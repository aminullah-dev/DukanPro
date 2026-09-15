import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dukan_data/dukan_data.dart' show AppDatabase, SettingsStore;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composition.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/providers.dart';
import 'features/iam/iam_providers.dart';
import 'features/audit/audit_providers.dart';
import 'features/insights/insights_providers.dart';
import 'infrastructure/audit_api.dart';
import 'infrastructure/auth_api.dart';
import 'infrastructure/biometric.dart';
import 'infrastructure/device_id.dart';
import 'infrastructure/http.dart';
import 'infrastructure/iam_api.dart';
import 'infrastructure/insights_api.dart';
import 'infrastructure/keyboard_wedge_scanner.dart';
import 'infrastructure/local_db.dart';
import 'infrastructure/secure_store.dart';
import 'infrastructure/sync_api.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'startup_failed_app.dart';
import 'widgets/localization_delegates.dart';

/// The device database, or null when it cannot be opened (see StartupFailedApp).
Future<AppDatabase?> _openDatabase() async {
  try {
    return await openAppDatabase(FlutterSecureStore.thisDeviceOnly());
  } on Object catch (e) {
    debugPrint('The local database could not be opened: ${e.runtimeType}'); // never the key
    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await _openDatabase();
  if (db == null) {
    runApp(const StartupFailedApp());
    return;
  }
  final deviceId = await loadDeviceId(db);
  // The language chosen last on this device, from the first frame on.
  final settings = SettingsStore(db);
  final savedLocale = localeFromTag(await settings.get(localeSettingKey), AppLocalizations.supportedLocales);
  // Whether this shop has a server behind it, chosen when it was set up.
  final savedMode = appModeFromTag(await settings.get(appModeSettingKey));
  const apiBase = String.fromEnvironment('DUKAN_API', defaultValue: 'http://localhost:8088');
  final secureStore = FlutterSecureStore();
  final authApi = DioAuthApi(baseUrl: apiBase);
  // One refresher for every client: the server rotates the refresh token, so
  // renewals must never race.
  final refresher = TokenRefresher(store: secureStore, api: authApi);
  Dio api() => authedDio(apiBase, store: secureStore, refresher: refresher);

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      deviceIdProvider.overrideWithValue(deviceId),
      savedLocaleProvider.overrideWithValue(savedLocale),
      saveLocaleProvider.overrideWithValue(
          (locale) => unawaited(settings.set(localeSettingKey, localeTag(locale)).catchError((Object _) {}))),
      savedAppModeProvider.overrideWithValue(savedMode),
      saveAppModeProvider.overrideWithValue(
          (mode) => unawaited(settings.set(appModeSettingKey, mode.name).catchError((Object _) {}))),
      secureStoreProvider.overrideWithValue(secureStore),
      authApiProvider.overrideWithValue(authApi),
      tokenRefresherProvider.overrideWithValue(refresher),
      biometricProvider.overrideWithValue(LocalAuthBiometric()),
      syncClientProvider
          .overrideWithValue(DioSyncClient(baseUrl: apiBase, store: secureStore, dio: api())),
      iamApiProvider.overrideWithValue(DioIamApi(baseUrl: apiBase, store: secureStore, dio: api())),
      insightsApiProvider
          .overrideWithValue(DioInsightsApi(baseUrl: apiBase, store: secureStore, dio: api())),
      auditApiProvider.overrideWithValue(DioAuditApi(baseUrl: apiBase, store: secureStore, dio: api())),
      scannerProvider.overrideWithValue(KeyboardWedgeScanner()),
    ],
  );
  // A background request that finds its session over ends it (see AuthController.sessionEnded).
  refresher.onSessionEnded = (code, epoch) =>
      unawaited(container.read(authControllerProvider.notifier).sessionEnded(code, epoch: epoch));

  runApp(UncontrolledProviderScope(container: container, child: const DukanProApp()));
}

class DukanProApp extends ConsumerWidget {
  const DukanProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0F6B5C)),
      routerConfig: router,
    );
  }
}
