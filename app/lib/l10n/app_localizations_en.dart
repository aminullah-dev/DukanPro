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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items',
      one: '$countString item',
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
  String errLoginLocked(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Too many wrong passwords. Wait $minutesString minutes, then try again.';
  }

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
  String get setCreditLimit => 'Set credit limit';

  @override
  String get creditLimitHelp => 'Leave empty for no limit';

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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString changes to sync',
      one: '$countString change to sync',
      zero: 'All changes synced',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed =>
      'Couldn\'t sync. Check your connection and try again.';

  @override
  String syncConflicts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items need review',
      one: '$countString item needs review',
    );
    return '$_temp0';
  }

  @override
  String syncRejected(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString changes were rejected by the server',
      one: '$countString change was rejected by the server',
    );
    return '$_temp0';
  }

  @override
  String get setupCode => 'Setup code';

  @override
  String get setupCodeHelp =>
      'Shown in the server console when the server starts';

  @override
  String get standaloneSetup => 'Set up without a server';

  @override
  String get standaloneSetupHelp =>
      'Everything stays on this device. No server to install, no internet needed. One account: yours.';

  @override
  String get standalonePasswordWarning =>
      'Nobody can recover this password, not even us. Write it down and keep it somewhere safe.';

  @override
  String get standaloneMode => 'This device only';

  @override
  String get errSetupCode => 'Wrong setup code. Check the server console.';

  @override
  String get lock => 'Lock';

  @override
  String get logoutConfirmTitle => 'Sign out of this device?';

  @override
  String get logoutConfirmBody =>
      'Signing out removes the saved sign-in from this device. Until someone signs in online again, nobody can sell here.';

  @override
  String logoutPendingWarning(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString changes are not synced yet.',
      one: '$countString change is not synced yet.',
    );
    return '$_temp0';
  }

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get backToUnlock => 'Back';

  @override
  String get errOfflineExpired =>
      'This device has been offline too long. Sign in online.';

  @override
  String get errStorage =>
      'This device\'s secure storage could not be read. Sign in again; if it keeps happening, restart the device.';

  @override
  String get errLocalDatabase =>
      'The data on this device could not be opened. Close the app and open it again; if it keeps happening, restart the device.';

  @override
  String get errTotalTooLarge =>
      'This total is too large to record. Check the quantity and price.';

  @override
  String get errSessionEndedUnlock =>
      'Your session ended. Enter your password: the app keeps working offline and signs in again when it is online.';

  @override
  String get cashNow => 'Cash now';

  @override
  String get onCredit => 'On credit';

  @override
  String get deactivateCustomer => 'Close account';

  @override
  String get reactivateCustomer => 'Reopen account';

  @override
  String get customerInactive => 'Account closed: no credit';

  @override
  String get writeOffDebt => 'Write off debt';

  @override
  String profitMissingCost(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items sold without a cost',
      one: '$countString item sold without a cost',
    );
    return '$_temp0';
  }

  @override
  String get errCustomerInactive =>
      'This customer\'s account is closed: no credit.';

  @override
  String get errDebtCurrency =>
      'This customer\'s debt is in another currency; credit is given only in their currency.';

  @override
  String get errOverCreditLimit =>
      'This sale would take the customer over their credit limit.';

  @override
  String get errDebtOverpayment => 'That is more than the customer owes.';

  @override
  String get errWriteOffTooMuch =>
      'You can write off at most what the customer owes.';

  @override
  String get openShift => 'Open shift';

  @override
  String get closeShift => 'Close shift';

  @override
  String get openingFloat => 'Cash in the drawer to start';

  @override
  String get openShiftPrompt =>
      'Open your shift to start selling. Count the cash already in the drawer.';

  @override
  String get zReport => 'Shift report';

  @override
  String get cashSales => 'Cash sales';

  @override
  String get cardSales => 'Card sales';

  @override
  String get transferSales => 'Mobile money and transfers';

  @override
  String get debtCollected => 'Debt collected in cash';

  @override
  String get expectedCash => 'Cash that should be in the drawer';

  @override
  String get countedCash => 'Cash counted';

  @override
  String get variance => 'Difference';

  @override
  String get card => 'Card';

  @override
  String get transfer => 'Transfer';

  @override
  String get addPayment => 'Add payment';

  @override
  String get remaining => 'Still to pay';

  @override
  String shiftClosed(String variance) {
    return 'Shift closed. Difference: $variance';
  }

  @override
  String get errShiftNotOpen =>
      'Open a shift first: sales go into an open shift of yours.';

  @override
  String get errShiftAlreadyOpen => 'You already have an open shift here.';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get paySupplier => 'Pay supplier';

  @override
  String get addSupplier => 'Add supplier';

  @override
  String get supplierName => 'Supplier name';

  @override
  String get noSuppliers => 'No suppliers yet';

  @override
  String get paidToSuppliers => 'Paid to suppliers in cash';

  @override
  String get productActive => 'Active: offered for sale';

  @override
  String get barcodes => 'Barcodes';

  @override
  String get addBarcode => 'Add barcode';

  @override
  String get removeBarcode => 'Remove barcode';

  @override
  String get errBarcodeTaken =>
      'This barcode is already on another product. Remove it there first.';

  @override
  String get errSupplierOverpayment =>
      'That is more than the shop owes this supplier.';

  @override
  String get errNotStockTracked => 'This product\'s stock is not tracked.';

  @override
  String get recentSales => 'Recent sales';

  @override
  String get noRecentSales => 'No sales yet';

  @override
  String get receivedOk => 'Received into stock';

  @override
  String get drawerFailed =>
      'The receipt printed, but the cash drawer did not open.';

  @override
  String get searchCustomer => 'Search customers';

  @override
  String get paid => 'Paid';

  @override
  String get voided => 'Voided';

  @override
  String get voidSale => 'Void sale';

  @override
  String get voidSaleTitle => 'Void this sale?';

  @override
  String get voidSaleBody =>
      'The stock comes back, and what the customer still owes for it is taken off their account. This can\'t be undone.';

  @override
  String get voidReason => 'Reason';

  @override
  String get saleVoidedOk => 'The sale was voided.';

  @override
  String get returnItems => 'Return items';

  @override
  String get returnTitle => 'Take goods back';

  @override
  String returnUpTo(String qty) {
    return 'Up to $qty';
  }

  @override
  String get returnPayBack => 'Pay back by';

  @override
  String returnWorth(String amount) {
    return 'Worth $amount';
  }

  @override
  String get returnConfirm => 'Take back';

  @override
  String returnDoneGiveBack(String amount) {
    return 'Returned. Give back $amount.';
  }

  @override
  String get returnDoneAccount =>
      'Returned. It came off the customer\'s account.';

  @override
  String get returnNothingLeft =>
      'Everything from this sale has come back already.';

  @override
  String get returnLabel => 'Return';

  @override
  String returnOf(String number) {
    return 'Return of $number';
  }

  @override
  String get errRefundQty => 'That is more than is left to take back.';

  @override
  String get errSaleNotRefundable =>
      'Goods can\'t be taken back from this sale.';

  @override
  String get errRefundReason => 'Write why the goods come back.';

  @override
  String get errSaleNotSynced =>
      'This sale hasn\'t reached the server yet. Sync, then try again.';

  @override
  String get errVoidReasonRequired => 'Write why the sale is being voided.';

  @override
  String get errVoidShiftClosed =>
      'This sale\'s shift is already closed and the sale took cash, so it can\'t be voided. Take the goods back with Return items instead.';

  @override
  String get language => 'Language';

  @override
  String get errSessionEnded =>
      'Your access has changed or ended. Sign in again.';

  @override
  String get biometricUnlockSetting => 'Unlock with fingerprint';

  @override
  String get idleLockSetting => 'Lock when idle for';

  @override
  String idleLockMinutes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString minutes',
      one: '$countString minute',
    );
    return '$_temp0';
  }

  @override
  String get idleLockManagersOnly =>
      'Only an owner or a manager can change this.';

  @override
  String get confirmPasswordTitle => 'Confirm your password';

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
  String get syncIssuesTitle => 'Sync issues';

  @override
  String get syncIssuesReview => 'Review';

  @override
  String get syncIssueConflict =>
      'changed elsewhere first; that change was kept';

  @override
  String get syncIssueRejected => 'the server did not accept this change';

  @override
  String get syncIssueRetry => 'Apply again';

  @override
  String get syncIssueDismiss => 'Set aside';

  @override
  String get syncIssuesEmpty => 'Nothing to review.';

  @override
  String get errUnitUnknown =>
      'This product\'s unit isn\'t loaded yet. Sync, then try again.';

  @override
  String get editQuantity => 'Change quantity';

  @override
  String get errAmountInvalid => 'Enter an amount such as 250 or 250.50.';

  @override
  String get errQtyInvalid => 'Enter a quantity such as 3 or 2.5.';

  @override
  String get errQtyPrecision =>
      'This unit does not take that many decimal places.';

  @override
  String get errMustBePositive => 'Enter a number greater than zero.';

  @override
  String get errChooseProduct => 'Choose a product.';

  @override
  String get errRequired => 'Required.';

  @override
  String get errTooLong => 'Too long.';

  @override
  String get quantityReceived => 'Quantity received';

  @override
  String get savedOk => 'Saved.';

  @override
  String get settings => 'Settings';

  @override
  String get printerSettings => 'Receipt printer';

  @override
  String get paperWidth => 'Paper width';

  @override
  String paperMillimetres(int mm) {
    final intl.NumberFormat mmNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String mmString = mmNumberFormat.format(mm);

    return '$mmString mm';
  }

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
  String insightDeadStock(String product, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$product hasn\'t sold in $daysString days',
      one: '$product hasn\'t sold in $daysString day',
    );
    return '$_temp0';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer is near their credit limit';
  }

  @override
  String insightDigest(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString sales today',
      one: '$countString sale today',
    );
    return '$_temp0';
  }

  @override
  String get insightUnknown => 'New insight';

  @override
  String get auditLog => 'Audit log';

  @override
  String get noAuditEntries => 'No activity recorded yet';

  @override
  String get errSaleEmpty => 'Add an item first.';

  @override
  String get errUnderpaid => 'The payment is less than the total.';

  @override
  String get errOverpaid => 'The payment is more than the total.';

  @override
  String get errDiscountInvalid =>
      'The discount can\'t be below zero or more than the total.';

  @override
  String get errSaleNotVoidable => 'This sale can\'t be voided.';

  @override
  String get errStockInsufficient => 'Not enough stock for this sale.';

  @override
  String get errShiftAlreadyClosed => 'This shift is already closed.';

  @override
  String get errCurrencyMismatch => 'The currencies don\'t match.';

  @override
  String get errBranchInactive => 'This branch is closed.';

  @override
  String get errUserLastAssignment => 'This is the employee\'s only branch.';

  @override
  String get errWeakPassword => 'This password is too short or too simple.';

  @override
  String get errNotFound => 'This no longer exists. Refresh and try again.';

  @override
  String get errConflict =>
      'Someone else changed this meanwhile. Refresh and try again.';

  @override
  String get errInvalid =>
      'Some values weren\'t accepted. Check them and try again.';

  @override
  String get biometricReason => 'Confirm it\'s you to unlock DukanPro';

  @override
  String get unitPiece => 'piece';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLitre => 'litre';

  @override
  String get unitDozen => 'dozen';

  @override
  String get unitMeter => 'meter';

  @override
  String get timeZoneKabul => 'Kabul time';

  @override
  String get currencyAfn => 'Afghani';

  @override
  String get currencyUsd => 'US dollar';

  @override
  String get currencyPkr => 'Pakistani rupee';

  @override
  String get currencyEur => 'Euro';

  @override
  String get auditSystem => 'System';

  @override
  String get auditOther => 'Other activity';

  @override
  String branchRole(String branch, String role) {
    return '$branch · $role';
  }

  @override
  String branchZoneCurrency(String zone, String currency) {
    return '$zone · $currency';
  }

  @override
  String auditBy(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get auditBarcodeAdded => 'Barcode added';

  @override
  String get auditBarcodeRemoved => 'Barcode removed';

  @override
  String get auditBranchActivated => 'Branch reopened';

  @override
  String get auditBranchCreated => 'Branch opened';

  @override
  String get auditBranchDeactivated => 'Branch closed';

  @override
  String get auditBranchUpdated => 'Branch changed';

  @override
  String get auditCostValuationChanged => 'Stock cost updated';

  @override
  String get auditCustomerCreated => 'Customer added';

  @override
  String get auditCustomerCreditLimitChanged => 'Credit limit changed';

  @override
  String get auditCustomerDeactivated => 'Customer account closed';

  @override
  String get auditCustomerReactivated => 'Customer account reopened';

  @override
  String get auditCustomerUpdated => 'Customer changed';

  @override
  String get auditDebtChargePosted => 'Sale on credit';

  @override
  String get auditDebtPaymentRecorded => 'Debt payment received';

  @override
  String get auditDebtWrittenOff => 'Debt written off';

  @override
  String get auditDiscountApplied => 'Discount given';

  @override
  String get auditNotificationsRefreshed => 'Insights refreshed';

  @override
  String get auditOwnerBootstrapped => 'Shop set up';

  @override
  String get auditPasswordReset => 'Password reset';

  @override
  String get auditPaymentRecorded => 'Payment recorded';

  @override
  String get auditProductCreated => 'Product added';

  @override
  String get auditProductDeactivated => 'Product deactivated';

  @override
  String get auditProductPriceChanged => 'Price changed';

  @override
  String get auditProductUpdated => 'Product changed';

  @override
  String get auditPurchaseReceived => 'Goods received';

  @override
  String get auditRoleAssigned => 'Role granted';

  @override
  String get auditRoleRevoked => 'Role removed';

  @override
  String get auditSaleLineAdded => 'Item added to a sale';

  @override
  String get auditSaleSettled => 'Sale completed';

  @override
  String get auditSaleVoided => 'Sale voided';

  @override
  String get auditSessionReuseDetected => 'Suspicious sign-in blocked';

  @override
  String get auditShiftClosed => 'Shift closed';

  @override
  String get auditShiftOpened => 'Shift opened';

  @override
  String get auditStockAdjusted => 'Stock adjusted';

  @override
  String get auditStockReceived => 'Stock received';

  @override
  String get auditStockSold => 'Stock sold';

  @override
  String get auditSupplierBillPosted => 'Supplier bill recorded';

  @override
  String get auditSupplierCreated => 'Supplier added';

  @override
  String get auditSupplierPaymentRecorded => 'Supplier paid';

  @override
  String get auditSyncPull => 'Device synced';

  @override
  String get auditUnitCreated => 'Unit added';

  @override
  String get auditUserAuthenticated => 'Signed in';

  @override
  String get auditUserCreated => 'Employee added';

  @override
  String get auditUserDisabled => 'Employee disabled';

  @override
  String get auditUserEnabled => 'Employee enabled';

  @override
  String get auditUserLoginFailed => 'Failed sign-in';

  @override
  String get auditUserLogout => 'Signed out';

  @override
  String get solarMonth1 => 'Hamal';

  @override
  String get solarMonth2 => 'Sawr';

  @override
  String get solarMonth3 => 'Jawza';

  @override
  String get solarMonth4 => 'Saratan';

  @override
  String get solarMonth5 => 'Asad';

  @override
  String get solarMonth6 => 'Sunbula';

  @override
  String get solarMonth7 => 'Mizan';

  @override
  String get solarMonth8 => 'Aqrab';

  @override
  String get solarMonth9 => 'Qaws';

  @override
  String get solarMonth10 => 'Jadi';

  @override
  String get solarMonth11 => 'Dalw';

  @override
  String get solarMonth12 => 'Hut';

  @override
  String solarDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String dateAndTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String get symbolAfn => 'AFN';

  @override
  String get symbolUsd => 'USD';

  @override
  String get symbolPkr => 'PKR';

  @override
  String get symbolEur => 'EUR';

  @override
  String moneyAmount(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String get shift => 'Shift';

  @override
  String get category => 'Category';

  @override
  String get syncIssueOther => 'Other data';

  @override
  String get errAccountDisabled =>
      'This account is disabled. Ask the shop\'s owner.';

  @override
  String get timeZoneKarachi => 'Karachi time';

  @override
  String get timeZoneTashkent => 'Tashkent time';

  @override
  String get timeZoneDushanbe => 'Dushanbe time';

  @override
  String get timeZoneDubai => 'Dubai time';

  @override
  String get timeZoneTehran => 'Tehran time';

  @override
  String get timeZoneUtc => 'UTC';
}
