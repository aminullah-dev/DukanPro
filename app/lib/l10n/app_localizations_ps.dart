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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString توکي',
      one: '$countString توکی',
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
  String get errNetwork =>
      'سرور ته لاسرسی ونشو. ډاډ ترلاسه کړئ چې چلیږي، بیا هڅه وکړئ.';

  @override
  String get errBootstrapDone =>
      'دا سرور له مخکې دوکان لري. مهرباني وکړئ ننوځئ.';

  @override
  String get setupFailed => 'چمتو کول ناکام شول. بیا هڅه وکړئ.';

  @override
  String get products => 'محصولات';

  @override
  String get addProduct => 'محصول اضافه کول';

  @override
  String get editProduct => 'محصول سمول';

  @override
  String get productName => 'نوم';

  @override
  String get sku => 'د توکي کوډ';

  @override
  String get price => 'بیه';

  @override
  String get unit => 'واحد';

  @override
  String get barcodeLabel => 'بارکوډ';

  @override
  String get trackStock => 'د ذخیرې تعقیب';

  @override
  String get adjustStock => 'ذخیره سمول';

  @override
  String get quantityDelta => 'اندازه (+/-)';

  @override
  String get save => 'ساتل';

  @override
  String get cancel => 'لغوه';

  @override
  String get onHand => 'موجود';

  @override
  String get noProducts => 'لا تر اوسه محصول نشته';

  @override
  String get searchHint => 'لټون یا سکن…';

  @override
  String get permissionDenied => 'تاسو د دې اجازه نه لرئ.';

  @override
  String get skuTaken => 'دا کوډ دمخه کارول شوی دی.';

  @override
  String get pos => 'د پلور صندوق';

  @override
  String get cartTitle => 'ټوکرۍ';

  @override
  String get emptyCart => 'ټوکرۍ خالي ده';

  @override
  String get tendered => 'ترلاسه شوي نغدي';

  @override
  String get change => 'بیرته';

  @override
  String get receipt => 'رسید';

  @override
  String get customers => 'پیرودونکي';

  @override
  String get addCustomer => 'پیرودونکی اضافه کول';

  @override
  String get customerName => 'نوم';

  @override
  String get phone => 'تلیفون';

  @override
  String get creditLimit => 'د پور حد';

  @override
  String get setCreditLimit => 'د پور حد ټاکل';

  @override
  String get creditLimitHelp => 'د بې حده لپاره یې خالي پرېږدئ';

  @override
  String get recordPayment => 'د تادیې ثبت';

  @override
  String get amount => 'اندازه';

  @override
  String get balance => 'بیلانس';

  @override
  String get credit => 'پور';

  @override
  String get receiveStock => 'توکي ترلاسه کول';

  @override
  String get supplier => 'عرضه‌کوونکی';

  @override
  String get unitCost => 'د پیرود بیه';

  @override
  String get receive => 'ترلاسه کول';

  @override
  String get noCustomers => 'لا تر اوسه پیرودونکی نشته';

  @override
  String get dashboard => 'ډشبورډ';

  @override
  String get salesToday => 'د نن پلور';

  @override
  String get profit => 'ګټه';

  @override
  String get outstandingDebt => 'پاتې پورونه';

  @override
  String get lowStock => 'کمه ذخیره';

  @override
  String get topSellers => 'ډیر پلورل شوي';

  @override
  String signedInAs(String user) {
    return 'د $user په توګه ننوتل';
  }

  @override
  String get syncNow => 'همغږي کول';

  @override
  String get syncing => 'همغږي کیږي…';

  @override
  String get syncUpToDate => 'تازه دی';

  @override
  String syncPending(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString بدلونونه د لیږلو لپاره',
      one: '$countString بدلون د لیږلو لپاره',
      zero: 'ټول بدلونونه همغږي شوي',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed => 'همغږي ونشوه. خپل پیوستون وګورئ او بیا هڅه وکړئ.';

  @override
  String syncConflicts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString توکي بیاکتنې ته اړتیا لري',
      one: '$countString توکی بیاکتنې ته اړتیا لري',
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
      other: '$countString بدلونونه د سرور له خوا رد شول',
      one: '$countString بدلون د سرور له خوا رد شو',
    );
    return '$_temp0';
  }

  @override
  String get setupCode => 'د تنظیم کوډ';

  @override
  String get setupCodeHelp =>
      'کله چې سرور پیلېږي، د سرور په کنسول کې ښودل کېږي';

  @override
  String get errSetupCode => 'د تنظیم کوډ سم نه دی. د سرور کنسول وګورئ.';

  @override
  String get lock => 'قلف';

  @override
  String get logoutConfirmTitle => 'له دې وسیلې وځئ؟';

  @override
  String get logoutConfirmBody =>
      'په وتلو سره، د ننوتلو ساتل شوي معلومات له دې وسیلې پاکېږي. تر هغه چې څوک بیا آنلاین ننوځي، هیڅوک دلته پلور نشي کولی.';

  @override
  String logoutPendingWarning(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString بدلونونه لا نه دي همغږي شوي.',
      one: '$countString بدلون لا نه دی همغږی شوی.',
    );
    return '$_temp0';
  }

  @override
  String get useAnotherAccount => 'له بل حساب سره ننوتل';

  @override
  String get backToUnlock => 'بېرته';

  @override
  String get errOfflineExpired => 'دا وسیله ډېره موده آفلاین وه. آنلاین ننوځئ.';

  @override
  String get errStorage =>
      'د دې وسیلې خوندي حافظه ونه لوستل شوه. بیا ننوځئ؛ که بیا پېښ شو، وسیله بیا چالانه کړئ.';

  @override
  String get errTotalTooLarge =>
      'دا ټولټال د ثبتولو لپاره ډېر لوی دی. شمېر او بیه وګورئ.';

  @override
  String get errSessionEndedUnlock =>
      'ستاسو ناسته پای ته ورسېده. خپل پټنوم ولیکئ: اپ له انټرنېټ پرته هم کار کوي او کله چې آنلاین شي بیا ننوځي.';

  @override
  String get cashNow => 'همدا اوس نغدي';

  @override
  String get onCredit => 'په پور';

  @override
  String get deactivateCustomer => 'حساب بندول';

  @override
  String get reactivateCustomer => 'حساب بیا پرانیستل';

  @override
  String get customerInactive => 'حساب بند: پور نشته';

  @override
  String get writeOffDebt => 'پور بښل';

  @override
  String profitMissingCost(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString توکي د پېر بیې پرته پلورل شوي',
    );
    return '$_temp0';
  }

  @override
  String get errCustomerInactive =>
      'د دې پېرودونکي حساب بند دی: پور نه ورکول کېږي.';

  @override
  String get errDebtCurrency =>
      'د دې پېرودونکي پور په بله اسعارو دی؛ پور یوازې د هغه په اسعارو ورکول کېږي.';

  @override
  String get errOverCreditLimit =>
      'دا پلور به د پېرودونکي د پور له حد څخه واوړي.';

  @override
  String get errDebtOverpayment => 'دا مبلغ د پېرودونکي له پور څخه زیات دی.';

  @override
  String get errWriteOffTooMuch =>
      'تر ټولو زیات د پېرودونکي د پور په اندازه بښل کېدای شي.';

  @override
  String get openShift => 'شفټ پیلول';

  @override
  String get closeShift => 'شفټ بندول';

  @override
  String get openingFloat => 'د صندوق د پیل نغدې پیسې';

  @override
  String get openShiftPrompt =>
      'د پلور د پیل لپاره خپل شفټ پیل کړئ. هغه نغدې پیسې وشمېرئ چې اوس په صندوق کې دي.';

  @override
  String get zReport => 'د شفټ راپور';

  @override
  String get cashSales => 'نغدي پلور';

  @override
  String get cardSales => 'د کارت پلور';

  @override
  String get transferSales => 'موبایلي پیسې او لېږد';

  @override
  String get debtCollected => 'په نغدو راټول شوی پور';

  @override
  String get expectedCash => 'هغه نغدې پیسې چې باید په صندوق کې وي';

  @override
  String get countedCash => 'شمېرل شوې نغدې پیسې';

  @override
  String get variance => 'توپیر';

  @override
  String get card => 'کارت';

  @override
  String get transfer => 'لېږد';

  @override
  String get addPayment => 'تادیه زیاته کړئ';

  @override
  String get remaining => 'پاتې';

  @override
  String shiftClosed(String variance) {
    return 'شفټ بند شو. توپیر: $variance افغانۍ';
  }

  @override
  String get errShiftNotOpen =>
      'لومړی خپل شفټ پیل کړئ؛ پلور ستاسو په پرانیستي شفټ کې ثبتېږي.';

  @override
  String get errShiftAlreadyOpen => 'تاسو دلته دمخه یو پرانیستی شفټ لرئ.';

  @override
  String get suppliers => 'عرضه کوونکي';

  @override
  String get paySupplier => 'عرضه کوونکي ته تادیه';

  @override
  String get addSupplier => 'عرضه کوونکی زیاتول';

  @override
  String get supplierName => 'د عرضه کوونکي نوم';

  @override
  String get noSuppliers => 'تر اوسه عرضه کوونکی نشته';

  @override
  String get paidToSuppliers => 'عرضه کوونکو ته نغدي تادیه';

  @override
  String get productActive => 'فعال (د پلور وړ)';

  @override
  String get barcodes => 'بارکوډونه';

  @override
  String get addBarcode => 'بارکوډ زیاتول';

  @override
  String get removeBarcode => 'بارکوډ لرې کول';

  @override
  String get errBarcodeTaken =>
      'دا بارکوډ په بل توکي ثبت دی. لومړی یې له هغه ځایه لرې کړئ.';

  @override
  String get errSupplierOverpayment =>
      'دا مبلغ د دې عرضه کوونکي له پور څخه زیات دی.';

  @override
  String get errNotStockTracked => 'د دې توکي زېرمه نه څارل کېږي.';

  @override
  String get recentSales => 'وروستي پلورونه';

  @override
  String get noRecentSales => 'تر اوسه پلور نشته';

  @override
  String get receivedOk => 'زېرمې ته ور زیات شو';

  @override
  String get drawerFailed => 'رسید چاپ شو، خو د پیسو صندوق خلاص نه شو.';

  @override
  String get searchCustomer => 'پېرودونکی ولټوئ';

  @override
  String get paid => 'تادیه شوي';

  @override
  String get voided => 'باطل شوی';

  @override
  String get language => 'ژبه';

  @override
  String get errSessionEnded =>
      'ستاسو لاسرسی بدل شوی یا پای ته رسېدلی دی. بیا ننوځئ.';

  @override
  String get biometricUnlockSetting => 'د ګوتې په نښه خلاصول';

  @override
  String get confirmPasswordTitle => 'خپل پټنوم تایید کړئ';

  @override
  String lastSyncedAt(String time) {
    return 'وروستۍ همغږي $time';
  }

  @override
  String get employees => 'کارمندان';

  @override
  String get addEmployee => 'کارمند زیاتول';

  @override
  String get noEmployees => 'لا تر اوسه کارمند نشته';

  @override
  String get role => 'رول';

  @override
  String get enable => 'فعالول';

  @override
  String get disable => 'غیرفعالول';

  @override
  String get statusActive => 'فعال';

  @override
  String get statusDisabled => 'غیرفعال';

  @override
  String get resetPassword => 'پټنوم بیا تنظیمول';

  @override
  String get newPassword => 'نوی پټنوم';

  @override
  String get assignRole => 'رول ټاکل';

  @override
  String get removeRole => 'لرې کول';

  @override
  String get branches => 'څانګې';

  @override
  String get addBranch => 'څانګه زیاتول';

  @override
  String get noBranches => 'لا تر اوسه څانګه نشته';

  @override
  String get branchNameLabel => 'د څانګې نوم';

  @override
  String get rename => 'نوم بدلول';

  @override
  String get activate => 'فعالول';

  @override
  String get deactivate => 'غیرفعالول';

  @override
  String get roleOwner => 'مالک';

  @override
  String get roleManager => 'مدیر';

  @override
  String get roleCashier => 'صندوق‌دار';

  @override
  String get roleStockKeeper => 'ګدام‌وال';

  @override
  String get roleAccountant => 'حساب‌دار';

  @override
  String get errUserLastOwner => 'تاسو وروستی مالک نشئ غیرفعالولی.';

  @override
  String get errBranchLastActive => 'تاسو یوازینۍ فعاله څانګه نشئ غیرفعالولی.';

  @override
  String get errUsernameTaken => 'دا کارن نوم لا دمخه نیول شوی دی.';

  @override
  String get errGeneric => 'یوه ستونزه رامنځته شوه. بیا هڅه وکړئ.';

  @override
  String get syncIssuesTitle => 'د همغږۍ ستونزې';

  @override
  String get syncIssuesReview => 'کتنه';

  @override
  String get syncIssueConflict =>
      'مخکې په بل ځای کې بدل شوی و؛ هغه بدلون وساتل شو';

  @override
  String get syncIssueRejected => 'سرور دا بدلون ونه مانه';

  @override
  String get syncIssueRetry => 'بیا یې پلي کړئ';

  @override
  String get syncIssueDismiss => 'یو طرف ته یې کېږدئ';

  @override
  String get syncIssuesEmpty => 'د کتنې لپاره هیڅ نشته.';

  @override
  String get errUnitUnknown =>
      'د دې توکي واحد لا نه دی راغلی. همغږي یې کړئ، بیا هڅه وکړئ.';

  @override
  String get editQuantity => 'مقدار بدلول';

  @override
  String get errAmountInvalid => 'مبلغ لکه ۲۵۰ یا ۲۵۰٫۵۰ ولیکئ.';

  @override
  String get errQtyInvalid => 'مقدار لکه ۳ یا ۲٫۵ ولیکئ.';

  @override
  String get errQtyPrecision => 'دا واحد دومره اعشاري رقمونه نه مني.';

  @override
  String get errMustBePositive => 'له صفر څخه لوی عدد ولیکئ.';

  @override
  String get errChooseProduct => 'یو توکی وټاکئ.';

  @override
  String get errRequired => 'دا برخه اړینه ده.';

  @override
  String get errTooLong => 'ډېر اوږد دی.';

  @override
  String get quantityReceived => 'ترلاسه شوی مقدار';

  @override
  String get savedOk => 'وساتل شو.';

  @override
  String get settings => 'تنظیمات';

  @override
  String get printerSettings => 'د رسید چاپګر';

  @override
  String get enablePrinting => 'د رسیدونو چاپ';

  @override
  String get printerHost => 'د چاپګر IP پته';

  @override
  String get printerPort => 'پورټ';

  @override
  String get testPrint => 'ازمایښتي چاپ';

  @override
  String get printReceipt => 'چاپ';

  @override
  String get printerNotConfigured =>
      'هیڅ چاپګر نه دی ټاکل شوی. له تنظیماتو یو اضافه کړئ.';

  @override
  String get printSucceeded => 'چاپګر ته واستول شو.';

  @override
  String get printFailed => 'چاپګر ته لاسرسی ونشو.';

  @override
  String get notifications => 'خبرتیاوې';

  @override
  String get insightsTitle => 'کتنې';

  @override
  String get noNotifications => 'هرڅه کتل شوي دي';

  @override
  String get refreshInsights => 'تازه کول';

  @override
  String get markReadAction => 'لوستل شوی';

  @override
  String insightReorder(String product) {
    return 'د $product ذخیره پای ته رسیږي';
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
      other: '$product په $daysString ورځو کې نه دی خرڅ شوی',
      one: '$product په $daysString ورځ کې نه دی خرڅ شوی',
    );
    return '$_temp0';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer د پور سقف ته نږدې دی';
  }

  @override
  String insightDigest(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'نن $countString پلورونه',
      one: 'نن $countString پلور',
    );
    return '$_temp0';
  }

  @override
  String get insightUnknown => 'نوې کتنه';

  @override
  String get auditLog => 'د پلټنې لاګ';

  @override
  String get noAuditEntries => 'لا تر اوسه کوم فعالیت نه دی ثبت شوی';

  @override
  String get errSaleEmpty => 'لومړی یو توکی ور زیات کړئ.';

  @override
  String get errUnderpaid => 'ورکړل شوې پیسې له ټولې بیې لږې دي.';

  @override
  String get errOverpaid => 'ورکړل شوې پیسې له ټولې بیې زیاتې دي.';

  @override
  String get errDiscountInvalid =>
      'تخفیف نه شي کولای منفي یا له ټولې بیې زیات وي.';

  @override
  String get errSaleNotVoidable => 'دا پلور نه شي لغوه کېدای.';

  @override
  String get errStockInsufficient => 'د دې پلور لپاره کافي ذخیره نشته.';

  @override
  String get errShiftAlreadyClosed => 'دا شفټ مخکې تړل شوی دی.';

  @override
  String get errCurrencyMismatch => 'اسعار سره یو شان نه دي.';

  @override
  String get errBranchInactive => 'دا څانګه غیر فعاله ده.';

  @override
  String get errUserLastAssignment => 'دا د دې کارمند یوازینۍ څانګه ده.';

  @override
  String get errWeakPassword => 'دا پټنوم ډېر لنډ یا ساده دی.';

  @override
  String get errNotFound => 'دا نور شتون نه لري. تازه یې کړئ او بیا هڅه وکړئ.';

  @override
  String get errConflict =>
      'په دې منځ کې بل چا بدل کړی دی. تازه یې کړئ او بیا هڅه وکړئ.';

  @override
  String get errInvalid =>
      'ځینې ارزښتونه و نه منل شول. وې ګورئ او بیا هڅه وکړئ.';

  @override
  String get biometricReason =>
      'د دوکان‌پرو د خلاصولو لپاره خپل هویت تایید کړئ';

  @override
  String get unitPiece => 'دانه';

  @override
  String get unitKg => 'کیلوګرام';

  @override
  String get unitLitre => 'لیتر';

  @override
  String get unitDozen => 'درجن';

  @override
  String get unitMeter => 'متر';

  @override
  String get timeZoneKabul => 'د کابل وخت';

  @override
  String get currencyAfn => 'افغانۍ';

  @override
  String get currencyUsd => 'امریکايي ډالر';

  @override
  String get currencyPkr => 'پاکستانۍ کلدار';

  @override
  String get currencyEur => 'یورو';

  @override
  String get auditSystem => 'سیسټم';

  @override
  String get auditOther => 'بل فعالیت';

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
  String get auditBarcodeAdded => 'بارکوډ زیات شو';

  @override
  String get auditBarcodeRemoved => 'بارکوډ لرې شو';

  @override
  String get auditBranchActivated => 'څانګه بیا فعاله شوه';

  @override
  String get auditBranchCreated => 'څانګه جوړه شوه';

  @override
  String get auditBranchDeactivated => 'څانګه غیر فعاله شوه';

  @override
  String get auditBranchUpdated => 'څانګه بدله شوه';

  @override
  String get auditCostValuationChanged => 'د توکي د پېر بیه تازه شوه';

  @override
  String get auditCustomerCreated => 'پېرودونکی زیات شو';

  @override
  String get auditCustomerCreditLimitChanged => 'د پېرودونکي د پور حد بدل شو';

  @override
  String get auditCustomerDeactivated => 'د پېرودونکي حساب وتړل شو';

  @override
  String get auditCustomerReactivated => 'د پېرودونکي حساب بیا پرانیستل شو';

  @override
  String get auditCustomerUpdated => 'پېرودونکی بدل شو';

  @override
  String get auditDebtChargePosted => 'په پور پلور ثبت شو';

  @override
  String get auditDebtPaymentRecorded => 'د پېرودونکي پور ورکړل شو';

  @override
  String get auditDebtWrittenOff => 'پور وبښل شو';

  @override
  String get auditDiscountApplied => 'تخفیف ورکړل شو';

  @override
  String get auditNotificationsRefreshed => 'خبرتیاوې تازه شوې';

  @override
  String get auditOwnerBootstrapped => 'دوکان جوړ شو';

  @override
  String get auditPasswordReset => 'پټنوم بدل شو';

  @override
  String get auditPaymentRecorded => 'ورکړه ثبت شوه';

  @override
  String get auditProductCreated => 'توکی زیات شو';

  @override
  String get auditProductDeactivated => 'توکی غیر فعال شو';

  @override
  String get auditProductPriceChanged => 'د توکي بیه بدله شوه';

  @override
  String get auditProductUpdated => 'توکی بدل شو';

  @override
  String get auditPurchaseReceived => 'له عرضه‌کوونکي توکي ترلاسه شول';

  @override
  String get auditRoleAssigned => 'رول ورکړل شو';

  @override
  String get auditRoleRevoked => 'رول واخیستل شو';

  @override
  String get auditSaleLineAdded => 'پلور ته توکی زیات شو';

  @override
  String get auditSaleSettled => 'پلور بشپړ شو';

  @override
  String get auditSaleVoided => 'پلور لغوه شو';

  @override
  String get auditSessionReuseDetected => 'شکمنه ننوتنه بنده شوه';

  @override
  String get auditShiftClosed => 'شفټ وتړل شو';

  @override
  String get auditShiftOpened => 'شفټ پیل شو';

  @override
  String get auditStockAdjusted => 'ذخیره سمه شوه';

  @override
  String get auditStockReceived => 'ذخیره ترلاسه شوه';

  @override
  String get auditStockSold => 'ذخیره وپلورل شوه';

  @override
  String get auditSupplierBillPosted => 'د عرضه‌کوونکي بل ثبت شو';

  @override
  String get auditSupplierCreated => 'عرضه‌کوونکی زیات شو';

  @override
  String get auditSupplierPaymentRecorded => 'عرضه‌کوونکي ته پیسې ورکړل شوې';

  @override
  String get auditSyncPull => 'وسیله همغږې شوه';

  @override
  String get auditUnitCreated => 'واحد زیات شو';

  @override
  String get auditUserAuthenticated => 'ننوت';

  @override
  String get auditUserCreated => 'کارمند زیات شو';

  @override
  String get auditUserDisabled => 'کارمند غیر فعال شو';

  @override
  String get auditUserEnabled => 'کارمند فعال شو';

  @override
  String get auditUserLoginFailed => 'ناکامه ننوتنه';

  @override
  String get auditUserLogout => 'ووت';
}
