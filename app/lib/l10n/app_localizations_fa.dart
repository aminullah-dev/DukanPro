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
  String get products => 'محصولات';

  @override
  String get addProduct => 'افزودن محصول';

  @override
  String get editProduct => 'ویرایش محصول';

  @override
  String get productName => 'نام';

  @override
  String get sku => 'کد جنس';

  @override
  String get price => 'قیمت';

  @override
  String get unit => 'واحد';

  @override
  String get barcodeLabel => 'بارکد';

  @override
  String get trackStock => 'ردیابی موجودی';

  @override
  String get adjustStock => 'تنظیم موجودی';

  @override
  String get quantityDelta => 'مقدار (+/-)';

  @override
  String get save => 'ذخیره';

  @override
  String get cancel => 'لغو';

  @override
  String get onHand => 'موجود';

  @override
  String get noProducts => 'هنوز محصولی نیست';

  @override
  String get searchHint => 'جستجو یا اسکن…';

  @override
  String get permissionDenied => 'شما اجازهٔ این کار را ندارید.';

  @override
  String get skuTaken => 'این کد جنس قبلاً استفاده شده است.';

  @override
  String get pos => 'صندوق فروش';

  @override
  String get cartTitle => 'سبد';

  @override
  String get emptyCart => 'سبد خالی است';

  @override
  String get tendered => 'نقد دریافتی';

  @override
  String get change => 'باقی';

  @override
  String get receipt => 'رسید';

  @override
  String get customers => 'مشتریان';

  @override
  String get addCustomer => 'افزودن مشتری';

  @override
  String get customerName => 'نام';

  @override
  String get phone => 'تلفن';

  @override
  String get creditLimit => 'سقف اعتبار';

  @override
  String get setCreditLimit => 'تعیین سقف اعتبار';

  @override
  String get creditLimitHelp => 'برای بدون سقف، خالی بگذارید';

  @override
  String get recordPayment => 'ثبت پرداخت';

  @override
  String get amount => 'مبلغ';

  @override
  String get balance => 'بیلانس';

  @override
  String get credit => 'نسیه';

  @override
  String get receiveStock => 'ورود جنس';

  @override
  String get supplier => 'تأمین‌کننده';

  @override
  String get unitCost => 'قیمت خرید';

  @override
  String get receive => 'دریافت';

  @override
  String get noCustomers => 'هنوز مشتری‌ای نیست';

  @override
  String get dashboard => 'داشبورد';

  @override
  String get salesToday => 'فروش امروز';

  @override
  String get profit => 'سود';

  @override
  String get outstandingDebt => 'طلب‌های معوق';

  @override
  String get lowStock => 'کم‌موجودی';

  @override
  String get topSellers => 'پرفروش‌ها';

  @override
  String signedInAs(String user) {
    return 'واردشده به‌عنوان $user';
  }

  @override
  String get syncNow => 'همگام‌سازی';

  @override
  String get syncing => 'در حال همگام‌سازی…';

  @override
  String get syncUpToDate => 'به‌روز';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر برای ارسال',
      one: '۱ تغییر برای ارسال',
      zero: 'همه‌چیز همگام است',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed =>
      'همگام‌سازی ناکام شد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد نیاز به بازبینی دارند',
      one: '۱ مورد نیاز به بازبینی دارد',
    );
    return '$_temp0';
  }

  @override
  String syncRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر از طرف سرور رد شد',
      one: '۱ تغییر از طرف سرور رد شد',
    );
    return '$_temp0';
  }

  @override
  String get setupCode => 'کد راه‌اندازی';

  @override
  String get setupCodeHelp =>
      'هنگام روشن شدن سرور، در کنسول سرور نشان داده می‌شود';

  @override
  String get errSetupCode => 'کد راه‌اندازی درست نیست. کنسول سرور را ببینید.';

  @override
  String get lock => 'قفل';

  @override
  String get logoutConfirmTitle => 'از این دستگاه خارج می‌شوید؟';

  @override
  String get logoutConfirmBody =>
      'با خروج، ورود ذخیره‌شده از این دستگاه پاک می‌شود. تا وقتی کسی دوباره آنلاین وارد نشود، هیچ‌کس نمی‌تواند در اینجا فروش کند.';

  @override
  String logoutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر هنوز همگام نشده است.',
      one: '۱ تغییر هنوز همگام نشده است.',
    );
    return '$_temp0';
  }

  @override
  String get useAnotherAccount => 'ورود با حساب دیگر';

  @override
  String get backToUnlock => 'بازگشت';

  @override
  String get errOfflineExpired =>
      'این دستگاه مدت زیادی آفلاین بوده است. آنلاین وارد شوید.';

  @override
  String get errStorage =>
      'حافظهٔ امن این دستگاه خوانده نشد. دوباره وارد شوید؛ اگر تکرار شد، دستگاه را دوباره روشن کنید.';

  @override
  String get errTotalTooLarge =>
      'این مجموع برای ثبت بیش از حد بزرگ است. تعداد و قیمت را بررسی کنید.';

  @override
  String get errSessionEndedUnlock =>
      'نشست شما پایان یافت. رمز عبور خود را وارد کنید: برنامه بدون اینترنت هم کار می‌کند و وقتی آنلاین شد دوباره وارد می‌شود.';

  @override
  String get errSessionEnded =>
      'دسترسی شما تغییر کرده یا پایان یافته است. دوباره وارد شوید.';

  @override
  String get biometricUnlockSetting => 'باز کردن با اثر انگشت';

  @override
  String get confirmPasswordTitle => 'رمز عبور خود را تأیید کنید';

  @override
  String lastSyncedAt(String time) {
    return 'آخرین همگام‌سازی $time';
  }

  @override
  String get employees => 'کارمندان';

  @override
  String get addEmployee => 'افزودن کارمند';

  @override
  String get noEmployees => 'هنوز کارمندی نیست';

  @override
  String get role => 'نقش';

  @override
  String get enable => 'فعال کردن';

  @override
  String get disable => 'غیرفعال کردن';

  @override
  String get statusActive => 'فعال';

  @override
  String get statusDisabled => 'غیرفعال';

  @override
  String get resetPassword => 'بازنشانی رمز عبور';

  @override
  String get newPassword => 'رمز عبور جدید';

  @override
  String get assignRole => 'تعیین نقش';

  @override
  String get removeRole => 'حذف';

  @override
  String get branches => 'شعبه‌ها';

  @override
  String get addBranch => 'افزودن شعبه';

  @override
  String get noBranches => 'هنوز شعبه‌ای نیست';

  @override
  String get branchNameLabel => 'نام شعبه';

  @override
  String get rename => 'تغییر نام';

  @override
  String get activate => 'فعال کردن';

  @override
  String get deactivate => 'غیرفعال کردن';

  @override
  String get roleOwner => 'مالک';

  @override
  String get roleManager => 'مدیر';

  @override
  String get roleCashier => 'صندوق‌دار';

  @override
  String get roleStockKeeper => 'انباردار';

  @override
  String get roleAccountant => 'حسابدار';

  @override
  String get errUserLastOwner => 'نمی‌توانید تنها مالک را غیرفعال کنید.';

  @override
  String get errBranchLastActive =>
      'نمی‌توانید تنها شعبهٔ فعال را غیرفعال کنید.';

  @override
  String get errUsernameTaken => 'این نام کاربری قبلاً گرفته شده است.';

  @override
  String get errGeneric => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get syncIssuesTitle => 'مشکلات همگام‌سازی';

  @override
  String get syncIssuesReview => 'بررسی';

  @override
  String get syncIssueConflict =>
      'پیش‌تر جای دیگری تغییر کرده بود؛ آن تغییر نگه داشته شد';

  @override
  String get syncIssueRejected => 'سرور این تغییر را نپذیرفت';

  @override
  String get syncIssueRetry => 'دوباره اعمال شود';

  @override
  String get syncIssueDismiss => 'کنار گذاشته شود';

  @override
  String get syncIssuesEmpty => 'چیزی برای بررسی نیست.';

  @override
  String get errUnitUnknown =>
      'واحد این کالا هنوز بارگذاری نشده است. همگام‌سازی کنید و دوباره امتحان کنید.';

  @override
  String get editQuantity => 'تغییر مقدار';

  @override
  String get errAmountInvalid => 'مبلغ را مانند ۲۵۰ یا ۲۵۰٫۵۰ وارد کنید.';

  @override
  String get errQtyInvalid => 'مقدار را مانند ۳ یا ۲٫۵ وارد کنید.';

  @override
  String get errQtyPrecision => 'این واحد این‌قدر رقم اعشاری نمی‌پذیرد.';

  @override
  String get errMustBePositive => 'عددی بزرگ‌تر از صفر وارد کنید.';

  @override
  String get errChooseProduct => 'یک کالا انتخاب کنید.';

  @override
  String get errRequired => 'این بخش لازم است.';

  @override
  String get errTooLong => 'خیلی طولانی است.';

  @override
  String get quantityReceived => 'مقدار دریافت‌شده';

  @override
  String get savedOk => 'ذخیره شد.';

  @override
  String get settings => 'تنظیمات';

  @override
  String get printerSettings => 'چاپگر رسید';

  @override
  String get enablePrinting => 'چاپ رسیدها';

  @override
  String get printerHost => 'آدرس IP چاپگر';

  @override
  String get printerPort => 'پورت';

  @override
  String get testPrint => 'چاپ آزمایشی';

  @override
  String get printReceipt => 'چاپ';

  @override
  String get printerNotConfigured =>
      'چاپگری تنظیم نشده است. از تنظیمات یکی اضافه کنید.';

  @override
  String get printSucceeded => 'به چاپگر فرستاده شد.';

  @override
  String get printFailed => 'دسترسی به چاپگر ممکن نشد.';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get insightsTitle => 'بینش‌ها';

  @override
  String get noNotifications => 'همه‌چیز بررسی شده است';

  @override
  String get refreshInsights => 'به‌روزرسانی';

  @override
  String get markReadAction => 'خوانده‌شده';

  @override
  String insightReorder(String product) {
    return 'موجودی $product رو به اتمام است';
  }

  @override
  String insightDeadStock(String product, String days) {
    return '$product در $days روز فروش نداشته';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer به سقف اعتبار نزدیک است';
  }

  @override
  String insightDigest(String count) {
    return '$count فروش امروز';
  }

  @override
  String get insightUnknown => 'بینش جدید';

  @override
  String get auditLog => 'گزارش ممیزی';

  @override
  String get noAuditEntries => 'هنوز فعالیتی ثبت نشده است';
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
  String get products => 'محصولات';

  @override
  String get addProduct => 'افزودن محصول';

  @override
  String get editProduct => 'ویرایش محصول';

  @override
  String get productName => 'نام';

  @override
  String get sku => 'کد جنس';

  @override
  String get price => 'قیمت';

  @override
  String get unit => 'واحد';

  @override
  String get barcodeLabel => 'بارکد';

  @override
  String get trackStock => 'ردیابی موجودی';

  @override
  String get adjustStock => 'تنظیم موجودی';

  @override
  String get quantityDelta => 'مقدار (+/-)';

  @override
  String get save => 'ذخیره';

  @override
  String get cancel => 'لغو';

  @override
  String get onHand => 'موجود';

  @override
  String get noProducts => 'هنوز محصولی نیست';

  @override
  String get searchHint => 'جستجو یا اسکن…';

  @override
  String get permissionDenied => 'شما اجازهٔ این کار را ندارید.';

  @override
  String get skuTaken => 'این کد جنس قبلاً استفاده شده است.';

  @override
  String get pos => 'صندوق فروش';

  @override
  String get cartTitle => 'سبد';

  @override
  String get emptyCart => 'سبد خالی است';

  @override
  String get tendered => 'نقد دریافتی';

  @override
  String get change => 'باقی';

  @override
  String get receipt => 'رسید';

  @override
  String get customers => 'مشتریان';

  @override
  String get addCustomer => 'افزودن مشتری';

  @override
  String get customerName => 'نام';

  @override
  String get phone => 'تلفن';

  @override
  String get creditLimit => 'سقف اعتبار';

  @override
  String get setCreditLimit => 'تعیین سقف اعتبار';

  @override
  String get creditLimitHelp => 'برای بدون سقف، خالی بگذارید';

  @override
  String get recordPayment => 'ثبت پرداخت';

  @override
  String get amount => 'مبلغ';

  @override
  String get balance => 'بیلانس';

  @override
  String get credit => 'نسیه';

  @override
  String get receiveStock => 'ورود جنس';

  @override
  String get supplier => 'تأمین‌کننده';

  @override
  String get unitCost => 'قیمت خرید';

  @override
  String get receive => 'دریافت';

  @override
  String get noCustomers => 'هنوز مشتری‌ای نیست';

  @override
  String get dashboard => 'داشبورد';

  @override
  String get salesToday => 'فروش امروز';

  @override
  String get profit => 'سود';

  @override
  String get outstandingDebt => 'طلب‌های معوق';

  @override
  String get lowStock => 'کم‌موجودی';

  @override
  String get topSellers => 'پرفروش‌ها';

  @override
  String signedInAs(String user) {
    return 'واردشده به‌عنوان $user';
  }

  @override
  String get syncNow => 'همگام‌سازی';

  @override
  String get syncing => 'در حال همگام‌سازی…';

  @override
  String get syncUpToDate => 'به‌روز';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر برای ارسال',
      one: '۱ تغییر برای ارسال',
      zero: 'همه‌چیز همگام است',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed =>
      'همگام‌سازی ناکام شد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String syncConflicts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مورد نیاز به بازبینی دارند',
      one: '۱ مورد نیاز به بازبینی دارد',
    );
    return '$_temp0';
  }

  @override
  String syncRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر از طرف سرور رد شد',
      one: '۱ تغییر از طرف سرور رد شد',
    );
    return '$_temp0';
  }

  @override
  String get setupCode => 'کد راه‌اندازی';

  @override
  String get setupCodeHelp =>
      'هنگام روشن شدن سرور، در کنسول سرور نشان داده می‌شود';

  @override
  String get errSetupCode => 'کد راه‌اندازی درست نیست. کنسول سرور را ببینید.';

  @override
  String get lock => 'قفل';

  @override
  String get logoutConfirmTitle => 'از این دستگاه خارج می‌شوید؟';

  @override
  String get logoutConfirmBody =>
      'با خروج، ورود ذخیره‌شده از این دستگاه پاک می‌شود. تا وقتی کسی دوباره آنلاین وارد نشود، هیچ‌کس نمی‌تواند در اینجا فروش کند.';

  @override
  String logoutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغییر هنوز همگام نشده است.',
      one: '۱ تغییر هنوز همگام نشده است.',
    );
    return '$_temp0';
  }

  @override
  String get useAnotherAccount => 'ورود با حساب دیگر';

  @override
  String get backToUnlock => 'بازگشت';

  @override
  String get errOfflineExpired =>
      'این دستگاه مدت زیادی آفلاین بوده است. آنلاین وارد شوید.';

  @override
  String get errStorage =>
      'حافظهٔ امن این دستگاه خوانده نشد. دوباره وارد شوید؛ اگر تکرار شد، دستگاه را دوباره روشن کنید.';

  @override
  String get errTotalTooLarge =>
      'این مجموع برای ثبت بیش از حد بزرگ است. تعداد و قیمت را بررسی کنید.';

  @override
  String get errSessionEndedUnlock =>
      'نشست شما پایان یافت. رمز عبور خود را وارد کنید: برنامه بدون اینترنت هم کار می‌کند و وقتی آنلاین شد دوباره وارد می‌شود.';

  @override
  String get errSessionEnded =>
      'دسترسی شما تغییر کرده یا پایان یافته است. دوباره وارد شوید.';

  @override
  String get biometricUnlockSetting => 'باز کردن با اثر انگشت';

  @override
  String get confirmPasswordTitle => 'رمز عبور خود را تأیید کنید';

  @override
  String lastSyncedAt(String time) {
    return 'آخرین همگام‌سازی $time';
  }

  @override
  String get employees => 'کارمندان';

  @override
  String get addEmployee => 'افزودن کارمند';

  @override
  String get noEmployees => 'هنوز کارمندی نیست';

  @override
  String get role => 'نقش';

  @override
  String get enable => 'فعال کردن';

  @override
  String get disable => 'غیرفعال کردن';

  @override
  String get statusActive => 'فعال';

  @override
  String get statusDisabled => 'غیرفعال';

  @override
  String get resetPassword => 'بازنشانی رمز عبور';

  @override
  String get newPassword => 'رمز عبور جدید';

  @override
  String get assignRole => 'تعیین نقش';

  @override
  String get removeRole => 'حذف';

  @override
  String get branches => 'شعبه‌ها';

  @override
  String get addBranch => 'افزودن شعبه';

  @override
  String get noBranches => 'هنوز شعبه‌ای نیست';

  @override
  String get branchNameLabel => 'نام شعبه';

  @override
  String get rename => 'تغییر نام';

  @override
  String get activate => 'فعال کردن';

  @override
  String get deactivate => 'غیرفعال کردن';

  @override
  String get roleOwner => 'مالک';

  @override
  String get roleManager => 'مدیر';

  @override
  String get roleCashier => 'صندوق‌دار';

  @override
  String get roleStockKeeper => 'انباردار';

  @override
  String get roleAccountant => 'حسابدار';

  @override
  String get errUserLastOwner => 'نمی‌توانید تنها مالک را غیرفعال کنید.';

  @override
  String get errBranchLastActive =>
      'نمی‌توانید تنها شعبهٔ فعال را غیرفعال کنید.';

  @override
  String get errUsernameTaken => 'این نام کاربری قبلاً گرفته شده است.';

  @override
  String get errGeneric => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get syncIssuesTitle => 'مشکلات همگام‌سازی';

  @override
  String get syncIssuesReview => 'بررسی';

  @override
  String get syncIssueConflict =>
      'پیش‌تر جای دیگری تغییر کرده بود؛ آن تغییر نگه داشته شد';

  @override
  String get syncIssueRejected => 'سرور این تغییر را نپذیرفت';

  @override
  String get syncIssueRetry => 'دوباره اعمال شود';

  @override
  String get syncIssueDismiss => 'کنار گذاشته شود';

  @override
  String get syncIssuesEmpty => 'چیزی برای بررسی نیست.';

  @override
  String get errUnitUnknown =>
      'واحد این کالا هنوز بارگذاری نشده است. همگام‌سازی کنید و دوباره امتحان کنید.';

  @override
  String get editQuantity => 'تغییر مقدار';

  @override
  String get errAmountInvalid => 'مبلغ را مانند ۲۵۰ یا ۲۵۰٫۵۰ وارد کنید.';

  @override
  String get errQtyInvalid => 'مقدار را مانند ۳ یا ۲٫۵ وارد کنید.';

  @override
  String get errQtyPrecision => 'این واحد این‌قدر رقم اعشاری نمی‌پذیرد.';

  @override
  String get errMustBePositive => 'عددی بزرگ‌تر از صفر وارد کنید.';

  @override
  String get errChooseProduct => 'یک کالا انتخاب کنید.';

  @override
  String get errRequired => 'این بخش لازم است.';

  @override
  String get errTooLong => 'خیلی طولانی است.';

  @override
  String get quantityReceived => 'مقدار دریافت‌شده';

  @override
  String get savedOk => 'ذخیره شد.';

  @override
  String get settings => 'تنظیمات';

  @override
  String get printerSettings => 'چاپگر رسید';

  @override
  String get enablePrinting => 'چاپ رسیدها';

  @override
  String get printerHost => 'آدرس IP چاپگر';

  @override
  String get printerPort => 'پورت';

  @override
  String get testPrint => 'چاپ آزمایشی';

  @override
  String get printReceipt => 'چاپ';

  @override
  String get printerNotConfigured =>
      'چاپگری تنظیم نشده است. از تنظیمات یکی اضافه کنید.';

  @override
  String get printSucceeded => 'به چاپگر فرستاده شد.';

  @override
  String get printFailed => 'دسترسی به چاپگر ممکن نشد.';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get insightsTitle => 'بینش‌ها';

  @override
  String get noNotifications => 'همه‌چیز بررسی شده است';

  @override
  String get refreshInsights => 'به‌روزرسانی';

  @override
  String get markReadAction => 'خوانده‌شده';

  @override
  String insightReorder(String product) {
    return 'موجودی $product رو به اتمام است';
  }

  @override
  String insightDeadStock(String product, String days) {
    return '$product در $days روز فروش نداشته';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer به سقف اعتبار نزدیک است';
  }

  @override
  String insightDigest(String count) {
    return '$count فروش امروز';
  }

  @override
  String get insightUnknown => 'بینش جدید';

  @override
  String get auditLog => 'گزارش ممیزی';

  @override
  String get noAuditEntries => 'هنوز فعالیتی ثبت نشده است';
}
