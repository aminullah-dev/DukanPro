// The device database is encrypted with SQLCipher (review F047): a plain file
// is converted in place, the key is checked on open, and a file the key cannot
// open is set aside rather than deleted.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

late Directory _dir;
String get _path => '${_dir.path}/dukanpro.sqlite';

bool _fileHolds(String path, String text) {
  final bytes = File(path).readAsBytesSync();
  final needle = utf8.encode(text);
  outer:
  for (var i = 0; i + needle.length <= bytes.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (bytes[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

Future<void> _plainDatabaseWith(String value) async {
  final db = AppDatabase(NativeDatabase(File(_path)));
  await SettingsStore(db).set('probe', value);
  await db.close();
}

void main() {
  setUp(() => _dir = Directory.systemTemp.createTempSync('dukan_db_'));
  tearDown(() => _dir.deleteSync(recursive: true));

  test('the linked SQLite is SQLCipher', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    expect(db.select('PRAGMA cipher_version').first.values.first, isNotEmpty);
  });

  test('a new database is written encrypted and opens only with its key', () async {
    final key = newDatabaseKey();
    expect(prepareEncryptedDatabase(_path, key), DatabasePreparation.none);
    final db = AppDatabase(openEncryptedDatabase(_path, key));
    await SettingsStore(db).set('probe', 'a customer phone number');
    await db.close();

    expect(isPlainSqliteFile(_path), isFalse);
    expect(_fileHolds(_path, 'a customer phone number'), isFalse);
    final unkeyed = sqlite3.open(_path);
    expect(
      () => unkeyed.select('SELECT count(*) FROM sqlite_master'),
      throwsA(isA<SqliteException>().having((e) => e.resultCode, 'resultCode', 26)),
    );
    unkeyed.close();

    expect(prepareEncryptedDatabase(_path, key), DatabasePreparation.ready);
    final again = AppDatabase(openEncryptedDatabase(_path, key));
    expect(await SettingsStore(again).get('probe'), 'a customer phone number');
    await again.close();
  });

  test('a plain database from before encryption is encrypted in place, keeping rows and schema version', () async {
    await _plainDatabaseWith('from before');
    expect(isPlainSqliteFile(_path), isTrue);

    final key = newDatabaseKey();
    expect(prepareEncryptedDatabase(_path, key), DatabasePreparation.encrypted);
    expect(isPlainSqliteFile(_path), isFalse);
    expect(_fileHolds(_path, 'from before'), isFalse);
    expect(File('$_path.encrypting').existsSync(), isFalse);

    final db = AppDatabase(openEncryptedDatabase(_path, key));
    expect(await SettingsStore(db).get('probe'), 'from before');
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, db.schemaVersion);
    await db.close();
  });

  test('a partial copy left by an interrupted conversion is discarded and the conversion redone', () async {
    await _plainDatabaseWith('intact');
    File('$_path.encrypting').writeAsStringSync('half a copy');
    final key = newDatabaseKey();
    expect(prepareEncryptedDatabase(_path, key), DatabasePreparation.encrypted);
    final db = AppDatabase(openEncryptedDatabase(_path, key));
    expect(await SettingsStore(db).get('probe'), 'intact');
    await db.close();
  });

  test('a database the key cannot open is set aside, never deleted, and a new one starts', () async {
    final lost = newDatabaseKey();
    prepareEncryptedDatabase(_path, lost);
    final old = AppDatabase(openEncryptedDatabase(_path, lost));
    await SettingsStore(old).set('probe', 'old');
    await old.close();
    final bytes = File(_path).readAsBytesSync();

    final key = newDatabaseKey();
    final now = DateTime.utc(2026, 9, 15, 6, 44, 26);
    expect(prepareEncryptedDatabase(_path, key, now: now), DatabasePreparation.setAside);
    expect(File(_path).existsSync(), isFalse);
    expect(File('$_path.unreadable-20260915064426').readAsBytesSync(), bytes);

    final fresh = AppDatabase(openEncryptedDatabase(_path, key));
    expect(await SettingsStore(fresh).get('probe'), isNull);
    await fresh.close();
  });

  test('keys are 32 random bytes in hex, and nothing else is taken as one', () {
    final a = newDatabaseKey();
    expect(isDatabaseKey(a), isTrue);
    expect(a, isNot(newDatabaseKey()));
    for (final bad in ['', 'x' * 64, a.toUpperCase(), "${a.substring(1)}'", a.substring(2)]) {
      expect(isDatabaseKey(bad), isFalse, reason: bad);
      expect(() => prepareEncryptedDatabase(_path, bad), throwsArgumentError, reason: bad);
    }
  });
}
