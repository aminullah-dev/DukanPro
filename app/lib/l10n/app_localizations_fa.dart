// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'دکان‌پرو';

  @override
  String get tagline => 'سیستم فروش آفلاین‌محور';

  @override
  String get posTitle => 'فروش';

  @override
  String get subtotal => 'جمع جزء';

  @override
  String get total => 'مجموع';

  @override
  String get charge => 'پرداخت';

  @override
  String get cash => 'نقد';

  @override
  String get newSale => 'فروش جدید';

  @override
  String itemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قلم',
      one: '۱ قلم',
      zero: 'بدون قلم',
    );
    return '$_temp0';
  }
}

/// The translations for Persian, as used in Afghanistan (`fa_AF`).
class AppLocalizationsFaAf extends AppLocalizationsFa {
  AppLocalizationsFaAf() : super('fa_AF');

  @override
  String get appTitle => 'دکان‌پرو';

  @override
  String get tagline => 'سیستم فروش آفلاین‌محور';

  @override
  String get posTitle => 'فروش';

  @override
  String get subtotal => 'جمع جزء';

  @override
  String get total => 'مجموع';

  @override
  String get charge => 'پرداخت';

  @override
  String get cash => 'نقد';

  @override
  String get newSale => 'فروش جدید';

  @override
  String itemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قلم',
      one: '۱ قلم',
      zero: 'بدون قلم',
    );
    return '$_temp0';
  }
}
