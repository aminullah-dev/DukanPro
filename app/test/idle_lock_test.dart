// The idle lock is a setting of the device: an owner or a manager chooses it,
// everyone else sees it, and it is 10 minutes until someone chooses.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/settings/printer_settings_screen.dart';
import 'package:dukanpro/features/settings/settings_providers.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppDatabase _db() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(() async => db.close());
  return db;
}

SessionActor _actor(String role) => SessionActor(
      User(
        id: 'u-$role', username: role, displayName: role, status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: role)], defaultBranchId: 'B1',
      ),
      'B1',
    );

/// The device's settings as [role] sees them.
ProviderContainer _device(String role, AppDatabase db) {
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sessionActorProvider.overrideWithValue(_actor(role)),
  ]);
  addTearDown(container.dispose);
  return container;
}

Future<ProviderContainer> _settingsTile(WidgetTester tester, String role) async {
  final container = _device(role, _db());
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: IdleLockTile()),
    ),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  test('10 minutes until someone chooses; a choice stays on the device', () async {
    final db = _db();
    final manager = _device('manager', db);
    expect(await manager.read(idleLockProvider.future), 10);
    await manager.read(idleLockProvider.notifier).save(2);
    expect(manager.read(idleLockProvider).value, 2);
    // Read afresh, as after a restart or when the next person signs in.
    expect(await _device('cashier', db).read(idleLockProvider.future), 2);
  });

  test('a stored value that is not one of the choices reads as 10 minutes', () async {
    final db = _db();
    await SettingsStore(db).set(idleLockSettingKey, '7');
    expect(await _device('owner', db).read(idleLockProvider.future), 10);
  });

  test('a cashier cannot change it, and only the listed choices are saved', () async {
    final db = _db();
    final cashier = _device('cashier', db);
    await cashier.read(idleLockProvider.future);
    await expectLater(cashier.read(idleLockProvider.notifier).save(30), throwsA(isA<PermissionDeniedError>()));
    final owner = _device('owner', db);
    await owner.read(idleLockProvider.future);
    await expectLater(owner.read(idleLockProvider.notifier).save(7), throwsA(isA<ValidationError>()));
    expect(await SettingsStore(db).get(idleLockSettingKey), isNull);
  });

  testWidgets('a manager picks the time in settings', (tester) async {
    final container = await _settingsTile(tester, 'manager');
    expect(find.text('Only an owner or a manager can change this.'), findsNothing);
    await tester.tap(find.text('10 minutes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 minutes').last);
    await tester.pumpAndSettle();
    expect(container.read(idleLockProvider).value, 2);
    expect(find.text('Saved.'), findsOneWidget);
  });

  testWidgets('a cashier sees the time but cannot change it', (tester) async {
    await _settingsTile(tester, 'cashier');
    expect(find.text('10 minutes'), findsOneWidget);
    expect(find.text('Only an owner or a manager can change this.'), findsOneWidget);
    expect(tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>)).onChanged, isNull);
  });
}
