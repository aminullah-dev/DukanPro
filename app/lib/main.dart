import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composition.dart';
import 'features/auth/providers.dart';
import 'infrastructure/auth_api.dart';
import 'infrastructure/biometric.dart';
import 'infrastructure/local_db.dart';
import 'infrastructure/secure_store.dart';
import 'infrastructure/sync_api.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await openAppDatabase();
  const apiBase = String.fromEnvironment('DUKAN_API', defaultValue: 'http://localhost:8088');
  final secureStore = FlutterSecureStore();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureStoreProvider.overrideWithValue(secureStore),
        authApiProvider.overrideWithValue(DioAuthApi(baseUrl: apiBase)),
        biometricProvider.overrideWithValue(LocalAuthBiometric()),
        syncClientProvider
            .overrideWithValue(DioSyncClient(baseUrl: apiBase, store: secureStore)),
      ],
      child: const DukanProApp(),
    ),
  );
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0F6B5C)),
      routerConfig: router,
    );
  }
}
