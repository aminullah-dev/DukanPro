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
  String get customers => 'Customers';

  @override
  String get addCustomer => 'Add customer';

  @override
  String get customerName => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get creditLimit => 'Credit limit';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get amount => 'Amount';

  @override
  String get balance => 'Balance';

  @override
  String get credit => 'Credit';

  @override
  String get receiveStock => 'Receive stock';

  @override
  String get supplier => 'Supplier';

  @override
  String get unitCost => 'Unit cost';

  @override
  String get receive => 'Receive';

  @override
  String get noCustomers => 'No customers yet';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get salesToday => 'Sales today';

  @override
  String get profit => 'Profit';

  @override
  String get outstandingDebt => 'Outstanding debt';

  @override
  String get lowStock => 'Low stock';

  @override
  String get topSellers => 'Top sellers';

  @override
  String signedInAs(String user) {
    return 'Signed in as $user';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncing => 'Syncing…';

  @override
  String get syncUpToDate => 'Up to date';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes to sync',
      one: '1 change to sync',
      zero: 'All changes synced',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed =>
      'Couldn\'t sync. Check your connection and try again.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items need review',
      one: '1 item needs review',
    );
    return '$_temp0';
  }

  @override
  String lastSyncedAt(String time) {
    return 'Last synced $time';
  }

  @override
  String get employees => 'Employees';

  @override
  String get addEmployee => 'Add employee';

  @override
  String get noEmployees => 'No employees yet';

  @override
  String get role => 'Role';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get statusActive => 'Active';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get newPassword => 'New password';

  @override
  String get assignRole => 'Assign role';

  @override
  String get removeRole => 'Remove';

  @override
  String get branches => 'Branches';

  @override
  String get addBranch => 'Add branch';

  @override
  String get noBranches => 'No branches yet';

  @override
  String get branchNameLabel => 'Branch name';

  @override
  String get rename => 'Rename';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleStockKeeper => 'Stock keeper';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get errUserLastOwner => 'You can\'t disable the last owner.';

  @override
  String get errBranchLastActive =>
      'You can\'t deactivate the only active branch.';

  @override
  String get errUsernameTaken => 'This username is already taken.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get savedOk => 'Saved.';

  @override
  String get settings => 'Settings';

  @override
  String get printerSettings => 'Receipt printer';

  @override
  String get enablePrinting => 'Print receipts';

  @override
  String get printerHost => 'Printer IP address';

  @override
  String get printerPort => 'Port';

  @override
  String get testPrint => 'Test print';

  @override
  String get printReceipt => 'Print';

  @override
  String get printerNotConfigured =>
      'No printer configured. Set one up in Settings.';

  @override
  String get printSucceeded => 'Sent to printer.';

  @override
  String get printFailed => 'Couldn\'t reach the printer.';

  @override
  String get notifications => 'Notifications';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get noNotifications => 'You\'re all caught up';

  @override
  String get refreshInsights => 'Refresh';

  @override
  String get markReadAction => 'Mark read';

  @override
  String insightReorder(String product) {
    return 'Restock $product — running low';
  }

  @override
  String insightDeadStock(String product, String days) {
    return '$product hasn\'t sold in $days days';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer is near their credit limit';
  }

  @override
  String insightDigest(String count) {
    return '$count sales today';
  }

  @override
  String get insightUnknown => 'New insight';
}
