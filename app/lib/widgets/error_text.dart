import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;

import '../infrastructure/auth_api.dart' show AuthApiException, NetworkException;
import '../l10n/app_localizations.dart';
import 'number_input.dart';

/// The sentence for a failure a screen shows: a refusal by a rule on the device
/// or the server, a lost connection, or anything else. Never a code or an
/// exception's text (docs/localization.md).
String appErrorText(AppLocalizations l, Object error) => switch (error) {
      ProviderException(:final exception) => appErrorText(l, exception),
      NetworkException() => l.errNetwork,
      AuthApiException(:final code) || AppError(:final code) => errorCodeText(l, code),
      _ => l.errGeneric,
    };

/// The sentence for an error code from the device or the server. A code with no
/// sentence of its own reads as its family (gone, changed meanwhile, not
/// accepted), and anything else as a generic failure.
String errorCodeText(AppLocalizations l, String code) =>
    numberCodeText(l, code) ??
    switch (code) {
      'NETWORK' || 'SYNC_UNAVAILABLE' => l.errNetwork,
      'ACCESS_DENIED' || 'ROLE_BUILTIN_IMMUTABLE' => l.permissionDenied,
      'SALE_EMPTY' || 'GRN_EMPTY' => l.errSaleEmpty,
      'SALE_UNDERPAID' => l.errUnderpaid,
      'SALE_OVERPAID' => l.errOverpaid,
      'SALE_DISCOUNT_INVALID' => l.errDiscountInvalid,
      'SALE_NOT_VOIDABLE' => l.errSaleNotVoidable,
      'SALE_OVER_CREDIT_LIMIT' => l.errOverCreditLimit,
      'STOCK_INSUFFICIENT' => l.errStockInsufficient,
      'CUSTOMER_INACTIVE' => l.errCustomerInactive,
      'DEBT_CURRENCY_MISMATCH' => l.errDebtCurrency,
      'DEBT_OVERPAYMENT' => l.errDebtOverpayment,
      'DEBT_WRITE_OFF_EXCEEDS_BALANCE' => l.errWriteOffTooMuch,
      'SUPPLIER_OVERPAYMENT' => l.errSupplierOverpayment,
      'SALE_CURRENCY_MISMATCH' || 'PURCHASE_CURRENCY_MISMATCH' || 'PRICE_CURRENCY_INVALID' || 'MONEY_CURRENCY_INVALID' =>
        l.errCurrencyMismatch,
      'SHIFT_NOT_OPEN' || 'SALE_SHIFT_CLOSED' => l.errShiftNotOpen,
      'SHIFT_ALREADY_OPEN' => l.errShiftAlreadyOpen,
      'SHIFT_ALREADY_CLOSED' => l.errShiftAlreadyClosed,
      'BARCODE_DUPLICATE' => l.errBarcodeTaken,
      'PRODUCT_DUPLICATE_SKU' => l.skuTaken,
      'PRODUCT_NOT_STOCK_TRACKED' => l.errNotStockTracked,
      'UNIT_NOT_FOUND' => l.errUnitUnknown,
      'BRANCH_INACTIVE' => l.errBranchInactive,
      'BRANCH_LAST_ACTIVE' => l.errBranchLastActive,
      'USER_LAST_OWNER' => l.errUserLastOwner,
      'USER_LAST_ASSIGNMENT' => l.errUserLastAssignment,
      'USER_DUPLICATE_USERNAME' => l.errUsernameTaken,
      'WEAK_PASSWORD' => l.errWeakPassword,
      'INVALID_CREDENTIALS' => l.loginFailed,
      'OFFLINE_EXPIRED' => l.errOfflineExpired,
      'STORAGE_UNAVAILABLE' => l.errStorage,
      'SETUP_TOKEN_INVALID' => l.errSetupCode,
      'BOOTSTRAP_ALREADY_DONE' => l.errBootstrapDone,
      'USER_DISABLED' => l.errAccountDisabled,
      'SESSION_REVOKED' || 'REFRESH_INVALID' || 'TOKEN_INVALID' => l.errSessionEnded,
      // Asked of the server by a till: the sale has not synced there yet.
      'SALE_NOT_FOUND' => l.errSaleNotSynced,
      'SALE_VOID_REASON_REQUIRED' => l.errVoidReasonRequired,
      'REFUND_QTY_INVALID' => l.errRefundQty,
      'SALE_NOT_REFUNDABLE' => l.errSaleNotRefundable,
      'REFUND_REASON_REQUIRED' => l.errRefundReason,
      _ when code.endsWith('_NOT_FOUND') => l.errNotFound,
      _ when code.endsWith('_VERSION_CONFLICT') || code == 'SYNC_ROW_EXISTS' => l.errConflict,
      _ when code.endsWith('_INVALID') || code.startsWith('SYNC_') || code == 'ROLE_UNKNOWN' => l.errInvalid,
      _ => l.errGeneric,
    };

/// A failure shown in place of a screen's content.
class ErrorMessage extends StatelessWidget {
  const ErrorMessage(this.error, {super.key});
  final Object error;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(appErrorText(AppLocalizations.of(context), error), textAlign: TextAlign.center),
        ),
      );
}
