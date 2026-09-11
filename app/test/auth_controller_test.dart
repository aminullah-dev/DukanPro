import 'package:drift/native.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/auth_state.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  ProviderContainer makeContainer(FakeSecureStore store) => ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          secureStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(FakeAuthApi()),
          verifierProvider.overrideWithValue(FakeVerifier()),
        ],
      );

  test('restore with no cache -> logged out', () async {
    final c = makeContainer(FakeSecureStore());
    await c.read(authControllerProvider.notifier).restore();
    expect(c.read(authControllerProvider), isA<AuthLoggedOut>());
    c.dispose();
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
    c.dispose();
  });

  test('bad credentials -> logged out with error code', () async {
    final c = makeContainer(FakeSecureStore());
    await c.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'bad');
    final s = c.read(authControllerProvider);
    expect(s, isA<AuthLoggedOut>());
    expect((s as AuthLoggedOut).error, 'INVALID_CREDENTIALS');
    c.dispose();
  });

  test('logout clears stored credentials', () async {
    final store = FakeSecureStore();
    final c = makeContainer(store);
    final controller = c.read(authControllerProvider.notifier);
    await controller.loginOnline(username: 'owner', password: 'correct');
    await controller.logout();
    expect(c.read(authControllerProvider), isA<AuthLoggedOut>());
    expect(await store.read(SecureKeys.refreshToken), isNull);
    c.dispose();
  });
}
