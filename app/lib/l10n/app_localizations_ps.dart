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
  String get credit => 'اُدهار';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدلونونه د لیږلو لپاره',
      one: '۱ بدلون د لیږلو لپاره',
      zero: 'ټول بدلونونه همغږي شوي',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed => 'همغږي ونشوه. خپل پیوستون وګورئ او بیا هڅه وکړئ.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توکي بیاکتنې ته اړتیا لري',
      one: '۱ توکی بیاکتنې ته اړتیا لري',
    );
    return '$_temp0';
  }

  @override
  String syncRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدلونونه د سرور له خوا رد شول',
      one: '۱ بدلون د سرور له خوا رد شو',
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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدلونونه لا نه دي همغږي شوي.',
      one: '۱ بدلون لا نه دی همغږی شوی.',
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
  String insightDeadStock(String product, String days) {
    return '$product په $days ورځو کې نه دی خرڅ شوی';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer د پور سقف ته نږدې دی';
  }

  @override
  String insightDigest(String count) {
    return '$count نن پلورونه';
  }

  @override
  String get insightUnknown => 'نوې کتنه';

  @override
  String get auditLog => 'د پلټنې لاګ';

  @override
  String get noAuditEntries => 'لا تر اوسه کومه فعالیت نه دی ثبت شوی';
}
