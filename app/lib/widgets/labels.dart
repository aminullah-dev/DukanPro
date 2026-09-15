import 'package:dukan_core/dukan_core.dart' show builtInUnits;

import '../l10n/app_localizations.dart';

// Labels for values stored as codes: a code is never shown as it is
// (docs/localization.md). Roles are in features/iam/iam_ui.dart.

/// What an audit entry records, in the active language.
String auditActionLabel(AppLocalizations l, String action) => switch (action) {
      'barcode.added' => l.auditBarcodeAdded,
      'barcode.removed' => l.auditBarcodeRemoved,
      'branch.activated' => l.auditBranchActivated,
      'branch.created' => l.auditBranchCreated,
      'branch.deactivated' => l.auditBranchDeactivated,
      'branch.updated' => l.auditBranchUpdated,
      'cost.valuation_changed' => l.auditCostValuationChanged,
      'customer.created' => l.auditCustomerCreated,
      'customer.credit_limit_changed' => l.auditCustomerCreditLimitChanged,
      'customer.deactivated' => l.auditCustomerDeactivated,
      'customer.reactivated' => l.auditCustomerReactivated,
      'customer.updated' => l.auditCustomerUpdated,
      'debt.charge_posted' => l.auditDebtChargePosted,
      'debt.payment_recorded' => l.auditDebtPaymentRecorded,
      'debt.written_off' => l.auditDebtWrittenOff,
      'discount.applied' => l.auditDiscountApplied,
      'notifications.refreshed' => l.auditNotificationsRefreshed,
      'owner.bootstrapped' => l.auditOwnerBootstrapped,
      'password.reset' => l.auditPasswordReset,
      'payment.recorded' => l.auditPaymentRecorded,
      'product.created' => l.auditProductCreated,
      'product.deactivated' => l.auditProductDeactivated,
      'product.price_changed' => l.auditProductPriceChanged,
      'product.updated' => l.auditProductUpdated,
      'purchase.received' => l.auditPurchaseReceived,
      'role.assigned' => l.auditRoleAssigned,
      'role.revoked' => l.auditRoleRevoked,
      'sale.line_added' => l.auditSaleLineAdded,
      'sale.settled' => l.auditSaleSettled,
      'sale.voided' => l.auditSaleVoided,
      'session.reuse_detected' => l.auditSessionReuseDetected,
      'shift.closed' => l.auditShiftClosed,
      'shift.opened' => l.auditShiftOpened,
      'stock.adjusted' => l.auditStockAdjusted,
      'stock.received' => l.auditStockReceived,
      'stock.sold' => l.auditStockSold,
      'supplier.bill_posted' => l.auditSupplierBillPosted,
      'supplier.created' => l.auditSupplierCreated,
      'supplier.payment_recorded' => l.auditSupplierPaymentRecorded,
      'sync.pull' => l.auditSyncPull,
      'unit.created' => l.auditUnitCreated,
      'user.authenticated' => l.auditUserAuthenticated,
      'user.created' => l.auditUserCreated,
      'user.disabled' => l.auditUserDisabled,
      'user.enabled' => l.auditUserEnabled,
      'user.login_failed' => l.auditUserLoginFailed,
      'user.logout' => l.auditUserLogout,
      _ => l.auditOther,
    };

/// A unit's name: the built-in units (known by their fixed ids) in the active
/// language, a shop's own units as the shop named them.
String unitLabel(AppLocalizations l, String id, String name) {
  for (final unit in builtInUnits) {
    if (unit.id != id) continue;
    return switch (unit.name) {
      'piece' => l.unitPiece,
      'kg' => l.unitKg,
      'litre' => l.unitLitre,
      'dozen' => l.unitDozen,
      'meter' => l.unitMeter,
      _ => name,
    };
  }
  return name;
}

/// A branch's time zone.
String timeZoneLabel(AppLocalizations l, String zone) => switch (zone) {
      'Asia/Kabul' => l.timeZoneKabul,
      'Asia/Karachi' => l.timeZoneKarachi,
      'Asia/Tashkent' => l.timeZoneTashkent,
      'Asia/Dushanbe' => l.timeZoneDushanbe,
      'Asia/Dubai' => l.timeZoneDubai,
      'Asia/Tehran' => l.timeZoneTehran,
      'UTC' => l.timeZoneUtc,
      _ => zone,
    };

/// A currency's name.
String currencyLabel(AppLocalizations l, String code) => switch (code) {
      'AFN' => l.currencyAfn,
      'USD' => l.currencyUsd,
      'PKR' => l.currencyPkr,
      'EUR' => l.currencyEur,
      _ => code,
    };
