// Theme 8: one shell tree for every width (a pane keeps its state across the
// breakpoint and exists once, built on first visit), and screens that fit a
// small phone: dashboard tiles with 7-digit figures, a dialog with the keyboard.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/app_shell.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/audit/audit_providers.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/customers/customers_screen.dart';
import 'package:dukanpro/features/dashboard/dashboard_screen.dart';
import 'package:dukanpro/features/iam/iam_providers.dart';
import 'package:dukanpro/features/insights/insights_providers.dart';
import 'package:dukanpro/features/pos/pos_screen.dart';
import 'package:dukanpro/features/sync/sync_providers.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void _size(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _app(ProviderContainer container, Widget home) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

void main() {
  testWidgets('crossing the breakpoint keeps a pane, its unsaved input, and one POS', (tester) async {
    _size(tester, const Size(1280, 800));
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
    ]);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'correct');
    await tester.pumpWidget(_app(container, const AppShell()));
    await tester.pumpAndSettle();

    // Panes are built on their first visit, not all at once.
    expect(find.byType(PosScreen, skipOffstage: false), findsNothing);
    await tester.tap(find.text('Point of sale'));
    await tester.pumpAndSettle();
    expect(find.text('Open shift'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '12');

    // Turned to a phone: the same pane, still holding what was typed, and no second POS.
    _size(tester, const Size(390, 844));
    await tester.pumpAndSettle();
    expect(find.byType(PosScreen, skipOffstage: false), findsOneWidget);
    expect(find.widgetWithText(TextField, '12'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsWidgets);
    expect(tester.takeException(), isNull);

    // The shell's sync control runs a periodic timer: stop it before the test ends.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(seconds: 1)); // the database's closed queries settle
  });

  testWidgets('dashboard tiles fit a small phone with 7-digit figures', (tester) async {
    _size(tester, const Size(360, 640));
    final container = ProviderContainer(overrides: [
      dashboardProvider.overrideWith((ref) async => const DashboardData(
            salesTodayMinor: 123456789, profitTodayMinor: 98765432, outstandingDebtMinor: 5555555500,
            lowStockCount: 12, topSellers: [], unknownCostLines: 3,
          )),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container, const DashboardScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the add-customer dialog scrolls when the keyboard takes half the screen', (tester) async {
    _size(tester, const Size(360, 640));
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      sessionActorProvider.overrideWithValue(SessionActor(
        User(
          id: 'u1', username: 'owner', displayName: 'Owner', status: UserStatus.active,
          assignments: [BranchAssignment(branchId: 'B1', roleName: 'owner')], defaultBranchId: 'B1',
        ),
        'B1',
      )),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(_app(container, const CustomersScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add customer'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
