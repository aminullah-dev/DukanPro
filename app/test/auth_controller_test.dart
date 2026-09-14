import 'dart:async';

import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/auth_state.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/infrastructure/biometric.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Secure storage that cannot be read (a locked keychain).
class _LockedKeychain extends FakeSecureStore {
  @override
  Future<String?> read(String key) async => throw PlatformException(code: '-34018');
}

/// A device whose fingerprint reader always says yes.
class _Fingerprint implements BiometricAuth {
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> authenticate(String reason) async => true;
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  ProviderContainer makeContainer(
    FakeSecureStore store, {
    FakeAuthApi? api,
    BiometricAuth? biometric,
    DateTime Function()? clock,
  }) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(api ?? FakeAuthApi()),
        verifierProvider.overrideWithValue(FakeVerifier()),
        if (biometric != null) biometricProvider.overrideWithValue(biometric),
        if (clock != null) clockProvider.overrideWithValue(clock),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('restore with no cache -> logged out', () async {
    final c = makeContainer(FakeSecureStore());
    await c.read(authControllerProvider.notifier).restore();
    expect(c.read(authControllerProvider), isA<AuthLoggedOut>());
  });

  test('online login caches credentials and logs in; offline unlock works', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store);
    final controller = c.read(authControllerProvider.notifier);

    await controller.loginOnline(username: 'owner', password: 'correct');
    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(await store.read(SecureKeys.passwordVerifier), isNotNull);
    expect(await store.read(SecureKeys.refreshToken), 'r1');

    await controller.unlockWithPassword('correct');
    final ok = c.read(authControllerProvider);
    expect(ok, isA<AuthLoggedIn>());
    expect((ok as AuthLoggedIn).offline, isTrue);

    await controller.unlockWithPassword('nope');
    expect(c.read(authControllerProvider), isA<AuthLocked>());
  });

  test('bad credentials -> logged out with error code', () async {
    final c = makeContainer(FakeSecureStore());
    await c.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'bad');
    final s = c.read(authControllerProvider);
    expect(s, isA<AuthLoggedOut>());
    expect((s as AuthLoggedOut).error, 'INVALID_CREDENTIALS');
  });

  test('logout clears stored credentials and the cached profile', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    await controller.logout();
    expect(c.read(authControllerProvider), isA<AuthLoggedOut>());
    expect(await store.read(SecureKeys.refreshToken), isNull);
    expect(await store.read(SecureKeys.validatedAt), isNull);
    expect(await db.select(db.cachedProfiles).get(), isEmpty);
  });

  test('the device caches exactly one profile: the latest signed-in user', () async {
    final c = makeContainer(FakeSecureStore());
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    await controller.loginOnline(username: 'cashier', password: 'correct');
    final cached = await db.select(db.cachedProfiles).get();
    expect(cached.map((p) => p.username), ['cashier']);
    expect((c.read(authControllerProvider) as AuthLoggedIn).profile.username, 'cashier');
  });

  test('revalidation refreshes roles and signs out a user the server no longer accepts', () async {
    final store = FakeSecureStore();
    final api = FakeAuthApi();
    final c = makeContainer(store, api: api);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    expect(c.read(sessionActorProvider)!.can(Permission.userManage), isTrue);

    // Demoted on the server, and the access token has lapsed: refresh, then re-read.
    api
      ..meRole = 'cashier'
      ..meErrors.add('TOKEN_EXPIRED');
    await controller.revalidate();
    expect(api.refreshCalls, 1);
    expect(await store.read(SecureKeys.refreshToken), 'r2');
    expect(c.read(sessionActorProvider)!.can(Permission.userManage), isFalse);

    // Disabled on the server: nothing is left to unlock with offline.
    api.meErrors.add('USER_DISABLED');
    await controller.revalidate();
    final s = c.read(authControllerProvider);
    expect(s, isA<AuthLoggedOut>());
    expect((s as AuthLoggedOut).error, 'USER_DISABLED');
    expect(await store.read(SecureKeys.passwordVerifier), isNull);
    expect(await db.select(db.cachedProfiles).get(), isEmpty);
  });

  test('offline unlock stops when the server has not confirmed the user for too long', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    controller.lock();
    final stale = DateTime.now().toUtc().subtract(AuthController.maxOfflineUnlock + const Duration(days: 1));
    await store.write(SecureKeys.validatedAt, stale.toIso8601String());

    await controller.unlockWithPassword('correct');

    final s = c.read(authControllerProvider);
    expect(s, isA<AuthLoggedOut>());
    expect((s as AuthLoggedOut).error, 'OFFLINE_EXPIRED');
  });

  test('lock keeps the session; another account can be tried and abandoned', () async {
    final c = makeContainer(FakeSecureStore());
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: 'piece', sellPrice: Money(5000, 'AFN'));
    c.read(posCartProvider.notifier).add(soap, 0);

    controller.lock();
    expect(c.read(authControllerProvider), isA<AuthLocked>());
    controller.useAnotherAccount();
    expect((c.read(authControllerProvider) as AuthLoggedOut).canReturn, isTrue);
    await controller.loginOnline(username: 'someone', password: 'bad'); // a failed try keeps the way back
    expect((c.read(authControllerProvider) as AuthLoggedOut).canReturn, isTrue);
    await controller.restore();
    expect(c.read(authControllerProvider), isA<AuthLocked>());
    await controller.unlockWithPassword('correct');
    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(c.read(posCartProvider), hasLength(1)); // the abandoned try kept the cart
  });

  test('setting the clock back does not stretch the offline window', () async {
    final store = FakeSecureStore();
    var now = DateTime.utc(2026, 9, 1);
    final c = makeContainer(store, clock: () => now);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');

    now = DateTime.utc(2026, 9, 21);
    controller.lock();
    await controller.unlockWithPassword('correct');
    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());

    // This device has seen 21 September: back on the 6th, a clock set back
    // could otherwise keep the 30-day window open for ever.
    now = DateTime.utc(2026, 9, 6);
    controller.lock();
    await controller.unlockWithPassword('correct');
    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'OFFLINE_EXPIRED');
  });

  test('a session that ended renews with the password used to unlock', () async {
    final api = FakeAuthApi();
    final c = makeContainer(FakeSecureStore(), api: api);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    controller.lock();
    await controller.unlockWithPassword('correct');

    api.meErrors.add('SESSION_REVOKED');
    await controller.revalidate(password: 'correct');
    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(api.loginCalls, 2);

    // Reset on the server: the old password no longer signs in.
    api
      ..password = 'changed-by-owner'
      ..meErrors.add('SESSION_REVOKED');
    await controller.revalidate(password: 'correct');
    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'SESSION_REVOKED');
  });

  test('without a password (PIN, fingerprint) an ended session needs an online sign-in', () async {
    final api = FakeAuthApi();
    final c = makeContainer(FakeSecureStore(), api: api);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    api.meErrors.add('REFRESH_INVALID');
    await controller.revalidate();
    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'REFRESH_INVALID');
    expect(api.loginCalls, 1);
  });

  test('sign-out does not wait for the server', () async {
    final store = FakeSecureStore();
    final api = FakeAuthApi()..logoutGate = Completer<void>(); // never answers
    final c = makeContainer(store, api: api);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');

    await controller.logout();
    expect(c.read(authControllerProvider), isA<AuthLoggedOut>());
    expect(await store.read(SecureKeys.refreshToken), isNull);
  });

  test('unreadable secure storage shows a message instead of a spinner', () async {
    final c = makeContainer(_LockedKeychain());
    await c.read(authControllerProvider.notifier).restore();
    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'STORAGE_UNAVAILABLE');
  });

  test('biometric unlock works only after the user opts in with the password', () async {
    final c = makeContainer(FakeSecureStore(), biometric: _Fingerprint());
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    controller.lock();

    expect(await controller.unlockWithBiometric(), isFalse); // not opted in
    expect(await controller.enableBiometric('wrong'), isFalse);
    expect(await controller.enableBiometric('correct'), isTrue);
    expect(await controller.unlockWithBiometric(), isTrue);
    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());

    // Another user signing in on the device does not inherit it.
    await controller.loginOnline(username: 'cashier', password: 'correct');
    expect(await controller.biometricEnabled(), isFalse);
  });

  test('a new user starts with an empty cart; a lock keeps it', () async {
    final c = makeContainer(FakeSecureStore());
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: 'piece', sellPrice: Money(5000, 'AFN'));
    c.read(posCartProvider.notifier).add(soap, 0);

    controller.lock();
    await controller.unlockWithPassword('correct');
    expect(c.read(posCartProvider), hasLength(1));

    await controller.loginOnline(username: 'cashier', password: 'correct');
    expect(c.read(posCartProvider), isEmpty);
  });
}
