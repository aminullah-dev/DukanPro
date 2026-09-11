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

  @override
  String get signIn => 'ننوتل';

  @override
  String get username => 'کارن نوم';

  @override
  String get password => 'پټنوم';

  @override
  String get displayName => 'ستاسو نوم';

  @override
  String get shopName => 'د دوکان نوم';

  @override
  String get firstRunSetup => 'لومړی ځل؟ خپل دوکان چمتو کړئ';

  @override
  String get unlock => 'خلاصول';

  @override
  String get usePin => 'د پین کارول';

  @override
  String get useBiometric => 'د بیومیټریک کارول';

  @override
  String get pinLabel => 'پین';

  @override
  String get logout => 'وتل';

  @override
  String get offlineMode => 'آفلاین';

  @override
  String get loginFailed => 'ننوتل ناکام شول. کارن نوم او پټنوم وګورئ.';

  @override
  String get wrongSecret => 'سم نه دی — بیا هڅه وکړئ.';

  @override
  String signedInAs(String user) {
    return 'د $user په توګه ننوتل';
  }
}
