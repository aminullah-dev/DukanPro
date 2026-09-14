import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/number_input.dart';
import '../../widgets/locale_toggle.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import '../customers/customers_providers.dart';
import '../settings/settings_providers.dart';
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

  int _dpFor(Product p) =>
      ref.read(unitDecimalsProvider).maybeWhen(data: (m) => m[p.unitId] ?? 0, orElse: () => 0);

  Future<void> _charge(int total) async {
    final actor = ref.read(sessionActorProvider);
    final l = AppLocalizations.of(context);
    if (actor == null) return;
    final result = await showDialog<_PayResult>(
      context: context,
      builder: (_) => _PaymentDialog(totalMinor: total),
    );
    if (result == null) return;
    try {
      final lines = ref.read(posCartProvider.notifier).toSaleLines();
      final sales = ref.read(localSalesProvider);
      final sale = result.credit
          ? await sales.settle(
              lines: lines, cashMinor: result.cashMinor, tenderedMinor: result.tenderedMinor,
              customerId: result.customerId, customerCreditLimitMinor: result.creditLimit,
              branchId: actor.branchId, actorId: actor.user.id, deviceId: 'app',
            )
          : await sales.settleCash(
              lines: lines, tenderedMinor: result.tenderedMinor, branchId: actor.branchId,
              actorId: actor.user.id, deviceId: 'app',
            );
      final saleLines = await sales.saleLinesFor(sale.id);
      ref.read(posCartProvider.notifier).clear();
      ref
        ..invalidate(productsProvider)
        ..invalidate(customersProvider);
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => _ReceiptDialog(sale: sale, lines: saleLines),
        );
      }
    } on AppError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l.charge}: ${e.code}')));
      }
    }
  }

  Future<void> _addByBarcode(String code) async {
    final p = await ref.read(localCatalogProvider).products.findByBarcode(code.trim());
    if (p != null) ref.read(posCartProvider.notifier).add(p, _dpFor(p));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actor = ref.watch(sessionActorProvider);
    final canSell = actor?.can(Permission.saleCreate) ?? false;
    // Hands-free: a hardware scan adds the matching product to the cart.
    ref.listen(posScanProvider, (_, next) {
      if (canSell) next.whenData((e) => _addByBarcode(e.code));
    });
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(posCartProvider);
    final total = cart.fold<int>(0, (s, l) => s + l.lineTotal);

    return Scaffold(
      appBar: AppBar(title: Text(l.pos), actions: const [LocaleToggle(), SizedBox(width: 8)]),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l.searchHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                    onSubmitted: (code) async {
                      final p = await ref.read(localCatalogProvider).products.findByBarcode(code.trim());
                      if (p != null) ref.read(posCartProvider.notifier).add(p, _dpFor(p));
                    },
                  ),
                ),
                Expanded(
                  child: productsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (products) {
                      final q = _query.toLowerCase();
                      final items = q.isEmpty
                          ? products
                          : products.where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q)).toList();
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150, mainAxisExtent: 96, crossAxisSpacing: 10, mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final p = items[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: canSell ? () => ref.read(posCartProvider.notifier).add(p, _dpFor(p)) : null,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text('${_afn(p.sellPrice.amountMinor)} ${p.sellPrice.currency}',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
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
            ),
          ),
          Container(
            width: 340,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
            ),
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
                              title: Text(line.product.name),
                              subtitle: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => ref.read(posCartProvider.notifier).dec(i)),
                                  Text(line.qtyLabel),
                                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => ref.read(posCartProvider.notifier).inc(i)),
                                ],
                              ),
                              trailing: Text(_afn(line.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
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
                          Text('${_afn(total)} AFN', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: (canSell && cart.isNotEmpty) ? () => _charge(total) : null,
                          icon: const Icon(Icons.point_of_sale),
                          label: Text(l.charge),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayResult {
  const _PayResult({
    required this.credit,
    required this.cashMinor,
    required this.tenderedMinor,
    this.customerId,
    this.creditLimit,
  });
  final bool credit;
  final int cashMinor;
  final int tenderedMinor;
  final String? customerId;
  final int? creditLimit;
}

class _PaymentDialog extends ConsumerStatefulWidget {
  const _PaymentDialog({required this.totalMinor});
  final int totalMinor;
  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  late final TextEditingController _tendered =
      TextEditingController(text: _afn(widget.totalMinor));
  Customer? _customer;

  @override
  void dispose() {
    _tendered.dispose();
    super.dispose();
  }

  /// The cash received as typed, or null while it is not a valid amount.
  int? get _tenderedMinor {
    try {
      return amountOrNull(_tendered.text) ?? 0;
    } on AppError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tendered = _tenderedMinor;
    final change = tendered == null ? -1 : tendered - widget.totalMinor;
    final customersAsync = ref.watch(customersProvider);
    return AlertDialog(
      title: Text(l.charge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.total),
            Text('${_afn(widget.totalMinor)} AFN', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _tendered,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.tendered, border: const OutlineInputBorder(), suffixText: 'AFN',
              errorText: tendered == null ? l.errAmountInvalid : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.change),
            Text(change >= 0 ? '${_afn(change)} AFN' : '—',
                style: TextStyle(color: change >= 0 ? Colors.green.shade700 : Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          customersAsync.maybeWhen(
            data: (customers) => DropdownButtonFormField<String?>(
              initialValue: _customer?.id,
              decoration: InputDecoration(labelText: l.credit, isDense: true),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                for (final c in customers) DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (id) => setState(
                  () => _customer = id == null ? null : customers.firstWhere((c) => c.id == id)),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        if (_customer != null)
          FilledButton.tonal(
            onPressed: tendered == null
                ? null
                : () => Navigator.pop(
                      context,
                      _PayResult(
                        credit: true,
                        // Cash toward a credit sale is at most its total; the rest is the debt.
                        cashMinor: tendered > widget.totalMinor ? widget.totalMinor : tendered,
                        tenderedMinor: tendered,
                        customerId: _customer!.id,
                        creditLimit: _customer!.creditLimitMinor,
                      ),
                    ),
            child: Text(l.credit),
          ),
        FilledButton(
          onPressed: tendered != null && tendered >= widget.totalMinor
              ? () => Navigator.pop(
                    context,
                    _PayResult(credit: false, cashMinor: widget.totalMinor, tenderedMinor: tendered),
                  )
              : null,
          child: Text(l.cash),
        ),
      ],
    );
  }
}

class _ReceiptDialog extends ConsumerWidget {
  const _ReceiptDialog({required this.sale, required this.lines});
  final SaleRow sale;
  final List<SaleLineRow> lines;

  Future<void> _print(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final printer = ref.read(receiptPrinterProvider);
    if (printer == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.printerNotConfigured)));
      return;
    }
    final data = buildReceipt(shopName: ref.read(shopNameProvider), sale: sale, lines: lines);
    try {
      await printer.printRaw(const EscPosEncoder().encode(data));
      if (sale.paidMinor > 0) await printer.kickCashDrawer(); // cash sale → open drawer
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.printSucceeded)));
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.printFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Column(children: [
        Text(l.receipt),
        Text(sale.number, style: Theme.of(context).textTheme.bodySmall),
      ]),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final line in lines)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text('${line.name} ×${formatQuantity(line.qtyMinor, line.decimalPlaces)}')),
                Text(_afn(line.lineTotalMinor)),
              ]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.total, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${_afn(sale.totalMinor)} AFN', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.cash),
              Text('${_afn(sale.paidMinor + sale.changeMinor)} AFN'),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l.change),
              Text('${_afn(sale.changeMinor)} AFN'),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _print(context, ref, l),
          icon: const Icon(Icons.print_outlined),
          label: Text(l.printReceipt),
        ),
        FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.newSale)),
      ],
    );
  }
}
