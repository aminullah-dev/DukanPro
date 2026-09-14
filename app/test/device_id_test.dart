import 'package:drift/native.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/infrastructure/device_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an install gets one device id and keeps it', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final first = await loadDeviceId(db);
    expect(first, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$')));
    expect(await loadDeviceId(db), first);
  });
}
