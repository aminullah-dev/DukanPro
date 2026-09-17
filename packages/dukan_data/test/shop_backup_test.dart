// A shop with no server keeps its books only on its device. A backup is the
// whole shop in one file, unreadable without the shop's password, that restores
// onto a new device without ever overwriting one that already holds a shop.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const _piece = '00000000-0000-7000-8000-000000000001';

/// With a quote in it: a password never breaks the SQL that carries it.
const _password = "the shop's password";

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('dukan_backup'));
  tearDown(() => dir.delete(recursive: true));

  Future<AppDatabase> shop() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await SettingsStore(db).set('device.id', 'old-till');
    await ProfileStore(db).replace(
      userId: 'u1', username: 'ahmad', displayName: 'Ahmad', defaultBranchId: 'b1',
      branches: [{'branch_id': 'b1', 'branch_name': 'Dukan-e Ahmad', 'role_name': 'owner'}],
    );
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap-7f3a', unitId: _piece, sellPrice: Money(5000, 'AFN'));
    await LocalCatalog(db).createProduct(
      soap, barcodes: [Barcode(id: newId(), productId: soap.id, code: '036000291452')],
      actorId: 'u1', deviceId: 'old-till',
    );
    return db;
  }

  Future<AppDatabase> newDevice() async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await SettingsStore(db).set('device.id', 'new-till');
    return db;
  }

  Future<String> backupOf(AppDatabase db, {String name = 'shop.dukanpro'}) async {
    final path = '${dir.path}/$name';
    await ShopBackup(db).export(path, _password);
    return path;
  }

  void setVersion(String path, int version) {
    final raw = sqlite3.open(path);
    try {
      raw.execute("PRAGMA key = '${_password.replaceAll("'", "''")}'");
      raw.execute('PRAGMA user_version = $version');
    } finally {
      raw.close();
    }
  }

  Matcher refusedWith(String code) => throwsA(isA<ValidationError>().having((e) => e.code, 'code', code));

  test('a backup restores the whole shop onto a new device, which keeps its own id', () async {
    final path = await backupOf(await shop());
    final device = await newDevice();

    await ShopBackup(device).restoreInto(path, _password, keepSettings: {'device.id'}, workDirectory: dir);

    expect((await LocalCatalog(device).products.findByBarcode('036000291452'))?.name, 'Soap-7f3a');
    expect((await ProfileStore(device).current())?.username, 'ahmad');
    expect(await SettingsStore(device).get('device.id'), 'new-till');
    expect(await DriftSyncOutbox(device).pending(), isNotEmpty, reason: "the shop's change log comes too");
  });

  test("a device's own encrypted database backs up, and restores into another encrypted one", () async {
    // As on a real device: each database under its own random key, which the
    // backup never carries. Only the password opens the backup.
    final old = AppDatabase(openEncryptedDatabase('${dir.path}/old.sqlite', newDatabaseKey()));
    addTearDown(old.close);
    await ProfileStore(old).replace(
      userId: 'u1', username: 'ahmad', displayName: 'Ahmad', defaultBranchId: 'b1',
      branches: [{'branch_id': 'b1', 'branch_name': 'Dukan-e Ahmad', 'role_name': 'owner'}],
    );
    final path = await backupOf(old);
    final device = AppDatabase(openEncryptedDatabase('${dir.path}/new.sqlite', newDatabaseKey()));
    addTearDown(device.close);

    await ShopBackup(device).restoreInto(path, _password, workDirectory: dir);

    expect((await ProfileStore(device).current())?.username, 'ahmad');
  });

  test('without the password the file cannot be opened, and no name in it can be read', () async {
    final path = await backupOf(await shop());
    final raw = sqlite3.open(path);
    addTearDown(raw.close);
    expect(() => raw.select('SELECT count(*) FROM sqlite_master'), throwsA(isA<SqliteException>()));
    expect(String.fromCharCodes(File(path).readAsBytesSync()).contains('Soap-7f3a'), isFalse);
  });

  test('a wrong password is refused, and the device is left as it was', () async {
    final path = await backupOf(await shop());
    final device = await newDevice();
    await expectLater(ShopBackup(device).restoreInto(path, 'not it', workDirectory: dir), refusedWith('BACKUP_PASSWORD_WRONG'));
    expect(await ProfileStore(device).current(), isNull);
  });

  test('a file that is no backup at all reads as a wrong password', () async {
    final path = '${dir.path}/photo.jpg';
    File(path).writeAsBytesSync(List.generate(4096, (i) => i % 251));
    await expectLater(
      ShopBackup(await newDevice()).restoreInto(path, _password, workDirectory: dir),
      refusedWith('BACKUP_PASSWORD_WRONG'),
    );
  });

  test('a backup made by a newer app is refused', () async {
    final path = await backupOf(await shop());
    setVersion(path, 99);
    await expectLater(
      ShopBackup(await newDevice()).restoreInto(path, _password, workDirectory: dir),
      refusedWith('BACKUP_TOO_NEW'),
    );
  });

  test('a backup made by an older app is brought up to date as it restores, and the chosen file is left unchanged', () async {
    final path = await backupOf(await shop());
    setVersion(path, 14);
    final before = File(path).readAsBytesSync();
    final device = await newDevice();

    await ShopBackup(device).restoreInto(path, _password, workDirectory: dir);

    expect((await LocalCatalog(device).products.findByBarcode('036000291452'))?.name, 'Soap-7f3a');
    expect(File(path).readAsBytesSync(), before);
  });

  test('a device that already holds a shop is never overwritten', () async {
    final path = await backupOf(await shop());
    final busy = await shop();
    await expectLater(ShopBackup(busy).restoreInto(path, _password, workDirectory: dir), refusedWith('BACKUP_DEVICE_NOT_EMPTY'));
    expect((await ProfileStore(busy).current())?.username, 'ahmad');
  });

  test('a database with no shop in it is not a backup', () async {
    final path = await backupOf(await newDevice(), name: 'empty.dukanpro');
    await expectLater(
      ShopBackup(await newDevice()).restoreInto(path, _password, workDirectory: dir),
      refusedWith('BACKUP_NOT_A_SHOP'),
    );
  });

  test('restoring leaves no working copy behind', () async {
    final path = await backupOf(await shop());
    await ShopBackup(await newDevice()).restoreInto(path, _password, workDirectory: dir);
    expect(dir.listSync().map((f) => f.uri.pathSegments.last), ['shop.dukanpro']);
  });
}
