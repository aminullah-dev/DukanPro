import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'widgets/localization_delegates.dart';

/// Shown instead of the app when this device's database cannot be opened: its
/// key unreadable in secure storage, or the file damaged. A sentence in the
/// device's language rather than a crash at launch.
class StartupFailedApp extends StatelessWidget {
  const StartupFailedApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(AppLocalizations.of(context).errLocalDatabase, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
      );
}
