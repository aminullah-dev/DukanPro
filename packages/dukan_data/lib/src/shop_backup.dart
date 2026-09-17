import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:sqlite3/sqlite3.dart';

import '../database.dart';
import 'settings_store.dart';

/// SQLite's "file is not a database", which is how a wrong key reads.
const _notADatabase = 26;

/// A whole shop in one file, for a shop with no server. There the device is the
/// only place the books live, so a lost, broken or reset device loses them
/// unless a copy was kept somewhere else.
///
/// The file is itself a SQLCipher database keyed by the shop's password, from
/// which SQLCipher derives the key (PBKDF2-HMAC-SHA512). Without the password it
/// is noise; with it, it restores on any device running this app or a newer one.
final class ShopBackup {
  ShopBackup(this._db);
  final AppDatabase _db;

  /// Writes the whole of this device's database to [path], encrypted with [password].
  Future<void> export(String path, String password) async {
    _deleteWithCompanions(path);
    final version = await _userVersion();
    await _db.customStatement('ATTACH DATABASE ${_literal(path)} AS backup KEY ${_literal(password)}');
    try {
      await _db.customSelect("SELECT sqlcipher_export('backup')").get();
      // sqlcipher_export copies every table and row but not user_version, which
      // drift reads as the schema version.
      await _db.customStatement('PRAGMA backup.user_version = $version');
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
    }
  }

  /// Puts the shop in the backup at [path], opened with [password], onto this
  /// device, which must hold no shop yet. A backup from an older app is brought
  /// up to this app's schema first; one from a newer app is refused.
  ///
  /// Settings named in [keepSettings] keep this device's own values: its id
  /// above all, so its sale numbers never repeat the old device's. The work
  /// happens on a copy in [workDirectory], so the file the person chose is never
  /// changed.
  ///
  /// Raises [ValidationError] `BACKUP_PASSWORD_WRONG` (also for a file that is no
  /// backup at all), `BACKUP_TOO_NEW`, `BACKUP_NOT_A_SHOP` or
  /// `BACKUP_DEVICE_NOT_EMPTY`.
  Future<void> restoreInto(
    String path,
    String password, {
    Set<String> keepSettings = const {},
    Directory? workDirectory,
  }) async {
    await _requireNoShop();
    final work = '${(workDirectory ?? Directory.systemTemp).path}/dukanpro-restore-${newId()}.db';
    await File(path).copy(work);
    try {
      await _checkOffThisIsolate(work, password, _db.schemaVersion);
      await _upgrade(work, password);
      final kept = {for (final key in keepSettings) key: await SettingsStore(_db).get(key)};
      await _db.customStatement('ATTACH DATABASE ${_literal(work)} AS backup KEY ${_literal(password)}');
      try {
        await _db.transaction(() async {
          await _db.customStatement('PRAGMA defer_foreign_keys = ON');
          for (final table in _db.allTables) {
            final name = '"${table.actualTableName}"';
            // By name: a database brought up to date by migrations may order its
            // columns differently from one created at this version.
            final columns = table.$columns.map((c) => '"${c.name}"').join(', ');
            await _db.customStatement('DELETE FROM main.$name');
            await _db.customStatement('INSERT INTO main.$name ($columns) SELECT $columns FROM backup.$name');
          }
        });
      } finally {
        await _db.customStatement('DETACH DATABASE backup');
      }
      for (final MapEntry(:key, :value) in kept.entries) {
        if (value != null) await SettingsStore(_db).set(key, value);
      }
      _db.notifyUpdates({for (final table in _db.allTables) TableUpdate.onTable(table)});
    } finally {
      _deleteWithCompanions(work);
    }
  }

  /// A restore replaces everything, so it goes only onto a device that holds no
  /// shop: no profile, and no products, sales, customers, suppliers or stock.
  Future<void> _requireNoShop() async {
    final tables = <TableInfo<Table, Object?>>[
      _db.cachedProfiles,
      _db.products,
      _db.sales,
      _db.customers,
      _db.suppliers,
      _db.stockMovements,
    ];
    for (final table in tables) {
      final count = countAll();
      final rows = await (_db.selectOnly(table)..addColumns([count])).map((r) => r.read(count)).getSingle();
      if ((rows ?? 0) > 0) throw ValidationError('BACKUP_DEVICE_NOT_EMPTY');
    }
  }

  /// Opens the working copy as this app's database once: drift brings an older
  /// backup up to the current schema. What opens must hold a shop.
  Future<void> _upgrade(String path, String password) async {
    final copy = AppDatabase(
      NativeDatabase.createInBackground(File(path), setup: (raw) => raw.execute('PRAGMA key = ${_literal(password)}')),
    );
    try {
      if ((await copy.select(copy.cachedProfiles).get()).isEmpty) throw ValidationError('BACKUP_NOT_A_SHOP');
    } finally {
      await copy.close();
    }
  }

  Future<int> _userVersion() async =>
      (await _db.customSelect('PRAGMA user_version').getSingle()).data.values.first! as int;
}

/// Deriving a key from a password is slow on purpose, so the backup is opened
/// on an isolate of its own. Top-level, so the closure carries nothing else.
Future<void> _checkOffThisIsolate(String path, String password, int schemaVersion) =>
    Isolate.run(() => _checkBackup(path, password, schemaVersion));

/// Whether the file opens with [password] and holds a database this app can
/// bring up to date.
void _checkBackup(String path, String password, int schemaVersion) {
  final db = sqlite3.open(path);
  try {
    db.execute('PRAGMA key = ${_literal(password)}');
    final int version;
    try {
      db.select('SELECT count(*) FROM sqlite_master');
      version = db.select('PRAGMA user_version').first.values.first! as int;
    } on SqliteException catch (e) {
      if (e.resultCode == _notADatabase) throw ValidationError('BACKUP_PASSWORD_WRONG');
      rethrow;
    }
    if (version == 0) throw ValidationError('BACKUP_NOT_A_SHOP');
    if (version > schemaVersion) throw ValidationError('BACKUP_TOO_NEW', {'version': version});
  } finally {
    db.close();
  }
}

/// A SQL string literal: the only way a file path or a password enters SQL here.
String _literal(String text) => "'${text.replaceAll("'", "''")}'";

void _deleteWithCompanions(String path) {
  for (final suffix in const ['', '-journal', '-wal', '-shm']) {
    final file = File('$path$suffix');
    if (file.existsSync()) file.deleteSync();
  }
}
