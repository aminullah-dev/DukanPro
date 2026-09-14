import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ps.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('fa', 'AF'),
    Locale('ps'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'DukanPro'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first retail POS'**
  String get tagline;

  /// No description provided for @posTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get posTitle;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New sale'**
  String get newSale;

  /// No description provided for @itemsInCart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsInCart(int count);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get displayName;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopName;

  /// No description provided for @firstRunSetup.
  ///
  /// In en, this message translates to:
  /// **'First time? Set up your shop'**
  String get firstRunSetup;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @usePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get useBiometric;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineMode;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Check your username and password.'**
  String get loginFailed;

  /// No description provided for @wrongSecret.
  ///
  /// In en, this message translates to:
  /// **'Incorrect — try again.'**
  String get wrongSecret;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Make sure it\'s running, then try again.'**
  String get errNetwork;

  /// No description provided for @errBootstrapDone.
  ///
  /// In en, this message translates to:
  /// **'This server already has a shop set up. Sign in instead.'**
  String get errBootstrapDone;

  /// No description provided for @setupFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup failed. Please try again.'**
  String get setupFailed;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get productName;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @barcodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcodeLabel;

  /// No description provided for @trackStock.
  ///
  /// In en, this message translates to:
  /// **'Track stock'**
  String get trackStock;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get adjustStock;

  /// No description provided for @quantityDelta.
  ///
  /// In en, this message translates to:
  /// **'Quantity (+/-)'**
  String get quantityDelta;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @onHand.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get onHand;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProducts;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search or scan…'**
  String get searchHint;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this.'**
  String get permissionDenied;

  /// No description provided for @skuTaken.
  ///
  /// In en, this message translates to:
  /// **'This SKU is already used.'**
  String get skuTaken;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'Point of sale'**
  String get pos;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get emptyCart;

  /// No description provided for @tendered.
  ///
  /// In en, this message translates to:
  /// **'Cash received'**
  String get tendered;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get addCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customerName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @creditLimit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get creditLimit;

  /// No description provided for @setCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'Set credit limit'**
  String get setCreditLimit;

  /// No description provided for @creditLimitHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no limit'**
  String get creditLimitHelp;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get recordPayment;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @receiveStock.
  ///
  /// In en, this message translates to:
  /// **'Receive stock'**
  String get receiveStock;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @unitCost.
  ///
  /// In en, this message translates to:
  /// **'Unit cost'**
  String get unitCost;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomers;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @salesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get salesToday;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @outstandingDebt.
  ///
  /// In en, this message translates to:
  /// **'Outstanding debt'**
  String get outstandingDebt;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get lowStock;

  /// No description provided for @topSellers.
  ///
  /// In en, this message translates to:
  /// **'Top sellers'**
  String get topSellers;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {user}'**
  String signedInAs(String user);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncUpToDate;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All changes synced} =1{1 change to sync} other{{count} changes to sync}}'**
  String syncPending(int count);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync. Check your connection and try again.'**
  String get syncFailed;

  /// No description provided for @syncConflicts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item needs review} other{{count} items need review}}'**
  String syncConflicts(int count);

  /// No description provided for @syncRejected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change was rejected by the server} other{{count} changes were rejected by the server}}'**
  String syncRejected(int count);

  /// No description provided for @setupCode.
  ///
  /// In en, this message translates to:
  /// **'Setup code'**
  String get setupCode;

  /// No description provided for @setupCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Shown in the server console when the server starts'**
  String get setupCodeHelp;

  /// No description provided for @errSetupCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong setup code. Check the server console.'**
  String get errSetupCode;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Signing out removes the saved sign-in from this device. Until someone signs in online again, nobody can sell here.'**
  String get logoutConfirmBody;

  /// No description provided for @logoutPendingWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change is not synced yet.} other{{count} changes are not synced yet.}}'**
  String logoutPendingWarning(int count);

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @backToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backToUnlock;

  /// No description provided for @errOfflineExpired.
  ///
  /// In en, this message translates to:
  /// **'This device has been offline too long. Sign in online.'**
  String get errOfflineExpired;

  /// No description provided for @errStorage.
  ///
  /// In en, this message translates to:
  /// **'This device\'s secure storage could not be read. Sign in again; if it keeps happening, restart the device.'**
  String get errStorage;

  /// No description provided for @errTotalTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This total is too large to record. Check the quantity and price.'**
  String get errTotalTooLarge;

  /// No description provided for @errSessionEndedUnlock.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Enter your password: the app keeps working offline and signs in again when it is online.'**
  String get errSessionEndedUnlock;

  /// No description provided for @cashNow.
  ///
  /// In en, this message translates to:
  /// **'Cash now'**
  String get cashNow;

  /// No description provided for @onCredit.
  ///
  /// In en, this message translates to:
  /// **'On credit'**
  String get onCredit;

  /// No description provided for @deactivateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Close account'**
  String get deactivateCustomer;

  /// No description provided for @reactivateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Reopen account'**
  String get reactivateCustomer;

  /// No description provided for @customerInactive.
  ///
  /// In en, this message translates to:
  /// **'Account closed: no credit'**
  String get customerInactive;

  /// No description provided for @writeOffDebt.
  ///
  /// In en, this message translates to:
  /// **'Write off debt'**
  String get writeOffDebt;

  /// No description provided for @profitMissingCost.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item sold without a cost} other{{count} items sold without a cost}}'**
  String profitMissingCost(int count);

  /// No description provided for @errCustomerInactive.
  ///
  /// In en, this message translates to:
  /// **'This customer\'s account is closed: no credit.'**
  String get errCustomerInactive;

  /// No description provided for @errDebtCurrency.
  ///
  /// In en, this message translates to:
  /// **'This customer\'s debt is in another currency; credit is given only in their currency.'**
  String get errDebtCurrency;

  /// No description provided for @errOverCreditLimit.
  ///
  /// In en, this message translates to:
  /// **'This sale would take the customer over their credit limit.'**
  String get errOverCreditLimit;

  /// No description provided for @errDebtOverpayment.
  ///
  /// In en, this message translates to:
  /// **'That is more than the customer owes.'**
  String get errDebtOverpayment;

  /// No description provided for @errWriteOffTooMuch.
  ///
  /// In en, this message translates to:
  /// **'You can write off at most what the customer owes.'**
  String get errWriteOffTooMuch;

  /// No description provided for @openShift.
  ///
  /// In en, this message translates to:
  /// **'Open shift'**
  String get openShift;

  /// No description provided for @closeShift.
  ///
  /// In en, this message translates to:
  /// **'Close shift'**
  String get closeShift;

  /// No description provided for @openingFloat.
  ///
  /// In en, this message translates to:
  /// **'Cash in the drawer to start'**
  String get openingFloat;

  /// No description provided for @openShiftPrompt.
  ///
  /// In en, this message translates to:
  /// **'Open your shift to start selling. Count the cash already in the drawer.'**
  String get openShiftPrompt;

  /// No description provided for @zReport.
  ///
  /// In en, this message translates to:
  /// **'Shift report'**
  String get zReport;

  /// No description provided for @cashSales.
  ///
  /// In en, this message translates to:
  /// **'Cash sales'**
  String get cashSales;

  /// No description provided for @cardSales.
  ///
  /// In en, this message translates to:
  /// **'Card sales'**
  String get cardSales;

  /// No description provided for @transferSales.
  ///
  /// In en, this message translates to:
  /// **'Mobile money and transfers'**
  String get transferSales;

  /// No description provided for @debtCollected.
  ///
  /// In en, this message translates to:
  /// **'Debt collected in cash'**
  String get debtCollected;

  /// No description provided for @expectedCash.
  ///
  /// In en, this message translates to:
  /// **'Cash that should be in the drawer'**
  String get expectedCash;

  /// No description provided for @countedCash.
  ///
  /// In en, this message translates to:
  /// **'Cash counted'**
  String get countedCash;

  /// No description provided for @variance.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get variance;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add payment'**
  String get addPayment;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Still to pay'**
  String get remaining;

  /// No description provided for @shiftClosed.
  ///
  /// In en, this message translates to:
  /// **'Shift closed. Difference: {variance} AFN'**
  String shiftClosed(String variance);

  /// No description provided for @errShiftNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Open a shift first: sales go into an open shift of yours.'**
  String get errShiftNotOpen;

  /// No description provided for @errShiftAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'You already have an open shift here.'**
  String get errShiftAlreadyOpen;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @paySupplier.
  ///
  /// In en, this message translates to:
  /// **'Pay supplier'**
  String get paySupplier;

  /// No description provided for @addSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add supplier'**
  String get addSupplier;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get supplierName;

  /// No description provided for @noSuppliers.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get noSuppliers;

  /// No description provided for @paidToSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Paid to suppliers in cash'**
  String get paidToSuppliers;

  /// No description provided for @productActive.
  ///
  /// In en, this message translates to:
  /// **'Active: offered for sale'**
  String get productActive;

  /// No description provided for @barcodes.
  ///
  /// In en, this message translates to:
  /// **'Barcodes'**
  String get barcodes;

  /// No description provided for @addBarcode.
  ///
  /// In en, this message translates to:
  /// **'Add barcode'**
  String get addBarcode;

  /// No description provided for @removeBarcode.
  ///
  /// In en, this message translates to:
  /// **'Remove barcode'**
  String get removeBarcode;

  /// No description provided for @errBarcodeTaken.
  ///
  /// In en, this message translates to:
  /// **'This barcode is already on another product. Remove it there first.'**
  String get errBarcodeTaken;

  /// No description provided for @errSupplierOverpayment.
  ///
  /// In en, this message translates to:
  /// **'That is more than the shop owes this supplier.'**
  String get errSupplierOverpayment;

  /// No description provided for @errNotStockTracked.
  ///
  /// In en, this message translates to:
  /// **'This product\'s stock is not tracked.'**
  String get errNotStockTracked;

  /// No description provided for @errSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your access has changed or ended. Sign in again.'**
  String get errSessionEnded;

  /// No description provided for @biometricUnlockSetting.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint'**
  String get biometricUnlockSetting;

  /// No description provided for @confirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordTitle;

  /// No description provided for @lastSyncedAt.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String lastSyncedAt(String time);

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployee;

  /// No description provided for @noEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get noEmployees;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statusDisabled;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @assignRole.
  ///
  /// In en, this message translates to:
  /// **'Assign role'**
  String get assignRole;

  /// No description provided for @removeRole.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeRole;

  /// No description provided for @branches.
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branches;

  /// No description provided for @addBranch.
  ///
  /// In en, this message translates to:
  /// **'Add branch'**
  String get addBranch;

  /// No description provided for @noBranches.
  ///
  /// In en, this message translates to:
  /// **'No branches yet'**
  String get noBranches;

  /// No description provided for @branchNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get branchNameLabel;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleCashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get roleCashier;

  /// No description provided for @roleStockKeeper.
  ///
  /// In en, this message translates to:
  /// **'Stock keeper'**
  String get roleStockKeeper;

  /// No description provided for @roleAccountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get roleAccountant;

  /// No description provided for @errUserLastOwner.
  ///
  /// In en, this message translates to:
  /// **'You can\'t disable the last owner.'**
  String get errUserLastOwner;

  /// No description provided for @errBranchLastActive.
  ///
  /// In en, this message translates to:
  /// **'You can\'t deactivate the only active branch.'**
  String get errBranchLastActive;

  /// No description provided for @errUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get errUsernameTaken;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @syncIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync issues'**
  String get syncIssuesTitle;

  /// No description provided for @syncIssuesReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get syncIssuesReview;

  /// No description provided for @syncIssueConflict.
  ///
  /// In en, this message translates to:
  /// **'changed elsewhere first; that change was kept'**
  String get syncIssueConflict;

  /// No description provided for @syncIssueRejected.
  ///
  /// In en, this message translates to:
  /// **'the server did not accept this change'**
  String get syncIssueRejected;

  /// No description provided for @syncIssueRetry.
  ///
  /// In en, this message translates to:
  /// **'Apply again'**
  String get syncIssueRetry;

  /// No description provided for @syncIssueDismiss.
  ///
  /// In en, this message translates to:
  /// **'Set aside'**
  String get syncIssueDismiss;

  /// No description provided for @syncIssuesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review.'**
  String get syncIssuesEmpty;

  /// No description provided for @errUnitUnknown.
  ///
  /// In en, this message translates to:
  /// **'This product\'s unit isn\'t loaded yet. Sync, then try again.'**
  String get errUnitUnknown;

  /// No description provided for @editQuantity.
  ///
  /// In en, this message translates to:
  /// **'Change quantity'**
  String get editQuantity;

  /// No description provided for @errAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount such as 250 or 250.50.'**
  String get errAmountInvalid;

  /// No description provided for @errQtyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity such as 3 or 2.5.'**
  String get errQtyInvalid;

  /// No description provided for @errQtyPrecision.
  ///
  /// In en, this message translates to:
  /// **'This unit does not take that many decimal places.'**
  String get errQtyPrecision;

  /// No description provided for @errMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than zero.'**
  String get errMustBePositive;

  /// No description provided for @errChooseProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose a product.'**
  String get errChooseProduct;

  /// No description provided for @errRequired.
  ///
  /// In en, this message translates to:
  /// **'Required.'**
  String get errRequired;

  /// No description provided for @errTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long.'**
  String get errTooLong;

  /// No description provided for @quantityReceived.
  ///
  /// In en, this message translates to:
  /// **'Quantity received'**
  String get quantityReceived;

  /// No description provided for @savedOk.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get savedOk;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @printerSettings.
  ///
  /// In en, this message translates to:
  /// **'Receipt printer'**
  String get printerSettings;

  /// No description provided for @enablePrinting.
  ///
  /// In en, this message translates to:
  /// **'Print receipts'**
  String get enablePrinting;

  /// No description provided for @printerHost.
  ///
  /// In en, this message translates to:
  /// **'Printer IP address'**
  String get printerHost;

  /// No description provided for @printerPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get printerPort;

  /// No description provided for @testPrint.
  ///
  /// In en, this message translates to:
  /// **'Test print'**
  String get testPrint;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printReceipt;

  /// No description provided for @printerNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'No printer configured. Set one up in Settings.'**
  String get printerNotConfigured;

  /// No description provided for @printSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Sent to printer.'**
  String get printSucceeded;

  /// No description provided for @printFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the printer.'**
  String get printFailed;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get noNotifications;

  /// No description provided for @refreshInsights.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshInsights;

  /// No description provided for @markReadAction.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markReadAction;

  /// No description provided for @insightReorder.
  ///
  /// In en, this message translates to:
  /// **'Restock {product} — running low'**
  String insightReorder(String product);

  /// No description provided for @insightDeadStock.
  ///
  /// In en, this message translates to:
  /// **'{product} hasn\'t sold in {days} days'**
  String insightDeadStock(String product, String days);

  /// No description provided for @insightDebtRisk.
  ///
  /// In en, this message translates to:
  /// **'{customer} is near their credit limit'**
  String insightDebtRisk(String customer);

  /// No description provided for @insightDigest.
  ///
  /// In en, this message translates to:
  /// **'{count} sales today'**
  String insightDigest(String count);

  /// No description provided for @insightUnknown.
  ///
  /// In en, this message translates to:
  /// **'New insight'**
  String get insightUnknown;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @noAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet'**
  String get noAuditEntries;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa', 'ps'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'fa':
      {
        switch (locale.countryCode) {
          case 'AF':
            return AppLocalizationsFaAf();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ps':
      return AppLocalizationsPs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
