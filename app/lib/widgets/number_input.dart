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
String? numberErrorText(AppLocalizations l, Object error) =>
    error is AppError ? numberCodeText(l, error.code) : null;

/// The sentence for a refused amount or quantity, by its code (null for any
/// other code).
String? numberCodeText(AppLocalizations l, String code) => switch (code) {
      'MONEY_AMOUNT_INVALID' || 'CATALOG_PRICE_INVALID' || 'CUSTOMER_CREDIT_LIMIT_INVALID' || 'SHIFT_CASH_INVALID' ||
      'SALE_LINE_INVALID_PRICE' =>
        l.errAmountInvalid,
      'CATALOG_QTY_INVALID' || 'STOCK_INVALID_QTY' => l.errQtyInvalid,
      'CATALOG_UNIT_PRECISION' => l.errQtyPrecision,
      'SALE_TOTAL_TOO_LARGE' || 'GRN_TOTAL_TOO_LARGE' => l.errTotalTooLarge,
      'GRN_LINE_INVALID' || 'DEBT_PAYMENT_INVALID' || 'DEBT_WRITE_OFF_INVALID' || 'SUPPLIER_PAYMENT_INVALID' ||
      'SALE_LINE_INVALID_QTY' || 'SALE_PAYMENT_INVALID' =>
        l.errMustBePositive,
      _ => null,
    };
