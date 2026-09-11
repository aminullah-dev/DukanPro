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
  String get errNetwork =>
      'Can\'t reach the server. Make sure it\'s running, then try again.';

  @override
  String get errBootstrapDone =>
      'This server already has a shop set up. Sign in instead.';

  @override
  String get setupFailed => 'Setup failed. Please try again.';

  @override
  String get products => 'Products';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productName => 'Name';

  @override
  String get sku => 'SKU';

  @override
  String get price => 'Price';

  @override
  String get unit => 'Unit';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String get trackStock => 'Track stock';

  @override
  String get adjustStock => 'Adjust stock';

  @override
  String get quantityDelta => 'Quantity (+/-)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get onHand => 'In stock';

  @override
  String get noProducts => 'No products yet';

  @override
  String get searchHint => 'Search or scan…';

  @override
  String get permissionDenied => 'You don\'t have permission for this.';

  @override
  String get skuTaken => 'This SKU is already used.';

  @override
  String get pos => 'Point of sale';

  @override
  String get cartTitle => 'Cart';

  @override
  String get emptyCart => 'Cart is empty';

  @override
  String get tendered => 'Cash received';

  @override
  String get change => 'Change';

  @override
  String get receipt => 'Receipt';

  @override
  String signedInAs(String user) {
    return 'Signed in as $user';
  }
}
