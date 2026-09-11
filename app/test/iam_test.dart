import 'package:dukanpro/features/iam/employees_screen.dart';
import 'package:dukanpro/features/iam/iam_providers.dart';
import 'package:dukanpro/infrastructure/iam_api.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('EmployeesController creates a staff member and refreshes the list', () async {
    final api = FakeIamApi();
    final container = ProviderContainer(overrides: [iamApiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);

    expect(await container.read(employeesControllerProvider.future), isEmpty);

    await container.read(employeesControllerProvider.notifier).create(
          username: 'cashier1', password: 'pw12345678', displayName: 'Cashier', roleName: 'cashier',
        );
    final list = await container.read(employeesControllerProvider.future);
    expect(list.single.username, 'cashier1');
    expect(list.single.isActive, isTrue);
  });

  test('EmployeesController disabling reflects the new status', () async {
    final api = FakeIamApi(employees: [
      const EmployeeDto(
        id: 'u1', username: 'amir', displayName: 'Amir', status: 'active', branches: [],
      ),
    ]);
    final container = ProviderContainer(overrides: [iamApiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);

    await container.read(employeesControllerProvider.future);
    await container.read(employeesControllerProvider.notifier).setStatus('u1', active: false);
    final list = await container.read(employeesControllerProvider.future);
    expect(list.single.isActive, isFalse);
  });

  testWidgets('EmployeesScreen renders the staff list from the API', (tester) async {
    final api = FakeIamApi(employees: [
      const EmployeeDto(
        id: 'u1', username: 'amir', displayName: 'Amir', status: 'active', branches: [],
      ),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [iamApiProvider.overrideWithValue(api)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: EmployeesScreen(),
        ),
      ),
    );
    await tester.pump(); // resolve the FutureProvider
    expect(find.text('Amir  (@amir)'), findsOneWidget);
    expect(find.text('Add employee'), findsOneWidget);
  });
}
