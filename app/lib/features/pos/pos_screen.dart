import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/locale_toggle.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import 'pos_providers.dart';

String _afn(int minor) => (minor / 100).toStringAsFixed(2);

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
    final tendered = await showDialog<int>(
      context: context,
      builder: (_) => _PaymentDialog(totalMinor: total),
    );
    if (tendered == null) return;
    try {
      final lines = ref.read(posCartProvider.notifier).toSaleLines();
      final sales = ref.read(localSalesProvider);
      final sale = await sales.settleCash(
        lines: lines, tenderedMinor: tendered, branchId: actor.branchId,
        actorId: actor.user.id, deviceId: 'app',
      );
      final saleLines = await sales.saleLinesFor(sale.id);
      ref.read(posCartProvider.notifier).clear();
      ref.invalidate(productsProvider);
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actor = ref.watch(sessionActorProvider);
    final canSell = actor?.can(Permission.saleCreate) ?? false;
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

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.totalMinor});
  final int totalMinor;
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late final TextEditingController _tendered =
      TextEditingController(text: _afn(widget.totalMinor));

  @override
  void dispose() {
    _tendered.dispose();
    super.dispose();
  }

  int get _tenderedMinor => ((double.tryParse(_tendered.text) ?? 0) * 100).round();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final change = _tenderedMinor - widget.totalMinor;
    return AlertDialog(
      title: Text(l.cash),
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
            decoration: InputDecoration(labelText: l.tendered, border: const OutlineInputBorder(), suffixText: 'AFN'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l.change),
            Text(change >= 0 ? '${_afn(change)} AFN' : '—',
                style: TextStyle(color: change >= 0 ? Colors.green.shade700 : Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _tenderedMinor >= widget.totalMinor ? () => Navigator.pop(context, _tenderedMinor) : null,
          child: Text(l.charge),
        ),
      ],
    );
  }
}

class _ReceiptDialog extends StatelessWidget {
  const _ReceiptDialog({required this.sale, required this.lines});
  final SaleRow sale;
  final List<SaleLineRow> lines;

  @override
  Widget build(BuildContext context) {
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
        FilledButton(onPressed: () => Navigator.pop(context), child: Text(l.newSale)),
      ],
    );
  }
}
