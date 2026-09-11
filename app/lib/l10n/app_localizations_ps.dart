// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pushto Pashto (`ps`).
class AppLocalizationsPs extends AppLocalizations {
  AppLocalizationsPs([String locale = 'ps']) : super(locale);

  @override
  String get appTitle => 'دوکان‌پرو';

  @override
  String get tagline => 'آفلاین-محوره پلورنیز سیستم';

  @override
  String get posTitle => 'پلور';

  @override
  String get subtotal => 'فرعي ټول';

  @override
  String get total => 'ټول';

  @override
  String get charge => 'تادیه';

  @override
  String get cash => 'نغدي';

  @override
  String get newSale => 'نوی پلور';

  @override
  String itemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توکي',
      one: '۱ توکی',
      zero: 'هیڅ توکی نشته',
    );
    return '$_temp0';
  }
}
