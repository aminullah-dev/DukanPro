import 'package:dukan_core/dukan_core.dart';

import '../l10n/app_localizations.dart';
import 'number_input.dart';

/// The sentence for a refusal about money: a typed amount, or a sale or debt
/// rule. Anything else shows its code, so a refusal is never silent.
String moneyErrorText(AppLocalizations l, AppError e) =>
    numberErrorText(l, e) ??
    switch (e.code) {
      'SALE_OVER_CREDIT_LIMIT' => l.errOverCreditLimit,
      'CUSTOMER_INACTIVE' => l.errCustomerInactive,
      'DEBT_CURRENCY_MISMATCH' => l.errDebtCurrency,
      'DEBT_OVERPAYMENT' => l.errDebtOverpayment,
      'DEBT_WRITE_OFF_EXCEEDS_BALANCE' => l.errWriteOffTooMuch,
      'SHIFT_NOT_OPEN' => l.errShiftNotOpen,
      'SHIFT_ALREADY_OPEN' => l.errShiftAlreadyOpen,
      final code => code,
    };
