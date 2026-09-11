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

  @override
  String get signIn => 'ورود';

  @override
  String get username => 'نام کاربری';

  @override
  String get password => 'رمز عبور';

  @override
  String get displayName => 'نام شما';

  @override
  String get shopName => 'نام دکان';

  @override
  String get firstRunSetup => 'بار اول؟ دکان خود را راه‌اندازی کنید';

  @override
  String get unlock => 'باز کردن';

  @override
  String get usePin => 'استفاده از پین';

  @override
  String get useBiometric => 'استفاده از اثر انگشت';

  @override
  String get pinLabel => 'پین';

  @override
  String get logout => 'خروج';

  @override
  String get offlineMode => 'آفلاین';

  @override
  String get loginFailed =>
      'ورود ناکام شد. نام کاربری و رمز عبور را بررسی کنید.';

  @override
  String get wrongSecret => 'نادرست است — دوباره تلاش کنید.';

  @override
  String get errNetwork =>
      'دسترسی به سرور ممکن نشد. مطمئن شوید که در حال اجراست و دوباره تلاش کنید.';

  @override
  String get errBootstrapDone =>
      'این سرور از قبل یک دکان دارد. لطفاً وارد شوید.';

  @override
  String get setupFailed => 'راه‌اندازی ناکام شد. دوباره تلاش کنید.';

  @override
  String signedInAs(String user) {
    return 'واردشده به‌عنوان $user';
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

  @override
  String get signIn => 'ورود';

  @override
  String get username => 'نام کاربری';

  @override
  String get password => 'رمز عبور';

  @override
  String get displayName => 'نام شما';

  @override
  String get shopName => 'نام دکان';

  @override
  String get firstRunSetup => 'بار اول؟ دکان خود را راه‌اندازی کنید';

  @override
  String get unlock => 'باز کردن';

  @override
  String get usePin => 'استفاده از پین';

  @override
  String get useBiometric => 'استفاده از اثر انگشت';

  @override
  String get pinLabel => 'پین';

  @override
  String get logout => 'خروج';

  @override
  String get offlineMode => 'آفلاین';

  @override
  String get loginFailed =>
      'ورود ناکام شد. نام کاربری و رمز عبور را بررسی کنید.';

  @override
  String get wrongSecret => 'نادرست است — دوباره تلاش کنید.';

  @override
  String get errNetwork =>
      'دسترسی به سرور ممکن نشد. مطمئن شوید که در حال اجراست و دوباره تلاش کنید.';

  @override
  String get errBootstrapDone =>
      'این سرور از قبل یک دکان دارد. لطفاً وارد شوید.';

  @override
  String get setupFailed => 'راه‌اندازی ناکام شد. دوباره تلاش کنید.';

  @override
  String signedInAs(String user) {
    return 'واردشده به‌عنوان $user';
  }
}
