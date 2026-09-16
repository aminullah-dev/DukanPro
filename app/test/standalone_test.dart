// A shop with no server: one device is the whole shop. It sets itself up, it
// unlocks however long it has been, and what a server would own is not offered.
import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/app_shell.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/audit/audit_providers.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/auth_state.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/auth/login_screen.dart';
import 'package:dukanpro/features/iam/iam_providers.dart';
import 'package:dukanpro/features/insights/insights_providers.dart';
import 'package:dukanpro/features/insights/notifications_bell.dart';
import 'package:dukanpro/features/sync/sync_button.dart';
import 'package:dukanpro/features/sync/sync_providers.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Long enough for [assertPasswordStrong]; nothing in the shipped app.
const _password = 'shop-owner-pass';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  ProviderContainer makeContainer(
    FakeSecureStore store, {
    AppMode? saved,
    void Function(AppMode)? onSave,
    DateTime Function()? clock,
  }) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(FakeAuthApi()),
        verifierProvider.overrideWithValue(FakeVerifier()),
        if (saved != null) savedAppModeProvider.overrideWithValue(saved),
        if (onSave != null) saveAppModeProvider.overrideWithValue(onSave),
        if (clock != null) clockProvider.overrideWithValue(clock),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> setUpShop(ProviderContainer c) =>
      c.read(authControllerProvider.notifier).setupStandalone(
            username: 'ahmad',
            password: _password,
            displayName: 'Ahmad',
            shopName: 'Dukan-e Ahmad',
          );

  test('the device writes its own owner and keeps the mode', () async {
    final store = FakeSecureStore();
    final saved = <AppMode>[];
    final c = makeContainer(store, onSave: saved.add);

    await setUpShop(c);

    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    // This is what the device is from now on, and it is kept across restarts.
    expect(saved, [AppMode.standalone]);
    expect(c.read(standaloneProvider), isTrue);
    // Whoever set the shop up owns it, in the one branch the shop itself is.
    final actor = c.read(sessionActorProvider)!;
    expect(actor.can(Permission.saleCreate), isTrue);
    expect(actor.can(Permission.settingsManage), isTrue);
    expect(c.read(shopNameProvider), 'Dukan-e Ahmad');
    // Nothing was asked of a server, so the device holds no session from one.
    expect(await store.read(SecureKeys.refreshToken), isNull);
    expect(await store.read(SecureKeys.passwordVerifier), isNotNull);
    // Nothing to sync to, so the device never tries.
    expect(c.read(autoSyncProvider), isFalse);
  });

  test('a password too short is refused and no shop is set up', () async {
    final store = FakeSecureStore();
    final saved = <AppMode>[];
    final c = makeContainer(store, onSave: saved.add);

    await c.read(authControllerProvider.notifier).setupStandalone(
          username: 'ahmad', password: 'short', displayName: 'Ahmad', shopName: 'Dukan-e Ahmad',
        );

    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'WEAK_PASSWORD');
    expect(saved, isEmpty, reason: 'the device is not a shop without a server yet');
    expect(await ProfileStore(db).current(), isNull);
  });

  test('it unlocks however long it has been, with no server to confirm anyone', () async {
    final store = FakeSecureStore();
    var now = DateTime.utc(2026, 1, 1);
    final c = makeContainer(store, saved: AppMode.standalone, clock: () => now);
    final controller = c.read(authControllerProvider.notifier);
    await setUpShop(c);

    controller.lock();
    expect(c.read(authControllerProvider), isA<AuthLocked>());
    // A year on. With a server behind it this device would be long past its
    // offline window; here there is no window to run out.
    now = DateTime.utc(2027, 1, 1);
    await controller.unlockWithPassword(_password);

    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
  });

  test('a PIN unlocks though no server ever issued a session', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store, saved: AppMode.standalone);
    final controller = c.read(authControllerProvider.notifier);
    await setUpShop(c);

    await controller.setPin('4821');
    controller.lock();
    await controller.unlockWithPin('4821');

    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
  });

  test('a wrong password is still refused', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store, saved: AppMode.standalone);
    final controller = c.read(authControllerProvider.notifier);
    await setUpShop(c);

    controller.lock();
    await controller.unlockWithPassword('not-the-password');

    expect((c.read(authControllerProvider) as AuthLocked).error, 'WRONG_SECRET');
  });

  test('signing out cannot wipe the only account there is', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store, saved: AppMode.standalone);
    await setUpShop(c);

    await c.read(authControllerProvider.notifier).logout();

    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(await store.read(SecureKeys.passwordVerifier), isNotNull);
    expect(await ProfileStore(db).current(), isNotNull);
  });

  testWidgets('the shell offers no staff, branches, audit log or sync', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(FakeSecureStore()),
      authApiProvider.overrideWithValue(FakeAuthApi()),
      verifierProvider.overrideWithValue(FakeVerifier()),
      syncClientProvider.overrideWithValue(FakeSyncClient()),
      insightsApiProvider.overrideWithValue(FakeInsightsApi()),
      iamApiProvider.overrideWithValue(FakeIamApi()),
      auditApiProvider.overrideWithValue(FakeAuditApi(const [])),
      savedAppModeProvider.overrideWithValue(AppMode.standalone),
    ]);
    addTearDown(container.dispose);
    await setUpShop(container);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(),
      ),
    ));
    await tester.pumpAndSettle();

    // Everything the shop keeps on this device, owner's rights and all.
    for (final offered in ['Point of sale', 'Products', 'Customers', 'Dashboard', 'Settings']) {
      expect(find.text(offered), findsWidgets, reason: offered);
    }
    // What only a server could hold.
    for (final hidden in ['Employees', 'Branches', 'Audit log']) {
      expect(find.text(hidden), findsNothing, reason: hidden);
    }
    expect(find.byType(NotificationsBell), findsNothing);
    expect(find.byType(SyncAction), findsNothing);
    expect(find.byType(SyncStatusCard), findsNothing);
    // It says what it is, rather than calling itself offline.
    expect(find.text('This device only'), findsWidgets);
    // Sign-out would wipe the only account; only Lock is offered.
    expect(find.byTooltip('Lock'), findsWidgets);
    expect(find.byTooltip('Sign out'), findsNothing);

    // The shell's idle lock runs a timer: stop it before the test ends.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('the sign-in screen offers a shop with no server, and sets one up', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final store = FakeSecureStore();
    final saved = <AppMode>[];
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(store),
      authApiProvider.overrideWithValue(FakeAuthApi()),
      verifierProvider.overrideWithValue(FakeVerifier()),
      saveAppModeProvider.overrideWithValue(saved.add),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    // Both ways to set a shop up are offered from the start: a shop with no
    // server is a choice on the way in, not a setting to find later.
    expect(find.text('Set up without a server'), findsOneWidget);
    await tester.tap(find.text('Set up without a server'));
    await tester.pumpAndSettle();

    // It says what this is, and that the password cannot be recovered.
    expect(find.textContaining('Everything stays on this device'), findsOneWidget);
    expect(find.textContaining('Nobody can recover this password'), findsOneWidget);
    // No setup code: there is no server console to read one from.
    expect(find.text('Setup code'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'ahmad');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), _password);
    await tester.enterText(find.widgetWithText(TextField, 'Shop name'), 'Dukan-e Ahmad');
    await tester.tap(find.widgetWithText(FilledButton, 'Set up without a server'));
    await tester.pumpAndSettle();

    expect(container.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(saved, [AppMode.standalone]);
    expect(container.read(shopNameProvider), 'Dukan-e Ahmad');
  });
}
