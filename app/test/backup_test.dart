// A shop with no server keeps its books on one device. Its owner sends a
// backup somewhere else, is reminded while there is none, and a new device
// takes the shop back from that file with the shop's password.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/auth/auth_controller.dart';
import 'package:dukanpro/features/auth/auth_state.dart';
import 'package:dukanpro/features/auth/login_screen.dart';
import 'package:dukanpro/features/auth/providers.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/settings/backup.dart';
import 'package:dukanpro/infrastructure/device_id.dart';
import 'package:dukanpro/infrastructure/file_share.dart';
import 'package:dukanpro/infrastructure/secure_store.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Long enough for [assertPasswordStrong]; nothing in the shipped app.
const _password = 'shop-owner-pass';
const _piece = '00000000-0000-7000-8000-000000000001';

/// What the share sheet was handed, and whether a place to send it was chosen.
class _Shares {
  _Shares({this.chosen = true});
  bool chosen;
  final sent = <({String path, String mimeType})>[];

  Future<bool> call(String path, {required String mimeType, Rect? origin}) async {
    sent.add((path: path, mimeType: mimeType));
    return chosen;
  }
}

void main() {
  late Directory dir;
  final now = DateTime.utc(2026, 9, 17, 8);

  setUp(() => dir = Directory.systemTemp.createTempSync('dukan_backup_app'));
  tearDown(() => dir.deleteSync(recursive: true));

  AppDatabase database() {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  ProviderContainer container(
    AppDatabase db, {
    FakeSecureStore? store,
    AppMode? saved,
    void Function(AppMode)? onSave,
    _Shares? shares,
    PickFile? pick,
  }) {
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(store ?? FakeSecureStore()),
      authApiProvider.overrideWithValue(FakeAuthApi()),
      verifierProvider.overrideWithValue(FakeVerifier()),
      clockProvider.overrideWithValue(() => now),
      workDirectoryProvider.overrideWithValue(() async => dir),
      if (saved != null) savedAppModeProvider.overrideWithValue(saved),
      if (onSave != null) saveAppModeProvider.overrideWithValue(onSave),
      if (shares != null) shareFileProvider.overrideWithValue(shares.call),
      if (pick != null) pickFileProvider.overrideWithValue(pick),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  Future<void> setUpShop(ProviderContainer c) => c.read(authControllerProvider.notifier).setupStandalone(
        username: 'ahmad', password: _password, displayName: 'Ahmad', shopName: 'Dukan-e Ahmad',
      );

  /// A shop with one product, backed up to a file; returns the file's path.
  Future<String> backedUpShop() async {
    final db = database();
    final c = container(db, saved: AppMode.standalone);
    await setUpShop(c);
    final soap = Product(id: newId(), sku: 'S1', name: 'Soap', unitId: _piece, sellPrice: Money(5000, 'AFN'));
    await LocalCatalog(db).createProduct(soap, barcodes: const [], actorId: 'u1', deviceId: 'old-till');
    final path = '${dir.path}/shop.dukanpro';
    await ShopBackup(db).export(path, _password);
    return path;
  }

  Widget app(ProviderContainer c, Widget home) => UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      );

  /// Confirms the restore and waits for it: copying the file and opening it
  /// are real work, off the test's clock, whose results the test's clock then
  /// has to pick up. The screen removes the chosen file's copy last of all.
  Future<void> restoreAndWait(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
    final picked = File('${dir.path}/picked');
    for (var i = 0; i < 250 && picked.existsSync(); i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
  }

  test('a shop restored onto a new device is its shop there, opened with the same password', () async {
    final path = await backedUpShop();
    final db = database();
    await SettingsStore(db).set(deviceIdSettingKey, 'new-till');
    final saved = <AppMode>[];
    final c = container(db, onSave: saved.add);
    final controller = c.read(authControllerProvider.notifier);

    await controller.restoreStandalone(path: path, password: _password, workDirectory: dir);

    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(saved, [AppMode.standalone]);
    expect(c.read(shopNameProvider), 'Dukan-e Ahmad');
    expect(c.read(sessionActorProvider)!.can(Permission.settingsManage), isTrue);
    expect((await LocalCatalog(db).products.list()).single.name, 'Soap');
    expect(await SettingsStore(db).get(deviceIdSettingKey), 'new-till', reason: 'its sale numbers stay its own');

    controller.lock();
    await controller.unlockWithPassword(_password);
    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
  });

  test('a wrong password leaves the new device as it was: no shop, no mode, no password', () async {
    final path = await backedUpShop();
    final db = database();
    final store = FakeSecureStore();
    final saved = <AppMode>[];
    final c = container(db, store: store, onSave: saved.add);

    await c.read(authControllerProvider.notifier).restoreStandalone(path: path, password: 'not-it', workDirectory: dir);

    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'BACKUP_PASSWORD_WRONG');
    expect(saved, isEmpty);
    expect(await store.read(SecureKeys.passwordVerifier), isNull);
    expect(await ProfileStore(db).current(), isNull);
  });

  test('a file that cannot be read is a failed restore, not a failed sign-in', () async {
    final c = container(database());
    await c
        .read(authControllerProvider.notifier)
        .restoreStandalone(path: '${dir.path}/gone.dukanpro', password: _password, workDirectory: dir);
    expect((c.read(authControllerProvider) as AuthLoggedOut).error, 'BACKUP_FAILED');
  });

  test('only the owner of a shop with no server is offered backups', () async {
    final standalone = container(database(), saved: AppMode.standalone);
    await setUpShop(standalone);
    expect(standalone.read(canBackUpProvider), isTrue);

    // With a server, the server keeps the books.
    final server = container(database());
    await server.read(authControllerProvider.notifier).loginOnline(username: 'owner', password: 'correct');
    expect(server.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(server.read(canBackUpProvider), isFalse);
  });

  testWidgets('a backup asks for the password again, then sends an encrypted file and says when', (tester) async {
    final db = database();
    final shares = _Shares();
    final c = container(db, saved: AppMode.standalone, shares: shares);
    await setUpShop(c);
    await tester.pumpWidget(app(c, const Scaffold(body: BackupTile())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Never backed up'), findsOneWidget);

    await tester.tap(find.text('Back up this shop'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not-the-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Back up'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect — try again.'), findsOneWidget);
    expect(shares.sent, isEmpty);
    await tester.pump(const Duration(seconds: 5)); // that message goes away
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back up this shop'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), _password);
    await tester.tap(find.widgetWithText(FilledButton, 'Back up'));
    await tester.pumpAndSettle();

    final sent = shares.sent.single;
    expect(sent.path, endsWith('dukanpro-backup-2026-09-17.dukanpro'));
    expect(sent.mimeType, 'application/octet-stream');
    expect(File(sent.path).existsSync(), isTrue);
    expect(String.fromCharCodes(File(sent.path).readAsBytesSync()).contains('Dukan-e Ahmad'), isFalse);
    expect(find.textContaining('Backup made.'), findsOneWidget);
    expect(find.textContaining('Last backup:'), findsOneWidget);
    expect(c.read(lastBackupProvider).value, now);
  });

  testWidgets('a share sheet closed without sending anywhere is not a backup', (tester) async {
    final shares = _Shares(chosen: false);
    final c = container(database(), saved: AppMode.standalone, shares: shares);
    await setUpShop(c);
    await tester.pumpWidget(app(c, const Scaffold(body: BackupTile())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back up this shop'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), _password);
    await tester.tap(find.widgetWithText(FilledButton, 'Back up'));
    await tester.pumpAndSettle();

    expect(shares.sent, hasLength(1));
    expect(find.textContaining('Never backed up'), findsOneWidget);
    expect(c.read(lastBackupProvider).value, isNull);
  });

  testWidgets('the dashboard asks for a backup while there is none, or the last is a week old', (tester) async {
    final c = container(database(), saved: AppMode.standalone);
    await setUpShop(c);
    await tester.pumpWidget(app(c, const Scaffold(body: BackupReminder())));
    await tester.pumpAndSettle();
    expect(find.textContaining('never been backed up'), findsOneWidget);

    await c.read(lastBackupProvider.notifier).record(now.subtract(const Duration(days: 3)));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsNothing);

    await c.read(lastBackupProvider.notifier).record(now.subtract(const Duration(days: 10)));
    await tester.pumpAndSettle();
    expect(find.text('The last backup is 10 days old.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Back up now'), findsOneWidget);
  });

  testWidgets('a new device takes a shop back from the sign-in screen', (tester) async {
    final backup = (await tester.runAsync(backedUpShop))!;
    final db = database();
    final c = container(db, pick: (into) async => File(backup).copySync('${into.path}/picked').path);
    await tester.pumpWidget(app(c, const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore a shop from a backup'));
    await tester.pumpAndSettle();
    expect(find.text("The shop's password"), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, _password);
    await restoreAndWait(tester);
    await tester.pumpAndSettle();

    expect(c.read(authControllerProvider), isA<AuthLoggedIn>());
    expect(File('${dir.path}/picked').existsSync(), isFalse, reason: 'the copy it was chosen as is removed');
  });

  testWidgets('a wrong password on the sign-in screen says what went wrong', (tester) async {
    final backup = (await tester.runAsync(backedUpShop))!;
    final c = container(database(), pick: (into) async => File(backup).copySync('${into.path}/picked').path);
    await tester.pumpWidget(app(c, const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore a shop from a backup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'not-the-password');
    await restoreAndWait(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('This password does not open the file.'), findsOneWidget);
  });
}
