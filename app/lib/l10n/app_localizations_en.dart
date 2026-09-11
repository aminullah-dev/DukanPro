// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DukanPro';

  @override
  String get tagline => 'Offline-first retail POS';

  @override
  String get posTitle => 'Sale';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get charge => 'Charge';

  @override
  String get cash => 'Cash';

  @override
  String get newSale => 'New sale';

  @override
  String itemsInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Your name';

  @override
  String get shopName => 'Shop name';

  @override
  String get firstRunSetup => 'First time? Set up your shop';

  @override
  String get unlock => 'Unlock';

  @override
  String get usePin => 'Use PIN';

  @override
  String get useBiometric => 'Use biometrics';

  @override
  String get pinLabel => 'PIN';

  @override
  String get logout => 'Sign out';

  @override
  String get offlineMode => 'Offline';

  @override
  String get loginFailed => 'Sign-in failed. Check your username and password.';

  @override
  String get wrongSecret => 'Incorrect — try again.';

  @override
  String signedInAs(String user) {
    return 'Signed in as $user';
  }
}
