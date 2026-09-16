// A cashier's shell offers the till's panes only: what needs another permission
// (the dashboard, stock, suppliers, staff, branches, the audit log, the
// notifications) is not there at all.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/app_shell.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/audit/audit_providers.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/iam/iam_providers.dart';
import 'package:dukanpro/features/insights/insights_providers.dart';
import 'package:dukanpro/features/insights/notifications_bell.dart';
import 'package:dukanpro/features/sync/sync_providers.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets("a cashier's shell offers only the till's panes", (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(FakeSecureStore()),
      authApiProvider.overrideWithValue(FakeAuthApi()),
      verifierProvider.overrideWithValue(FakeVerifier()),
      syncClientProvider.overrideWithValue(FakeSyncClient()),
      autoSyncProvider.overrideWithValue(false),
      insightsApiProvider.overrideWithValue(FakeInsightsApi()),
      iamApiProvider.overrideWithValue(FakeIamApi()),
      auditApiProvider.overrideWithValue(FakeAuditApi(const [])),
      // Signed in, and the shell asks this user what they may do: a cashier.
      sessionActorProvider.overrideWithValue(SessionActor(
        User(
          id: 'u1', username: 'kamal', displayName: 'Kamal', status: UserStatus.active,
          assignments: [BranchAssignment(branchId: 'b1', roleName: 'cashier')], defaultBranchId: 'b1',
        ),
        'b1',
      )),
    ]);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'correct');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(),
      ),
    ));
    await tester.pumpAndSettle();

    for (final offered in ['Point of sale', 'Products', 'Customers', 'Settings']) {
      expect(find.text(offered), findsWidgets, reason: offered);
    }
    for (final hidden in ['Dashboard', 'Receive stock', 'Suppliers', 'Employees', 'Branches', 'Audit log']) {
      expect(find.text(hidden), findsNothing, reason: hidden);
    }
    expect(find.byType(NotificationsBell), findsNothing);

    // The shell's sync control runs a periodic timer: stop it before the test ends.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}
