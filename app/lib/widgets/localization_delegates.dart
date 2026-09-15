import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

/// The app's localization delegates. Flutter ships no Cupertino strings for
/// Pashto, and text fields on iOS and macOS need them for their copy and paste
/// menu: Pashto borrows the Persian ones (the same script).
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  _PashtoCupertinoLocalizations(),
  ...AppLocalizations.localizationsDelegates,
];

class _PashtoCupertinoLocalizations extends LocalizationsDelegate<CupertinoLocalizations> {
  const _PashtoCupertinoLocalizations();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ps';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('fa'));

  @override
  bool shouldReload(_PashtoCupertinoLocalizations old) => false;
}
