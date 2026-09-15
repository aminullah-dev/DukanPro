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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString قلم',
      one: '$countString قلم',
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
  String get products => 'اجناس';

  @override
  String get addProduct => 'افزودن جنس';

  @override
  String get editProduct => 'ویرایش جنس';

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
  String get noProducts => 'هنوز جنسی نیست';

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
  String get supplier => 'تهیه‌کننده';

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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString تغییر برای ارسال',
      one: '$countString تغییر برای ارسال',
      zero: 'همه‌چیز همگام است',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed =>
      'همگام‌سازی ناکام شد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String syncConflicts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString مورد نیاز به بازبینی دارند',
      one: '$countString مورد نیاز به بازبینی دارد',
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
      other: '$countString تغییر از طرف سرور رد شد',
      one: '$countString تغییر از طرف سرور رد شد',
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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString تغییر هنوز همگام نشده است.',
      one: '$countString تغییر هنوز همگام نشده است.',
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
  String get errLocalDatabase =>
      'داده‌های این دستگاه باز نشد. برنامه را ببندید و دوباره باز کنید؛ اگر باز هم تکرار شد، دستگاه را دوباره روشن کنید.';

  @override
  String get errTotalTooLarge =>
      'این مجموع برای ثبت بیش از حد بزرگ است. تعداد و قیمت را بررسی کنید.';

  @override
  String get errSessionEndedUnlock =>
      'نشست شما پایان یافت. رمز عبور خود را وارد کنید: برنامه بدون اینترنت هم کار می‌کند و وقتی آنلاین شد دوباره وارد می‌شود.';

  @override
  String get cashNow => 'نقد همین حالا';

  @override
  String get onCredit => 'به نسیه';

  @override
  String get deactivateCustomer => 'بستن حساب';

  @override
  String get reactivateCustomer => 'بازکردن دوبارهٔ حساب';

  @override
  String get customerInactive => 'حساب بسته: بدون نسیه';

  @override
  String get writeOffDebt => 'بخشیدن قرض';

  @override
  String profitMissingCost(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString قلم بدون قیمت خرید فروخته شده',
    );
    return '$_temp0';
  }

  @override
  String get errCustomerInactive =>
      'حساب این مشتری بسته است و نسیه داده نمی‌شود.';

  @override
  String get errDebtCurrency =>
      'بدهی این مشتری به ارز دیگری است؛ نسیه فقط به ارز خود او داده می‌شود.';

  @override
  String get errOverCreditLimit => 'این فروش از سقف نسیهٔ مشتری بیشتر می‌شود.';

  @override
  String get errDebtOverpayment => 'این مبلغ از بدهی مشتری بیشتر است.';

  @override
  String get errWriteOffTooMuch =>
      'حداکثر به اندازهٔ بدهی مشتری می‌توان بخشید.';

  @override
  String get openShift => 'آغاز شیفت';

  @override
  String get closeShift => 'ختم شیفت';

  @override
  String get openingFloat => 'پول نقد آغاز صندوق';

  @override
  String get openShiftPrompt =>
      'برای آغاز فروش، شیفت خود را باز کنید. پول نقدی را که اکنون در صندوق است بشمارید.';

  @override
  String get zReport => 'گزارش شیفت';

  @override
  String get cashSales => 'فروش نقدی';

  @override
  String get cardSales => 'فروش با کارت';

  @override
  String get transferSales => 'پول موبایلی و حواله';

  @override
  String get debtCollected => 'قرض وصول‌شده به نقد';

  @override
  String get expectedCash => 'پول نقدی که باید در صندوق باشد';

  @override
  String get countedCash => 'پول نقد شمرده‌شده';

  @override
  String get variance => 'تفاوت';

  @override
  String get card => 'کارت';

  @override
  String get transfer => 'حواله';

  @override
  String get addPayment => 'افزودن پرداخت';

  @override
  String get remaining => 'باقی‌مانده';

  @override
  String shiftClosed(String variance) {
    return 'شیفت ختم شد. تفاوت: $variance';
  }

  @override
  String get errShiftNotOpen =>
      'اول شیفت خود را باز کنید؛ فروش در شیفت باز شما ثبت می‌شود.';

  @override
  String get errShiftAlreadyOpen => 'شما همین حالا یک شیفت باز در اینجا دارید.';

  @override
  String get suppliers => 'تهیه‌کنندگان';

  @override
  String get paySupplier => 'پرداخت به تهیه‌کننده';

  @override
  String get addSupplier => 'افزودن تهیه‌کننده';

  @override
  String get supplierName => 'نام تهیه‌کننده';

  @override
  String get noSuppliers => 'هنوز تهیه‌کننده‌ای نیست';

  @override
  String get paidToSuppliers => 'پرداخت نقدی به تهیه‌کنندگان';

  @override
  String get productActive => 'فعال (قابل فروش)';

  @override
  String get barcodes => 'بارکدها';

  @override
  String get addBarcode => 'افزودن بارکد';

  @override
  String get removeBarcode => 'حذف بارکد';

  @override
  String get errBarcodeTaken =>
      'این بارکد روی جنس دیگری ثبت است. اول آن را از آنجا حذف کنید.';

  @override
  String get errSupplierOverpayment =>
      'این مبلغ از قرض دکان به این تهیه‌کننده بیشتر است.';

  @override
  String get errNotStockTracked => 'موجودی این جنس دنبال نمی‌شود.';

  @override
  String get recentSales => 'فروش‌های اخیر';

  @override
  String get noRecentSales => 'هنوز فروشی نیست';

  @override
  String get receivedOk => 'به موجودی افزوده شد';

  @override
  String get drawerFailed => 'رسید چاپ شد، اما صندوق پول باز نشد.';

  @override
  String get searchCustomer => 'جستجوی مشتری';

  @override
  String get paid => 'پرداخت‌شده';

  @override
  String get voided => 'باطل‌شده';

  @override
  String get language => 'زبان';

  @override
  String get errSessionEnded =>
      'دسترسی شما تغییر کرده یا پایان یافته است. دوباره وارد شوید.';

  @override
  String get biometricUnlockSetting => 'باز کردن با اثر انگشت';

  @override
  String get idleLockSetting => 'قفل شدن پس از بی‌کاری';

  @override
  String idleLockMinutes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString دقیقه',
      one: '$countString دقیقه',
    );
    return '$_temp0';
  }

  @override
  String get idleLockManagersOnly =>
      'فقط مالک یا مدیر می‌تواند این را تغییر دهد.';

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
      'واحد این جنس هنوز بارگذاری نشده است. همگام‌سازی کنید و دوباره امتحان کنید.';

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
  String get errChooseProduct => 'یک جنس انتخاب کنید.';

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
  String get paperWidth => 'عرض کاغذ';

  @override
  String paperMillimetres(int mm) {
    final intl.NumberFormat mmNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String mmString = mmNumberFormat.format(mm);

    return '$mmString میلی‌متر';
  }

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
  String insightDeadStock(String product, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$product در $daysString روز فروش نداشته',
    );
    return '$_temp0';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer به سقف اعتبار نزدیک است';
  }

  @override
  String insightDigest(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString فروش امروز',
    );
    return '$_temp0';
  }

  @override
  String get insightUnknown => 'بینش جدید';

  @override
  String get auditLog => 'گزارش ممیزی';

  @override
  String get noAuditEntries => 'هنوز فعالیتی ثبت نشده است';

  @override
  String get errSaleEmpty => 'اول یک قلم اضافه کنید.';

  @override
  String get errUnderpaid => 'مبلغ پرداخت از مجموع کمتر است.';

  @override
  String get errOverpaid => 'مبلغ پرداخت از مجموع بیشتر است.';

  @override
  String get errDiscountInvalid =>
      'تخفیف نمی‌تواند منفی یا بیشتر از مجموع باشد.';

  @override
  String get errSaleNotVoidable => 'این فروش را نمی‌توان باطل کرد.';

  @override
  String get errStockInsufficient => 'موجودی برای این فروش کافی نیست.';

  @override
  String get errShiftAlreadyClosed => 'این شیفت قبلاً ختم شده است.';

  @override
  String get errCurrencyMismatch => 'واحدهای پول با هم یکی نیستند.';

  @override
  String get errBranchInactive => 'این شعبه غیرفعال است.';

  @override
  String get errUserLastAssignment => 'این تنها شعبهٔ این کارمند است.';

  @override
  String get errWeakPassword => 'این رمز عبور خیلی کوتاه یا ساده است.';

  @override
  String get errNotFound =>
      'این مورد دیگر وجود ندارد. تازه کنید و دوباره کوشش کنید.';

  @override
  String get errConflict =>
      'در این میان کس دیگری آن را تغییر داده است. تازه کنید و دوباره کوشش کنید.';

  @override
  String get errInvalid =>
      'بعضی مقادیر پذیرفته نشد. آن‌ها را بررسی کنید و دوباره کوشش کنید.';

  @override
  String get biometricReason =>
      'برای باز کردن قفل دکان‌پرو، هویت خود را تأیید کنید';

  @override
  String get unitPiece => 'دانه';

  @override
  String get unitKg => 'کیلوگرام';

  @override
  String get unitLitre => 'لیتر';

  @override
  String get unitDozen => 'درجن';

  @override
  String get unitMeter => 'متر';

  @override
  String get timeZoneKabul => 'وقت کابل';

  @override
  String get currencyAfn => 'افغانی';

  @override
  String get currencyUsd => 'دالر امریکایی';

  @override
  String get currencyPkr => 'کلدار پاکستانی';

  @override
  String get currencyEur => 'یورو';

  @override
  String get auditSystem => 'سیستم';

  @override
  String get auditOther => 'فعالیت دیگر';

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
  String get auditBarcodeAdded => 'بارکد اضافه شد';

  @override
  String get auditBarcodeRemoved => 'بارکد حذف شد';

  @override
  String get auditBranchActivated => 'شعبه دوباره فعال شد';

  @override
  String get auditBranchCreated => 'شعبه ایجاد شد';

  @override
  String get auditBranchDeactivated => 'شعبه غیرفعال شد';

  @override
  String get auditBranchUpdated => 'شعبه تغییر کرد';

  @override
  String get auditCostValuationChanged => 'قیمت خرید جنس به‌روز شد';

  @override
  String get auditCustomerCreated => 'مشتری اضافه شد';

  @override
  String get auditCustomerCreditLimitChanged => 'حد قرض مشتری تغییر کرد';

  @override
  String get auditCustomerDeactivated => 'حساب مشتری بسته شد';

  @override
  String get auditCustomerReactivated => 'حساب مشتری دوباره باز شد';

  @override
  String get auditCustomerUpdated => 'مشتری تغییر کرد';

  @override
  String get auditDebtChargePosted => 'فروش قرضی ثبت شد';

  @override
  String get auditDebtPaymentRecorded => 'قرض مشتری پرداخت شد';

  @override
  String get auditDebtWrittenOff => 'قرض بخشیده شد';

  @override
  String get auditDiscountApplied => 'تخفیف داده شد';

  @override
  String get auditNotificationsRefreshed => 'اعلان‌ها به‌روز شد';

  @override
  String get auditOwnerBootstrapped => 'دکان راه‌اندازی شد';

  @override
  String get auditPasswordReset => 'رمز عبور تغییر داده شد';

  @override
  String get auditPaymentRecorded => 'پرداخت ثبت شد';

  @override
  String get auditProductCreated => 'جنس اضافه شد';

  @override
  String get auditProductDeactivated => 'جنس غیرفعال شد';

  @override
  String get auditProductPriceChanged => 'قیمت جنس تغییر کرد';

  @override
  String get auditProductUpdated => 'جنس تغییر کرد';

  @override
  String get auditPurchaseReceived => 'جنس از تهیه‌کننده رسید';

  @override
  String get auditRoleAssigned => 'نقش داده شد';

  @override
  String get auditRoleRevoked => 'نقش گرفته شد';

  @override
  String get auditSaleLineAdded => 'قلم به فروش اضافه شد';

  @override
  String get auditSaleSettled => 'فروش تکمیل شد';

  @override
  String get auditSaleVoided => 'فروش باطل شد';

  @override
  String get auditSessionReuseDetected => 'ورود مشکوک مسدود شد';

  @override
  String get auditShiftClosed => 'شیفت ختم شد';

  @override
  String get auditShiftOpened => 'شیفت آغاز شد';

  @override
  String get auditStockAdjusted => 'موجودی اصلاح شد';

  @override
  String get auditStockReceived => 'موجودی وارد شد';

  @override
  String get auditStockSold => 'موجودی فروخته شد';

  @override
  String get auditSupplierBillPosted => 'صورت‌حساب تهیه‌کننده ثبت شد';

  @override
  String get auditSupplierCreated => 'تهیه‌کننده اضافه شد';

  @override
  String get auditSupplierPaymentRecorded => 'به تهیه‌کننده پرداخت شد';

  @override
  String get auditSyncPull => 'دستگاه همگام شد';

  @override
  String get auditUnitCreated => 'واحد اضافه شد';

  @override
  String get auditUserAuthenticated => 'وارد شد';

  @override
  String get auditUserCreated => 'کارمند اضافه شد';

  @override
  String get auditUserDisabled => 'کارمند غیرفعال شد';

  @override
  String get auditUserEnabled => 'کارمند فعال شد';

  @override
  String get auditUserLoginFailed => 'ورود ناموفق';

  @override
  String get auditUserLogout => 'خارج شد';

  @override
  String get solarMonth1 => 'حمل';

  @override
  String get solarMonth2 => 'ثور';

  @override
  String get solarMonth3 => 'جوزا';

  @override
  String get solarMonth4 => 'سرطان';

  @override
  String get solarMonth5 => 'اسد';

  @override
  String get solarMonth6 => 'سنبله';

  @override
  String get solarMonth7 => 'میزان';

  @override
  String get solarMonth8 => 'عقرب';

  @override
  String get solarMonth9 => 'قوس';

  @override
  String get solarMonth10 => 'جدی';

  @override
  String get solarMonth11 => 'دلو';

  @override
  String get solarMonth12 => 'حوت';

  @override
  String solarDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String dateAndTime(String date, String time) {
    return '$date، $time';
  }

  @override
  String get symbolAfn => 'افغانی';

  @override
  String get symbolUsd => 'دالر';

  @override
  String get symbolPkr => 'کلدار';

  @override
  String get symbolEur => 'یورو';

  @override
  String moneyAmount(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String get shift => 'شیفت';

  @override
  String get category => 'دسته‌بندی';

  @override
  String get syncIssueOther => 'اطلاعات دیگر';

  @override
  String get errAccountDisabled =>
      'این حساب غیرفعال شده است. از مالک دکان بپرسید.';

  @override
  String get timeZoneKarachi => 'وقت کراچی';

  @override
  String get timeZoneTashkent => 'وقت تاشکند';

  @override
  String get timeZoneDushanbe => 'وقت دوشنبه';

  @override
  String get timeZoneDubai => 'وقت دبی';

  @override
  String get timeZoneTehran => 'وقت تهران';

  @override
  String get timeZoneUtc => 'زمان جهانی';
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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString قلم',
      one: '$countString قلم',
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
  String get products => 'اجناس';

  @override
  String get addProduct => 'افزودن جنس';

  @override
  String get editProduct => 'ویرایش جنس';

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
  String get noProducts => 'هنوز جنسی نیست';

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
  String get supplier => 'تهیه‌کننده';

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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString تغییر برای ارسال',
      one: '$countString تغییر برای ارسال',
      zero: 'همه‌چیز همگام است',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed =>
      'همگام‌سازی ناکام شد. اتصال را بررسی کنید و دوباره تلاش کنید.';

  @override
  String syncConflicts(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString مورد نیاز به بازبینی دارند',
      one: '$countString مورد نیاز به بازبینی دارد',
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
      other: '$countString تغییر از طرف سرور رد شد',
      one: '$countString تغییر از طرف سرور رد شد',
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
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString تغییر هنوز همگام نشده است.',
      one: '$countString تغییر هنوز همگام نشده است.',
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
  String get errLocalDatabase =>
      'داده‌های این دستگاه باز نشد. برنامه را ببندید و دوباره باز کنید؛ اگر باز هم تکرار شد، دستگاه را دوباره روشن کنید.';

  @override
  String get errTotalTooLarge =>
      'این مجموع برای ثبت بیش از حد بزرگ است. تعداد و قیمت را بررسی کنید.';

  @override
  String get errSessionEndedUnlock =>
      'نشست شما پایان یافت. رمز عبور خود را وارد کنید: برنامه بدون اینترنت هم کار می‌کند و وقتی آنلاین شد دوباره وارد می‌شود.';

  @override
  String get cashNow => 'نقد همین حالا';

  @override
  String get onCredit => 'به نسیه';

  @override
  String get deactivateCustomer => 'بستن حساب';

  @override
  String get reactivateCustomer => 'بازکردن دوبارهٔ حساب';

  @override
  String get customerInactive => 'حساب بسته: بدون نسیه';

  @override
  String get writeOffDebt => 'بخشیدن قرض';

  @override
  String profitMissingCost(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString قلم بدون قیمت خرید فروخته شده',
    );
    return '$_temp0';
  }

  @override
  String get errCustomerInactive =>
      'حساب این مشتری بسته است و نسیه داده نمی‌شود.';

  @override
  String get errDebtCurrency =>
      'بدهی این مشتری به ارز دیگری است؛ نسیه فقط به ارز خود او داده می‌شود.';

  @override
  String get errOverCreditLimit => 'این فروش از سقف نسیهٔ مشتری بیشتر می‌شود.';

  @override
  String get errDebtOverpayment => 'این مبلغ از بدهی مشتری بیشتر است.';

  @override
  String get errWriteOffTooMuch =>
      'حداکثر به اندازهٔ بدهی مشتری می‌توان بخشید.';

  @override
  String get openShift => 'آغاز شیفت';

  @override
  String get closeShift => 'ختم شیفت';

  @override
  String get openingFloat => 'پول نقد آغاز صندوق';

  @override
  String get openShiftPrompt =>
      'برای آغاز فروش، شیفت خود را باز کنید. پول نقدی را که اکنون در صندوق است بشمارید.';

  @override
  String get zReport => 'گزارش شیفت';

  @override
  String get cashSales => 'فروش نقدی';

  @override
  String get cardSales => 'فروش با کارت';

  @override
  String get transferSales => 'پول موبایلی و حواله';

  @override
  String get debtCollected => 'قرض وصول‌شده به نقد';

  @override
  String get expectedCash => 'پول نقدی که باید در صندوق باشد';

  @override
  String get countedCash => 'پول نقد شمرده‌شده';

  @override
  String get variance => 'تفاوت';

  @override
  String get card => 'کارت';

  @override
  String get transfer => 'حواله';

  @override
  String get addPayment => 'افزودن پرداخت';

  @override
  String get remaining => 'باقی‌مانده';

  @override
  String shiftClosed(String variance) {
    return 'شیفت ختم شد. تفاوت: $variance';
  }

  @override
  String get errShiftNotOpen =>
      'اول شیفت خود را باز کنید؛ فروش در شیفت باز شما ثبت می‌شود.';

  @override
  String get errShiftAlreadyOpen => 'شما همین حالا یک شیفت باز در اینجا دارید.';

  @override
  String get suppliers => 'تهیه‌کنندگان';

  @override
  String get paySupplier => 'پرداخت به تهیه‌کننده';

  @override
  String get addSupplier => 'افزودن تهیه‌کننده';

  @override
  String get supplierName => 'نام تهیه‌کننده';

  @override
  String get noSuppliers => 'هنوز تهیه‌کننده‌ای نیست';

  @override
  String get paidToSuppliers => 'پرداخت نقدی به تهیه‌کنندگان';

  @override
  String get productActive => 'فعال (قابل فروش)';

  @override
  String get barcodes => 'بارکدها';

  @override
  String get addBarcode => 'افزودن بارکد';

  @override
  String get removeBarcode => 'حذف بارکد';

  @override
  String get errBarcodeTaken =>
      'این بارکد روی جنس دیگری ثبت است. اول آن را از آنجا حذف کنید.';

  @override
  String get errSupplierOverpayment =>
      'این مبلغ از قرض دکان به این تهیه‌کننده بیشتر است.';

  @override
  String get errNotStockTracked => 'موجودی این جنس دنبال نمی‌شود.';

  @override
  String get recentSales => 'فروش‌های اخیر';

  @override
  String get noRecentSales => 'هنوز فروشی نیست';

  @override
  String get receivedOk => 'به موجودی افزوده شد';

  @override
  String get drawerFailed => 'رسید چاپ شد، اما صندوق پول باز نشد.';

  @override
  String get searchCustomer => 'جستجوی مشتری';

  @override
  String get paid => 'پرداخت‌شده';

  @override
  String get voided => 'باطل‌شده';

  @override
  String get language => 'زبان';

  @override
  String get errSessionEnded =>
      'دسترسی شما تغییر کرده یا پایان یافته است. دوباره وارد شوید.';

  @override
  String get biometricUnlockSetting => 'باز کردن با اثر انگشت';

  @override
  String get idleLockSetting => 'قفل شدن پس از بی‌کاری';

  @override
  String idleLockMinutes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString دقیقه',
      one: '$countString دقیقه',
    );
    return '$_temp0';
  }

  @override
  String get idleLockManagersOnly =>
      'فقط مالک یا مدیر می‌تواند این را تغییر دهد.';

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
      'واحد این جنس هنوز بارگذاری نشده است. همگام‌سازی کنید و دوباره امتحان کنید.';

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
  String get errChooseProduct => 'یک جنس انتخاب کنید.';

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
  String get paperWidth => 'عرض کاغذ';

  @override
  String paperMillimetres(int mm) {
    final intl.NumberFormat mmNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String mmString = mmNumberFormat.format(mm);

    return '$mmString میلی‌متر';
  }

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
  String insightDeadStock(String product, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$product در $daysString روز فروش نداشته',
    );
    return '$_temp0';
  }

  @override
  String insightDebtRisk(String customer) {
    return '$customer به سقف اعتبار نزدیک است';
  }

  @override
  String insightDigest(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString فروش امروز',
    );
    return '$_temp0';
  }

  @override
  String get insightUnknown => 'بینش جدید';

  @override
  String get auditLog => 'گزارش ممیزی';

  @override
  String get noAuditEntries => 'هنوز فعالیتی ثبت نشده است';

  @override
  String get errSaleEmpty => 'اول یک قلم اضافه کنید.';

  @override
  String get errUnderpaid => 'مبلغ پرداخت از مجموع کمتر است.';

  @override
  String get errOverpaid => 'مبلغ پرداخت از مجموع بیشتر است.';

  @override
  String get errDiscountInvalid =>
      'تخفیف نمی‌تواند منفی یا بیشتر از مجموع باشد.';

  @override
  String get errSaleNotVoidable => 'این فروش را نمی‌توان باطل کرد.';

  @override
  String get errStockInsufficient => 'موجودی برای این فروش کافی نیست.';

  @override
  String get errShiftAlreadyClosed => 'این شیفت قبلاً ختم شده است.';

  @override
  String get errCurrencyMismatch => 'واحدهای پول با هم یکی نیستند.';

  @override
  String get errBranchInactive => 'این شعبه غیرفعال است.';

  @override
  String get errUserLastAssignment => 'این تنها شعبهٔ این کارمند است.';

  @override
  String get errWeakPassword => 'این رمز عبور خیلی کوتاه یا ساده است.';

  @override
  String get errNotFound =>
      'این مورد دیگر وجود ندارد. تازه کنید و دوباره کوشش کنید.';

  @override
  String get errConflict =>
      'در این میان کس دیگری آن را تغییر داده است. تازه کنید و دوباره کوشش کنید.';

  @override
  String get errInvalid =>
      'بعضی مقادیر پذیرفته نشد. آن‌ها را بررسی کنید و دوباره کوشش کنید.';

  @override
  String get biometricReason =>
      'برای باز کردن قفل دکان‌پرو، هویت خود را تأیید کنید';

  @override
  String get unitPiece => 'دانه';

  @override
  String get unitKg => 'کیلوگرام';

  @override
  String get unitLitre => 'لیتر';

  @override
  String get unitDozen => 'درجن';

  @override
  String get unitMeter => 'متر';

  @override
  String get timeZoneKabul => 'وقت کابل';

  @override
  String get currencyAfn => 'افغانی';

  @override
  String get currencyUsd => 'دالر امریکایی';

  @override
  String get currencyPkr => 'کلدار پاکستانی';

  @override
  String get currencyEur => 'یورو';

  @override
  String get auditSystem => 'سیستم';

  @override
  String get auditOther => 'فعالیت دیگر';

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
  String get auditBarcodeAdded => 'بارکد اضافه شد';

  @override
  String get auditBarcodeRemoved => 'بارکد حذف شد';

  @override
  String get auditBranchActivated => 'شعبه دوباره فعال شد';

  @override
  String get auditBranchCreated => 'شعبه ایجاد شد';

  @override
  String get auditBranchDeactivated => 'شعبه غیرفعال شد';

  @override
  String get auditBranchUpdated => 'شعبه تغییر کرد';

  @override
  String get auditCostValuationChanged => 'قیمت خرید جنس به‌روز شد';

  @override
  String get auditCustomerCreated => 'مشتری اضافه شد';

  @override
  String get auditCustomerCreditLimitChanged => 'حد قرض مشتری تغییر کرد';

  @override
  String get auditCustomerDeactivated => 'حساب مشتری بسته شد';

  @override
  String get auditCustomerReactivated => 'حساب مشتری دوباره باز شد';

  @override
  String get auditCustomerUpdated => 'مشتری تغییر کرد';

  @override
  String get auditDebtChargePosted => 'فروش قرضی ثبت شد';

  @override
  String get auditDebtPaymentRecorded => 'قرض مشتری پرداخت شد';

  @override
  String get auditDebtWrittenOff => 'قرض بخشیده شد';

  @override
  String get auditDiscountApplied => 'تخفیف داده شد';

  @override
  String get auditNotificationsRefreshed => 'اعلان‌ها به‌روز شد';

  @override
  String get auditOwnerBootstrapped => 'دکان راه‌اندازی شد';

  @override
  String get auditPasswordReset => 'رمز عبور تغییر داده شد';

  @override
  String get auditPaymentRecorded => 'پرداخت ثبت شد';

  @override
  String get auditProductCreated => 'جنس اضافه شد';

  @override
  String get auditProductDeactivated => 'جنس غیرفعال شد';

  @override
  String get auditProductPriceChanged => 'قیمت جنس تغییر کرد';

  @override
  String get auditProductUpdated => 'جنس تغییر کرد';

  @override
  String get auditPurchaseReceived => 'جنس از تهیه‌کننده رسید';

  @override
  String get auditRoleAssigned => 'نقش داده شد';

  @override
  String get auditRoleRevoked => 'نقش گرفته شد';

  @override
  String get auditSaleLineAdded => 'قلم به فروش اضافه شد';

  @override
  String get auditSaleSettled => 'فروش تکمیل شد';

  @override
  String get auditSaleVoided => 'فروش باطل شد';

  @override
  String get auditSessionReuseDetected => 'ورود مشکوک مسدود شد';

  @override
  String get auditShiftClosed => 'شیفت ختم شد';

  @override
  String get auditShiftOpened => 'شیفت آغاز شد';

  @override
  String get auditStockAdjusted => 'موجودی اصلاح شد';

  @override
  String get auditStockReceived => 'موجودی وارد شد';

  @override
  String get auditStockSold => 'موجودی فروخته شد';

  @override
  String get auditSupplierBillPosted => 'صورت‌حساب تهیه‌کننده ثبت شد';

  @override
  String get auditSupplierCreated => 'تهیه‌کننده اضافه شد';

  @override
  String get auditSupplierPaymentRecorded => 'به تهیه‌کننده پرداخت شد';

  @override
  String get auditSyncPull => 'دستگاه همگام شد';

  @override
  String get auditUnitCreated => 'واحد اضافه شد';

  @override
  String get auditUserAuthenticated => 'وارد شد';

  @override
  String get auditUserCreated => 'کارمند اضافه شد';

  @override
  String get auditUserDisabled => 'کارمند غیرفعال شد';

  @override
  String get auditUserEnabled => 'کارمند فعال شد';

  @override
  String get auditUserLoginFailed => 'ورود ناموفق';

  @override
  String get auditUserLogout => 'خارج شد';

  @override
  String get solarMonth1 => 'حمل';

  @override
  String get solarMonth2 => 'ثور';

  @override
  String get solarMonth3 => 'جوزا';

  @override
  String get solarMonth4 => 'سرطان';

  @override
  String get solarMonth5 => 'اسد';

  @override
  String get solarMonth6 => 'سنبله';

  @override
  String get solarMonth7 => 'میزان';

  @override
  String get solarMonth8 => 'عقرب';

  @override
  String get solarMonth9 => 'قوس';

  @override
  String get solarMonth10 => 'جدی';

  @override
  String get solarMonth11 => 'دلو';

  @override
  String get solarMonth12 => 'حوت';

  @override
  String solarDate(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String dateAndTime(String date, String time) {
    return '$date، $time';
  }

  @override
  String get symbolAfn => 'افغانی';

  @override
  String get symbolUsd => 'دالر';

  @override
  String get symbolPkr => 'کلدار';

  @override
  String get symbolEur => 'یورو';

  @override
  String moneyAmount(String amount, String currency) {
    return '$amount $currency';
  }

  @override
  String get shift => 'شیفت';

  @override
  String get category => 'دسته‌بندی';

  @override
  String get syncIssueOther => 'اطلاعات دیگر';

  @override
  String get errAccountDisabled =>
      'این حساب غیرفعال شده است. از مالک دکان بپرسید.';

  @override
  String get timeZoneKarachi => 'وقت کراچی';

  @override
  String get timeZoneTashkent => 'وقت تاشکند';

  @override
  String get timeZoneDushanbe => 'وقت دوشنبه';

  @override
  String get timeZoneDubai => 'وقت دبی';

  @override
  String get timeZoneTehran => 'وقت تهران';

  @override
  String get timeZoneUtc => 'زمان جهانی';
}
