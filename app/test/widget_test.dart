import 'package:drift/native.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/features/auth/login_screen.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/infrastructure/biometric.dart';
import 'package:dukanpro/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  testWidgets('with no cached session the app routes to the login screen', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() async => db.close());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          secureStoreProvider.overrideWithValue(FakeSecureStore()),
          authApiProvider.overrideWithValue(FakeAuthApi()),
          verifierProvider.overrideWithValue(FakeVerifier()),
          biometricProvider.overrideWithValue(const NoBiometric()),
        ],
        child: const DukanProApp(),
      ),
    );

    // Let restore() run and the router redirect away from the splash.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
