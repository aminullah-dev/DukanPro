// The database key is made once, kept in secure storage and read back after
// that; when the database cannot be opened, the app says so.
import 'package:dukan_data/dukan_data.dart' show isDatabaseKey;
import 'package:dukanpro/infrastructure/local_db.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:dukanpro/startup_failed_app.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('the key is made once and read back after that', () async {
    final store = FakeSecureStore();
    final key = await databaseKey(store);
    expect(isDatabaseKey(key), isTrue);
    expect(await store.read(SecureKeys.databaseKey), key);
    expect(await databaseKey(store), key);
  });

  test('a stored value that is not a key is replaced by one', () async {
    final store = FakeSecureStore();
    await store.write(SecureKeys.databaseKey, 'not a key');
    final key = await databaseKey(store);
    expect(isDatabaseKey(key), isTrue);
    expect(await store.read(SecureKeys.databaseKey), key);
  });

  testWidgets('when the database cannot be opened, the app says so', (tester) async {
    await tester.pumpWidget(const StartupFailedApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be opened'), findsOneWidget);
  });
}
