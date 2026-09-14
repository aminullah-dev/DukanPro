import 'package:dukan_core/dukan_core.dart';

import '../l10n/app_localizations.dart';

/// An amount of money typed by the user, in AFN minor units: Persian or Latin
/// digits, `.` or `٫`, never negative. Null when the field is empty. Throws
/// [ValidationError] `MONEY_AMOUNT_INVALID`.
int? amountOrNull(String text) {
  if (text.trim().isEmpty) return null;
  final minor = moneyToMinor(text);
  if (minor < 0) throw ValidationError('MONEY_AMOUNT_INVALID', {'input': text});
  return minor;
}

/// The sentence for a typed number (or amount) the domain refused, or null for
/// any other error.
String? numberErrorText(AppLocalizations l, Object error) => switch (error) {
      AppError(code: 'MONEY_AMOUNT_INVALID' || 'CATALOG_PRICE_INVALID' || 'CUSTOMER_CREDIT_LIMIT_INVALID') =>
        l.errAmountInvalid,
      AppError(code: 'CATALOG_QTY_INVALID' || 'STOCK_INVALID_QTY') => l.errQtyInvalid,
      AppError(code: 'CATALOG_UNIT_PRECISION') => l.errQtyPrecision,
      AppError(code: 'GRN_LINE_INVALID' || 'DEBT_PAYMENT_INVALID' || 'SALE_LINE_INVALID_QTY') =>
        l.errMustBePositive,
      _ => null,
    };
