import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/money.dart';
import '../../widgets/dates.dart';
import '../../widgets/labels.dart';
import '../../widgets/shell_scope.dart';
import '../../widgets/error_text.dart';
import '../../widgets/number_input.dart';
import '../../widgets/locale_toggle.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import '../customers/customers_providers.dart';
import '../settings/settings_providers.dart';
import '../auth/providers.dart';
import '../read_models.dart';
import 'pos_providers.dart';
import 'receipt_builder.dart';

String _afn(int minor) => formatQuantity(minor, 2);

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});
  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String _query = '';
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  /// Set while a sale is being charged: the cart is frozen and scans wait, so
  /// what is settled is exactly what the cashier confirmed.
  bool _charging = false;

  /// Whether this POS is the one on screen: not a pane hidden in the shell, not
  /// under a dialog (see build). Only then do scans reach it.
  bool _visible = true;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Adds [p] in its unit. While the units are not loaded, or the product's
  /// unit is missing, nothing is added and the cashier is told why, rather than
  /// selling kilograms as whole pieces.
  void _add(Product p) {
    if (_charging) return;
    final unit = ref.read(unitsByIdProvider).value?[p.unitId];
    if (unit == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errUnitUnknown)));
      return;
    }
    ref.read(posCartProvider.notifier).add(p, unit.decimalPlaces, unitName: unitLabel(AppLocalizations.of(context), unit.id, unit.name));
  }

  Future<void> _editQty(int i, CartLine line) async {
    final qty = await showDialog<int>(context: context, builder: (_) => _QtyDialog(line: line));
    if (qty != null && !_charging) ref.read(posCartProvider.notifier).setQty(i, qty);
  }

  Future<void> _charge() async {
    final actor = ref.read(sessionActorProvider);
    final shift = ref.read(currentShiftProvider).value;
    final l = AppLocalizations.of(context);
    if (actor == null || shift == null || _charging) return;
    // The sale is the cart as it stood when Charge was pressed.
    final lines = ref.read(posCartProvider.notifier).toSaleLines();
    if (lines.isEmpty) return;
    setState(() => _charging = true);
    try {
      final result = await showDialog<_PayResult>(
        context: context,
        builder: (_) => _PaymentDialog(totalMinor: computeTotals(lines).totalMinor),
      );
      if (result == null) return;
      final sales = ref.read(localSalesProvider);
      final sale = await sales.settle(
        lines: lines, tenders: result.tenders, customerId: result.customerId, shiftId: shift.id,
        branchId: actor.branchId, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider),
      );
      final saleLines = await sales.saleLinesFor(sale.id);
      ref.read(posCartProvider.notifier).clear();
      refreshReadModels(ref.invalidate);
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => _ReceiptDialog(
            sale: sale, lines: saleLines,
            // The drawer opens for cash taken now, never for a reprint.
            openDrawer: result.tenders.any((t) => t.method == PaymentMethod.cash),
          ),
        );
      }
    } on AppError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appErrorText(l, e))));
      }
    } finally {
      if (mounted) setState(() => _charging = false);
    }
  }

  /// Opens the seller's shift with the cash already in the drawer.
  Future<void> _openShift(int openingFloatMinor) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    try {
      await ref.read(localShiftsProvider).open(
            branchId: actor.branchId, userId: actor.user.id, openingFloatMinor: openingFloatMinor,
            deviceId: ref.read(deviceIdProvider),
          );
    } on AppError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(appErrorText(AppLocalizations.of(context), e))));
      }
    }
    ref.invalidate(currentShiftProvider);
  }

  /// The Z-report: what the shift took by tender and what the drawer should
  /// hold; closing records the counted cash and the difference.
  Future<void> _closeShift(ShiftRow shift) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final shifts = ref.read(localShiftsProvider);
    final summary = await shifts.summary(shift);
    if (!mounted) return;
    final counted = await showDialog<int>(context: context, builder: (_) => _ZReportDialog(summary: summary));
    if (counted == null) return;
    final closed = await shifts.close(
      shift, countedCashMinor: counted, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider),
    );
    ref.invalidate(currentShiftProvider);
    if (mounted) {
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.shiftClosed(amountText(closed.varianceMinor ?? 0)))));
    }
  }

  Future<void> _addByBarcode(String code) async {
    final p = await ref.read(localCatalogProvider).products.findByBarcode(normalizeDigits(code));
    if (p != null && mounted) _add(p);
  }

  /// Typed or scanned into the search field: a barcode adds its product and
  /// clears the field; anything else stays a name search. (A scanner's keys land
  /// here while the field has focus, so the scan listener leaves them alone.)
  Future<void> _submitSearch(String text) async {
    final p = await ref.read(localCatalogProvider).products.findByBarcode(normalizeDigits(text));
    if (p == null || !mounted) return;
    _add(p);
    _search.clear();
    setState(() => _query = '');
  }

  /// This device's latest sales, to reprint one's receipt.
  Future<void> _recentSales() async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final sales = ref.read(localSalesProvider);
    final recent = await sales.recent(branchId: actor.branchId);
    if (!mounted) return;
    final picked = await showDialog<SaleRow>(context: context, builder: (_) => _RecentSalesDialog(zone: ref.read(branchZoneProvider), sales: recent));
    if (picked == null) return;
    final lines = await sales.saleLinesFor(picked.id);
    if (mounted) {
      await showDialog<void>(context: context, builder: (_) => _ReceiptDialog(sale: picked, lines: lines));
    }
  }

  void _openCart(AppLocalizations l, bool canSell) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.75,
        child: Consumer(
          builder: (context, ref, _) => _cartPanel(
            context, l, ref.watch(posCartProvider), canSell,
            onCharge: () {
              Navigator.pop(sheetContext);
              _charge();
            },
          ),
        ),
      ),
    );
  }

  Widget _productPane(BuildContext context, AppLocalizations l, AsyncValue<List<Product>> productsAsync, bool canSell) {
    // Cards grow with the reader's text size, so a 7-digit price still fits.
    final scale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 2.0);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _search,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.searchHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
            onSubmitted: _submitSearch,
          ),
        ),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorMessage(e),
            data: (products) {
              final q = _query.toLowerCase();
              final items = q.isEmpty
                  ? products
                  : products.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150, mainAxisExtent: 96 * scale, crossAxisSpacing: 10, mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final p = items[i];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: canSell ? () => _add(p) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(formatMoney(AppLocalizations.of(context), p.sellPrice.amountMinor, p.sellPrice.currency),
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cartPanel(
    BuildContext context,
    AppLocalizations l,
    List<CartLine> cart,
    bool canSell, {
    required VoidCallback onCharge,
  }) {
    final total = cart.fold<int>(0, (s, l) => s + l.lineTotal);
    return IgnorePointer(
      ignoring: _charging,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [Text(l.cartTitle, style: Theme.of(context).textTheme.titleMedium)]),
          ),
          Expanded(
            child: cart.isEmpty
                ? Center(child: Text(l.emptyCart))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final line = cart[i];
                      return ListTile(
                        dense: true,
                        title: Text(line.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        // Compact, so the line's total beside it leaves the buttons room.
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => ref.read(posCartProvider.notifier).dec(i),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () => _editQty(i, line),
                                child: Text(line.qtyLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => ref.read(posCartProvider.notifier).inc(i),
                            ),
                          ],
                        ),
                        trailing: Text(amountText(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.total, style: Theme.of(context).textTheme.titleLarge),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(formatMoney(AppLocalizations.of(context), total, shopCurrencyOf(context)),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: canSell && cart.isNotEmpty && !_charging ? onCharge : null,
                    icon: const Icon(Icons.point_of_sale),
                    label: Text(l.charge),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// On a phone the cart is a bar under the products; it opens as a sheet.
  Widget _cartBar(AppLocalizations l, List<CartLine> cart, bool canSell) {
    final total = cart.fold<int>(0, (s, l) => s + l.lineTotal);
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openCart(l, canSell),
                icon: Badge(
                  label: Text('${cart.length}'),
                  isLabelVisible: cart.isNotEmpty,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                label: FittedBox(fit: BoxFit.scaleDown, child: Text(formatMoney(AppLocalizations.of(context), total, shopCurrencyOf(context)))),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: canSell && cart.isNotEmpty && !_charging ? _charge : null,
              icon: const Icon(Icons.point_of_sale),
              label: Text(l.charge),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actor = ref.watch(sessionActorProvider);
    final canSell = actor?.can(Permission.saleCreate) ?? false;
    // A pane hidden in the shell runs with tickers off; a dialog on top makes
    // this route not current. Scans go only to the POS in front of the cashier.
    _visible = TickerMode.valuesOf(context).enabled && (ModalRoute.of(context)?.isCurrent ?? true);
    ref.listen(posScanProvider, (_, next) {
      // With the search field focused the scanner's keys arrive there too, and
      // onSubmitted adds the product: one path per scan.
      if (canSell && _visible && !_charging && !_searchFocus.hasFocus) {
        next.whenData((e) => _addByBarcode(e.code));
      }
    });
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(posCartProvider);
    ref.watch(unitsByIdProvider); // loaded before the first tap
    final shiftAsync = ref.watch(currentShiftProvider);

    final Widget body;
    if (!shiftAsync.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (canSell && shiftAsync.value == null) {
      // A seller opens a shift before the first sale (its cash needs a drawer).
      body = _OpenShiftPanel(onOpen: _openShift);
    } else {
      body = LayoutBuilder(
        builder: (context, box) {
          final products = _productPane(context, l, productsAsync, canSell);
          if (box.maxWidth < 720) {
            return Column(children: [Expanded(child: products), _cartBar(l, cart, canSell)]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: products),
              Container(
                width: 340,
                decoration: BoxDecoration(border: Border(left: BorderSide(color: Theme.of(context).dividerColor))),
                child: _cartPanel(context, l, cart, canSell, onCharge: _charge),
              ),
            ],
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.pos), actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined),
          tooltip: l.recentSales,
          onPressed: _recentSales,
        ),
        if (shiftAsync.value case final shift?)
          IconButton(
            icon: const Icon(Icons.lock_clock_outlined),
            tooltip: l.closeShift,
            onPressed: () => _closeShift(shift),
          ),
        const LocaleToggle(),
        const SizedBox(width: 8),
      ]),
      body: body,
    );
  }
}

class _PayResult {
  const _PayResult({required this.tenders, this.customerId});
  final List<Tender> tenders;
  final String? customerId;
}

class _PaymentDialog extends ConsumerStatefulWidget {
  const _PaymentDialog({required this.totalMinor});
  final int totalMinor;
  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

/// One payment line in the dialog: a method and the amount given by it.
class _TenderLine {
  _TenderLine(this.method, String amount) : amount = TextEditingController(text: amount);
  PaymentMethod method;
  final TextEditingController amount;
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  late final List<_TenderLine> _lines = [_TenderLine(PaymentMethod.cash, _afn(widget.totalMinor))];
  final List<_TenderLine> _removed = [];
  Customer? _customer;

  @override
  void dispose() {
    for (final t in [..._lines, ..._removed]) {
      t.amount.dispose();
    }
    super.dispose();
  }

  /// The payments as typed: cash toward the total, with what was handed over,
  /// then card and transfer. Null while an amount is not valid, or card and
  /// transfer come to more than the total (they give no change).
  ({List<Tender> tenders, int change, int remaining})? get _split {
    var cashGiven = 0;
    final other = <Tender>[];
    for (final t in _lines) {
      final int amount;
      try {
        amount = amountOrNull(t.amount.text) ?? 0;
      } on AppError {
        return null;
      }
      if (amount == 0) continue;
      if (t.method == PaymentMethod.cash) {
        cashGiven += amount;
      } else {
        other.add(Tender(t.method, amount));
      }
    }
    final otherTotal = other.fold<int>(0, (s, t) => s + t.amountMinor);
    if (otherTotal > widget.totalMinor) return null;
    final due = widget.totalMinor - otherTotal;
    final cash = cashGiven < due ? cashGiven : due;
    return (
      tenders: [if (cash > 0) Tender(PaymentMethod.cash, cash, tenderedMinor: cashGiven), ...other],
      change: cashGiven - cash,
      remaining: due - cash,
    );
  }

  /// With a customer, the payments are what is paid now and the rest goes on
  /// credit: picking one clears the prefilled total (and back again).
  void _pick(Customer? c) {
    final first = _lines.first.amount;
    if (c != null && _customer == null && first.text == _afn(widget.totalMinor)) first.text = _afn(0);
    if (c == null && _customer != null && first.text == _afn(0)) first.text = _afn(widget.totalMinor);
    setState(() => _customer = c);
  }

  String _methodName(AppLocalizations l, PaymentMethod m) => switch (m) {
        PaymentMethod.cash => l.cash,
        PaymentMethod.card => l.card,
        PaymentMethod.transfer => l.transfer,
        PaymentMethod.credit => l.credit,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final split = _split;
    final customersAsync = ref.watch(customersProvider);
    // What goes on the customer's account: the total less what is paid now.
    final onCredit = _customer != null && split != null ? split.remaining : 0;
    Widget amountRow(String label, int value, {Color? color}) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(formatMoney(l, value, shopCurrencyOf(context)), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        );
    return AlertDialog(
      title: Text(l.charge),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            amountRow(l.total, widget.totalMinor),
            const SizedBox(height: 12),
            for (final (i, t) in _lines.indexed) ...[
              Row(children: [
                DropdownButton<PaymentMethod>(
                  value: t.method,
                  items: [
                    for (final m in const [PaymentMethod.cash, PaymentMethod.card, PaymentMethod.transfer])
                      DropdownMenuItem(value: m, child: Text(_methodName(l, m))),
                  ],
                  onChanged: (m) => setState(() => t.method = m ?? t.method),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: t.amount,
                    autofocus: i == 0,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: t.method != PaymentMethod.cash
                          ? l.amount
                          : _customer == null
                              ? l.tendered
                              : l.cashNow,
                      suffixText: currencySymbol(l, shopCurrencyOf(context)),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_lines.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _removed.add(_lines.removeAt(i))),
                  ),
              ]),
              const SizedBox(height: 8),
            ],
            if (_lines.length < 3)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _lines.add(
                        _TenderLine(PaymentMethod.card, split == null ? '' : _afn(split.remaining)),
                      )),
                  icon: const Icon(Icons.add),
                  label: Text(l.addPayment),
                ),
              ),
            if (split == null)
              Text(l.errAmountInvalid, style: TextStyle(color: Theme.of(context).colorScheme.error))
            else if (onCredit > 0)
              amountRow(l.onCredit, onCredit, color: Theme.of(context).colorScheme.error)
            else if (split.remaining > 0)
              amountRow(l.remaining, split.remaining, color: Theme.of(context).colorScheme.error)
            else
              amountRow(l.change, split.change, color: Colors.green.shade700),
            const SizedBox(height: 8),
            customersAsync.maybeWhen(
              // A search, not a list of every customer. Credit goes only to open
              // accounts.
              data: (customers) => Autocomplete<Customer>(
                displayStringForOption: (c) => c.name,
                optionsBuilder: (value) {
                  final q = value.text.trim().toLowerCase();
                  final open = customers.where((c) => c.isActive);
                  return (q.isEmpty
                          ? open
                          : open.where((c) => c.name.toLowerCase().contains(q) || (c.phone ?? '').contains(q)))
                      .take(20);
                },
                onSelected: _pick,
                fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
                  controller: controller,
                  focusNode: focus,
                  onSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    labelText: l.credit,
                    hintText: l.searchCustomer,
                    isDense: true,
                    suffixIcon: _customer == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              _pick(null);
                            },
                          ),
                  ),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        if (_customer != null)
          FilledButton.tonal(
            // Credit is for what is left after what is paid now.
            onPressed: split != null && onCredit > 0
                ? () => Navigator.pop(context, _PayResult(tenders: split.tenders, customerId: _customer!.id))
                : null,
            child: Text(l.credit),
          ),
        FilledButton(
          onPressed: split != null && split.remaining == 0
              ? () => Navigator.pop(context, _PayResult(tenders: split.tenders))
              : null,
          child: Text(l.charge),
        ),
      ],
    );
  }
}

/// Before the first sale: the seller opens their shift with the cash already in
/// the drawer (the float), so the close can say what should be there.
class _OpenShiftPanel extends StatefulWidget {
  const _OpenShiftPanel({required this.onOpen});
  final Future<void> Function(int openingFloatMinor) onOpen;
  @override
  State<_OpenShiftPanel> createState() => _OpenShiftPanelState();
}

class _OpenShiftPanelState extends State<_OpenShiftPanel> {
  final _float = TextEditingController(text: _afn(0));
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Future<void> _open(AppLocalizations l) async {
    final int amount;
    try {
      amount = amountOrNull(_float.text) ?? 0;
    } on AppError catch (e) {
      setState(() => _error = numberErrorText(l, e));
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onOpen(amount);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.point_of_sale, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(l.openShiftPrompt, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(
                  controller: _float,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l.openingFloat, suffixText: currencySymbol(l, shopCurrencyOf(context)), errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _open(l),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _busy ? null : () => _open(l), child: Text(l.openShift)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The shift report at the close: what the shift took by tender, what the
/// drawer should hold, and the difference from the cash counted.
class _ZReportDialog extends StatefulWidget {
  const _ZReportDialog({required this.summary});
  final ShiftSummary summary;
  @override
  State<_ZReportDialog> createState() => _ZReportDialogState();
}

class _ZReportDialogState extends State<_ZReportDialog> {
  final _counted = TextEditingController();

  @override
  void dispose() {
    _counted.dispose();
    super.dispose();
  }

  int? get _countedMinor {
    try {
      return amountOrNull(_counted.text);
    } on AppError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.summary;
    final counted = _countedMinor;
    final difference = counted == null ? null : counted - s.expectedCashMinor;
    Widget row(String label, int value, {bool bold = false, Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(label)),
            Text(formatMoney(l, value, shopCurrencyOf(context)),
                style: TextStyle(fontWeight: bold ? FontWeight.bold : null, color: color)),
          ]),
        );
    return AlertDialog(
      title: Text(l.zReport),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          row(l.openingFloat, s.openingFloatMinor),
          row(l.cashSales, s.cashSalesMinor),
          row(l.debtCollected, s.cashCollectedMinor),
          if (s.cashPaidOutMinor > 0) row(l.paidToSuppliers, -s.cashPaidOutMinor),
          row(l.cardSales, s.cardSalesMinor),
          row(l.transferSales, s.transferSalesMinor),
          const Divider(),
          row(l.expectedCash, s.expectedCashMinor, bold: true),
          const SizedBox(height: 12),
          TextField(
            controller: _counted,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.countedCash, suffixText: currencySymbol(l, shopCurrencyOf(context)), border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (difference != null) ...[
            const SizedBox(height: 8),
            row(l.variance, difference,
                bold: true,
                color: difference < 0 ? Theme.of(context).colorScheme.error : Colors.green.shade700),
          ],
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: counted == null ? null : () => Navigator.pop(context, counted),
          child: Text(l.closeShift),
        ),
      ],
    );
  }
}

/// A sale's receipt, printable. [openDrawer] kicks the cash drawer after a new
/// cash sale; a reprint never opens it.
class _ReceiptDialog extends ConsumerStatefulWidget {
  const _ReceiptDialog({required this.sale, required this.lines, this.openDrawer = false});
  final SaleRow sale;
  final List<SaleLineRow> lines;
  final bool openDrawer;
  @override
  ConsumerState<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends ConsumerState<_ReceiptDialog> {
  bool _printing = false;

  void _say(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _print(AppLocalizations l) async {
    final printer = ref.read(receiptPrinterProvider);
    if (printer == null) {
      _say(l.printerNotConfigured);
      return;
    }
    setState(() => _printing = true);
    try {
      final data = buildReceipt(
        shopName: ref.read(shopNameProvider), sale: widget.sale, lines: widget.lines,
        zone: ref.read(branchZoneProvider),
      );
      // A printer that stops answering must not hold the till.
      await printer.printRaw(const EscPosEncoder().encode(data)).timeout(const Duration(seconds: 10));
    } on Object {
      _say(l.printFailed);
      if (mounted) setState(() => _printing = false);
      return;
    }
    var drawerOk = true;
    if (widget.openDrawer) {
      try {
        await printer.kickCashDrawer().timeout(const Duration(seconds: 5));
      } on Object {
        drawerOk = false; // the receipt did print: say that the drawer failed, not the print
      }
    }
    _say(drawerOk ? l.printSucceeded : l.drawerFailed);
    if (mounted) setState(() => _printing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sale = widget.sale;
    return AlertDialog(
      scrollable: true,
      title: Column(children: [
        Text(l.receipt),
        Text(sale.number, style: Theme.of(context).textTheme.bodySmall),
        if (sale.status == 'voided')
          Text(l.voided, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final line in widget.lines)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text('${line.name} ×${formatQuantity(line.qtyMinor, line.decimalPlaces)}')),
                Text(amountText(line.lineTotalMinor)),
              ]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.total, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(formatMoney(l, sale.totalMinor, sale.currency), style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.paid),
              Text(formatMoney(l, sale.paidMinor + sale.changeMinor, sale.currency)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.change),
              Text(formatMoney(l, sale.changeMinor, sale.currency)),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _printing ? null : () => _print(l),
          icon: _printing
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.print_outlined),
          label: Text(l.printReceipt),
        ),
        FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.newSale)),
      ],
    );
  }
}

/// This device's latest sales: pick one to see and reprint its receipt.
class _RecentSalesDialog extends StatelessWidget {
  const _RecentSalesDialog({required this.sales, required this.zone});
  final List<SaleRow> sales;
  final String zone; // the branch's clock

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.recentSales),
      content: SizedBox(
        width: 360,
        height: 420,
        child: sales.isEmpty
            ? Center(child: Text(l.noRecentSales))
            : ListView.separated(
                itemCount: sales.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = sales[i];
                  final time = formatTime(l, s.occurredAt, zone);
                  return ListTile(
                    dense: true,
                    title: Text(s.number, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(s.status == 'voided' ? '$time · ${l.voided}' : time),
                    trailing: Text(formatMoney(l, s.totalMinor, s.currency)),
                    onTap: () => Navigator.pop(context, s),
                  );
                },
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel))],
    );
  }
}

/// Type a cart line's quantity, e.g. 0.750 kg of sugar, in Persian or Latin
/// digits.
class _QtyDialog extends StatefulWidget {
  const _QtyDialog({required this.line});
  final CartLine line;
  @override
  State<_QtyDialog> createState() => _QtyDialogState();
}

class _QtyDialogState extends State<_QtyDialog> {
  late final _qty =
      TextEditingController(text: formatQuantity(widget.line.qtyMinor, widget.line.decimalPlaces));
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l) {
    try {
      final qty = quantityToMinor(_qty.text, widget.line.decimalPlaces);
      if (qty <= 0) {
        setState(() => _error = l.errMustBePositive);
        return;
      }
      Navigator.pop(context, qty);
    } on AppError catch (e) {
      setState(() => _error = numberErrorText(l, e) ?? l.errQtyInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text('${l.editQuantity} · ${widget.line.product.name}'),
      content: TextField(
        controller: _qty,
        autofocus: true,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.line.decimalPlaces > 0),
        decoration: InputDecoration(suffixText: widget.line.unitName, errorText: _error),
        onSubmitted: (_) => _save(l),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: () => _save(l), child: Text(l.save)),
      ],
    );
  }
}
