import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart' show InfrastructureError;
import 'package:sqlite3/sqlite3.dart';

/// The device database, encrypted with SQLCipher (review F047).
///
/// The key is 32 random bytes written as 64 hex digits and used as SQLCipher's
/// raw key: it is random already, so no passphrase derivation runs on open. It
/// lives in the OS keychain, never beside the file.
String newDatabaseKey() {
  final random = Random.secure();
  return [for (var i = 0; i < 32; i++) random.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
}

/// Whether [key] has the shape of a database key. Only such a key is ever
/// written into SQL.
bool isDatabaseKey(String key) => _keyShape.hasMatch(key);
final _keyShape = RegExp(r'^[0-9a-f]{64}$');

/// What [prepareEncryptedDatabase] found at the path.
enum DatabasePreparation {
  /// No database yet: opening creates it, encrypted.
  none,

  /// An encrypted database this key opens.
  ready,

  /// A plain database from before encryption, now encrypted in place.
  encrypted,

  /// A database this key cannot open: the key was lost, or the file came from
  /// another device. It was renamed aside, never deleted, and a new database
  /// starts; the shop's data comes back from the server.
  setAside,
}

/// Makes the database at [path] ready to open with [key]. Run it once before
/// [openEncryptedDatabase], off the UI isolate: converting a plain file reads
/// all of it.
DatabasePreparation prepareEncryptedDatabase(String path, String key, {DateTime? now}) {
  _checkKey(key);
  // Without SQLCipher every encrypted file would look unreadable and be set
  // aside: stop before touching anything.
  _requireSqlCipher();
  // An interrupted earlier conversion leaves a partial copy: never trust it.
  final partial = File('$path$_encryptingSuffix');
  if (partial.existsSync()) partial.deleteSync();

  final file = File(path);
  if (!file.existsSync() || file.lengthSync() == 0) return DatabasePreparation.none;
  if (isPlainSqliteFile(path)) {
    _encryptInPlace(path, key);
    return DatabasePreparation.encrypted;
  }
  if (_opensWith(path, key)) return DatabasePreparation.ready;
  _setAside(path, now ?? DateTime.now().toUtc());
  return DatabasePreparation.setAside;
}

/// Opens the prepared database at [path] with [key] on a background isolate.
QueryExecutor openEncryptedDatabase(String path, String key) {
  _checkKey(key);
  return NativeDatabase.createInBackground(File(path), setup: (db) => applyDatabaseKey(db, key));
}

/// Keys a connection that was just opened. It refuses a SQLite without
/// SQLCipher, which would ignore the key and write the data in the clear.
void applyDatabaseKey(Database db, String key) {
  _checkKey(key);
  db.execute("PRAGMA key = \"x'$key'\";");
  if (!_hasCipher(db)) throw InfrastructureError('LOCAL_DB_CIPHER_MISSING');
  // Reading the schema checks the key now rather than at the first query.
  db.select('SELECT count(*) FROM sqlite_master');
}

/// Whether the file at [path] starts with plain SQLite's header, readable by
/// anyone who copies it. An encrypted file starts with random bytes.
bool isPlainSqliteFile(String path) {
  final raf = File(path).openSync();
  try {
    final head = raf.readSync(16);
    return head.length == 16 && String.fromCharCodes(head.take(15)) == 'SQLite format 3' && head[15] == 0;
  } finally {
    raf.closeSync();
  }
}

const _encryptingSuffix = '.encrypting';
const _companions = ['-wal', '-shm', '-journal'];
const _sqliteNotADatabase = 26;

void _checkKey(String key) {
  if (!isDatabaseKey(key)) throw ArgumentError('not a database key'); // never echo it
}

bool _hasCipher(Database db) {
  final rows = db.select('PRAGMA cipher_version');
  return rows.isNotEmpty && ((rows.first.values.first as String?) ?? '').isNotEmpty;
}

void _requireSqlCipher() {
  final probe = sqlite3.openInMemory();
  try {
    if (!_hasCipher(probe)) throw InfrastructureError('LOCAL_DB_CIPHER_MISSING');
  } finally {
    probe.close();
  }
}

bool _opensWith(String path, String key) {
  final db = sqlite3.open(path);
  try {
    db.execute("PRAGMA key = \"x'$key'\";");
    db.select('SELECT count(*) FROM sqlite_master');
    return true;
  } on SqliteException catch (e) {
    if (e.resultCode == _sqliteNotADatabase) return false;
    rethrow;
  } finally {
    db.close();
  }
}

void _encryptInPlace(String path, String key) {
  final copy = '$path$_encryptingSuffix';
  final plain = sqlite3.open(path);
  try {
    // sqlcipher_export copies the schema and every row but not user_version,
    // which drift reads as the schema version.
    final version = plain.select('PRAGMA user_version').first.values.first! as int;
    plain.execute("ATTACH DATABASE '${copy.replaceAll("'", "''")}' AS encrypted KEY \"x'$key'\";");
    plain.select("SELECT sqlcipher_export('encrypted')");
    plain.execute('PRAGMA encrypted.user_version = $version;');
    plain.execute('DETACH DATABASE encrypted;');
  } finally {
    plain.close();
  }
  // The plain file's journal would be replayed into the encrypted one, so it
  // goes first. A crash from here on leaves the plain file to convert again.
  for (final suffix in _companions) {
    final f = File('$path$suffix');
    if (f.existsSync()) f.deleteSync();
  }
  File(copy).renameSync(path);
}

void _setAside(String path, DateTime now) {
  final stamp = now.toIso8601String().replaceAll(RegExp('[^0-9]'), '').substring(0, 14);
  final aside = '$path.unreadable-$stamp';
  File(path).renameSync(aside);
  for (final suffix in _companions) {
    final f = File('$path$suffix');
    if (f.existsSync()) f.renameSync('$aside$suffix');
  }
}
