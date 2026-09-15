import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:test/test.dart';

void main() {
  test('the built-in units are there even where other units came first', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // A device that seeded its own copy before the ids were fixed.
    await db.into(db.units).insert(UnitsCompanion.insert(id: newId(), name: 'kg', decimalPlaces: const Value(3)));
    final ids = (await LocalCatalog(db).listUnits()).map((u) => u.id);
    expect(ids, containsAll([for (final u in builtInUnits) u.id]));
  });
}
