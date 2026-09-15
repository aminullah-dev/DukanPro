// Theme 9a: what the app shows for codes and counts. Every refusal reads as a
// sentence in the user's language, stored codes get labels, a sentence keeps
// one digit system, the chosen language survives a restart, and Pashto text
// fields have a copy and paste menu on Apple platforms.
import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukanpro/composition.dart';
import 'package:dukanpro/features/dashboard/dashboard_screen.dart';
import 'package:dukanpro/features/sync/sync_issues_screen.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:dukanpro/widgets/error_text.dart';
import 'package:dukanpro/widgets/labels.dart';
import 'package:dukanpro/widgets/localization_delegates.dart';
import 'package:dukanpro/widgets/money.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The codes the device's own rules raise, and those the server answers with.
const _codes = [
  'BARCODE_DUPLICATE', 'BRANCH_INACTIVE', 'BRANCH_LAST_ACTIVE', 'CATALOG_PRICE_INVALID',
  'CATALOG_QTY_INVALID', 'CATALOG_UNIT_PRECISION', 'CUSTOMER_CREDIT_LIMIT_INVALID', 'CUSTOMER_INACTIVE',
  'CUSTOMER_NOT_FOUND', 'DEBT_CURRENCY_MISMATCH', 'DEBT_OVERPAYMENT', 'DEBT_PAYMENT_INVALID',
  'DEBT_WRITE_OFF_EXCEEDS_BALANCE', 'DEBT_WRITE_OFF_INVALID', 'GRN_LINE_INVALID', 'GRN_TOTAL_TOO_LARGE',
  'MONEY_AMOUNT_INVALID', 'MONEY_CURRENCY_INVALID', 'OUTBOX_OP_NOT_FOUND', 'PRODUCT_DUPLICATE_SKU',
  'PRODUCT_NOT_FOUND', 'PRODUCT_NOT_STOCK_TRACKED', 'ROLE_BUILTIN_IMMUTABLE', 'ROLE_UNKNOWN',
  'SALE_CURRENCY_MISMATCH', 'SALE_DISCOUNT_INVALID', 'SALE_EMPTY', 'SALE_LINE_INVALID_PRICE',
  'SALE_LINE_INVALID_QTY', 'SALE_OVERPAID', 'SALE_OVER_CREDIT_LIMIT', 'SALE_PAYMENT_INVALID',
  'SALE_TOTAL_TOO_LARGE', 'SALE_UNDERPAID', 'SHIFT_ALREADY_CLOSED', 'SHIFT_ALREADY_OPEN',
  'SHIFT_CASH_INVALID', 'SHIFT_NOT_OPEN', 'STOCK_INVALID_QTY', 'SUPPLIER_OVERPAYMENT',
  'SUPPLIER_PAYMENT_INVALID', 'USER_DUPLICATE_USERNAME', 'USER_LAST_ASSIGNMENT', 'USER_LAST_OWNER',
  'WEAK_PASSWORD', 'ACCESS_DENIED', 'STOCK_INSUFFICIENT', 'SALE_NOT_VOIDABLE',
  'SALE_SHIFT_CLOSED', 'PRICE_CURRENCY_INVALID', 'PURCHASE_CURRENCY_MISMATCH', 'GRN_EMPTY',
  'UNIT_NOT_FOUND', 'INVALID_CREDENTIALS', 'USER_DISABLED', 'SESSION_REVOKED',
  'SYNC_FIELD_INVALID', 'SYNC_REF_MISMATCH', 'PRODUCT_VERSION_CONFLICT', 'SYNC_UNAVAILABLE',
];

/// Every action the server writes to the audit trail.
const _auditActions = [
  'barcode.added', 'barcode.removed', 'branch.activated', 'branch.created',
  'branch.deactivated', 'branch.updated', 'cost.valuation_changed', 'customer.created',
  'customer.credit_limit_changed', 'customer.deactivated', 'customer.reactivated', 'customer.updated',
  'debt.charge_posted', 'debt.payment_recorded', 'debt.written_off', 'discount.applied',
  'notifications.refreshed', 'owner.bootstrapped', 'password.reset', 'payment.recorded',
  'product.created', 'product.deactivated', 'product.price_changed', 'product.updated',
  'purchase.received', 'role.assigned', 'role.revoked', 'sale.line_added',
  'sale.settled', 'sale.voided', 'session.reuse_detected', 'shift.closed',
  'shift.opened', 'stock.adjusted', 'stock.received', 'stock.sold',
  'supplier.bill_posted', 'supplier.created', 'supplier.payment_recorded', 'sync.pull',
  'unit.created', 'user.authenticated', 'user.created', 'user.disabled',
  'user.enabled', 'user.login_failed', 'user.logout',
];

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fa = lookupAppLocalizations(const Locale('fa', 'AF'));
  final ps = lookupAppLocalizations(const Locale('ps'));

  test('every known error code reads as a sentence, never as the code', () {
    for (final l in [en, fa, ps]) {
      for (final code in _codes) {
        final text = appErrorText(l, ValidationError(code));
        expect(text, isNot(contains(code)), reason: code);
        expect(text, isNot(l.errGeneric), reason: '$code has no sentence of its own');
      }
    }
  });

  test('failures that are not refusals read as sentences too', () {
    expect(appErrorText(fa, const NetworkException()), fa.errNetwork);
    expect(appErrorText(fa, const AuthApiException('USER_LAST_OWNER')), fa.errUserLastOwner);
    expect(appErrorText(fa, StateError('SqliteException(5): database is locked')), fa.errGeneric);
    expect(errorCodeText(fa, 'SYNC_FIELD_NOT_ALLOWED'), fa.errInvalid);
    expect(errorCodeText(fa, 'NOTIFICATION_NOT_FOUND'), fa.errNotFound);
    expect(errorCodeText(fa, 'CUSTOMER_VERSION_CONFLICT'), fa.errConflict);
  });

  testWidgets('a screen that cannot load says why in a sentence', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('fa', 'AF'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ErrorMessage(ValidationError('SALE_EMPTY'))),
    ));
    expect(find.text(fa.errSaleEmpty), findsOneWidget);
    expect(find.textContaining('SALE_EMPTY'), findsNothing);
  });

  test('audit actions, built-in units, time zones and currencies have labels', () {
    for (final l in [en, fa, ps]) {
      for (final action in _auditActions) {
        expect(auditActionLabel(l, action), isNot(l.auditOther), reason: action);
      }
    }
    expect(auditActionLabel(fa, 'something.new'), fa.auditOther);
    final piece = builtInUnits.first;
    expect(unitLabel(fa, piece.id, piece.name), fa.unitPiece);
    expect(unitLabel(ps, builtInUnits[1].id, 'kg'), ps.unitKg);
    expect(unitLabel(fa, newId(), 'بوجی'), 'بوجی'); // a shop's own unit keeps its name
    expect(timeZoneLabel(fa, 'Asia/Kabul'), fa.timeZoneKabul);
    expect(currencyLabel(ps, 'AFN'), ps.currencyAfn);
  });

  test('a count inside a sentence is written in one digit system', () {
    expect(fa.syncPending(1), contains('۱'));
    expect(fa.syncPending(21), contains('۲۱'));
    expect(ps.syncConflicts(1), contains('۱'));
    expect(en.syncPending(1234), '1,234 changes to sync');
    expect(en.insightDigest(1), '1 sale today');
    expect(fa.insightDeadStock('برنج', 30), contains('۳۰'));
  });

  test('the chosen language is saved and used from the next launch', () {
    Locale? saved;
    final container = ProviderContainer(overrides: [
      savedLocaleProvider.overrideWithValue(const Locale('ps')),
      saveLocaleProvider.overrideWithValue((locale) => saved = locale),
    ]);
    addTearDown(container.dispose);
    expect(container.read(localeProvider), const Locale('ps'));
    container.read(localeProvider.notifier).set(const Locale('en'));
    expect(saved, const Locale('en'));
    const supported = AppLocalizations.supportedLocales;
    expect(localeFromTag(localeTag(const Locale('fa', 'AF')), supported), const Locale('fa', 'AF'));
    expect(localeFromTag('xx', supported), isNull);
    expect(ProviderContainer().read(localeProvider), const Locale('fa', 'AF')); // a new install
  });

  testWidgets('Pashto text fields get the copy and paste menu strings on Apple platforms', (tester) async {
    CupertinoLocalizations? cupertino;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ps'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        cupertino = Localizations.of<CupertinoLocalizations>(context, CupertinoLocalizations);
        return const SizedBox();
      }),
    ));
    expect(cupertino?.pasteButtonLabel, isNotEmpty);
  });

  test('every synced table and every branch zone has a label', () {
    for (final table in ['products', 'barcodes', 'units', 'categories', 'customers', 'suppliers',
      'stock_movements', 'sales', 'sale_lines', 'payments', 'customer_ledger', 'supplier_ledger', 'shifts']) {
      expect(syncTableLabel(fa, table), isNot(table), reason: table);
    }
    expect(syncTableLabel(fa, 'something_new'), fa.syncIssueOther);
    for (final zone in branchZoneOffsets.keys) {
      expect(timeZoneLabel(ps, zone), isNot(zone), reason: zone);
    }
    expect(errorCodeText(fa, 'USER_DISABLED'), fa.errAccountDisabled); // signing in again cannot help
    // The shift-close sentence takes its amount with the currency, not a fixed AFN.
    expect(en.shiftClosed(formatMoney(en, -500, 'USD')), allOf(contains('USD'), isNot(contains('AFN'))));
  });

  testWidgets("the dashboard's top sellers name built-in units in the user's language", (tester) async {
    final kg = builtInUnits[1];
    final container = ProviderContainer(overrides: [
      dashboardProvider.overrideWith((ref) async => DashboardData(
            salesTodayMinor: 0, profitTodayMinor: 0, outstandingDebtMinor: 0, lowStockCount: 0,
            topSellers: [TopSeller('برنج', 1500, decimalPlaces: 3, unitName: kg.name, unitId: kg.id)],
          )),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('fa', 'AF'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DashboardScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('1.500 ${fa.unitKg}'), findsOneWidget);
    expect(find.textContaining('kg'), findsNothing);
  });
}


