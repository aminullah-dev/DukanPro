import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/number_input.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import '../customers/customers_providers.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  const ReceiveStockScreen({super.key});
  @override
  ConsumerState<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  String? _productId;
  String? _supplierId;
  final _qty = TextEditingController();
  final _cost = TextEditingController();
  bool _busy = false;
  String? _error; // a message ready to show

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _receive(List<Product> products) async {
    final l = AppLocalizations.of(context);
    final actor = ref.read(sessionActorProvider);
    if (actor == null || !actor.can(Permission.stockAdjust)) {
      setState(() => _error = l.permissionDenied);
      return;
    }
    if (_productId == null) {
      setState(() => _error = l.errChooseProduct);
      return;
    }
    final product = products.firstWhere((p) => p.id == _productId);
    final unit = ref.read(unitsByIdProvider).value?[product.unitId];
    if (unit == null) {
      setState(() => _error = l.errUnitUnknown);
      return;
    }
    final dp = unit.decimalPlaces;
    // A cost or a supplier bill needs purchase.cost; without it, or with no cost
    // typed, a receipt only moves stock.
    final canCost = actor.can(Permission.purchaseCost);
    late final ReceiptLine line;
    try {
      line = ReceiptLine(
        productId: product.id,
        qtyMinor: quantityToMinor(_qty.text, dp),
        unitCostMinor: canCost ? (amountOrNull(_cost.text) ?? 0) : 0,
        decimalPlaces: dp,
      );
      assertReceivable(line);
    } on AppError catch (e) {
      setState(() => _error = numberErrorText(l, e) ?? l.errGeneric);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(localPurchasingProvider).receiveGoods(
            supplierId: canCost ? _supplierId : null,
            lines: [line],
            branchId: actor.branchId, actorId: actor.user.id, deviceId: 'app',
          );
      ref
        ..invalidate(productsProvider)
        ..invalidate(suppliersProvider);
      if (mounted) Navigator.of(context).pop();
    } on AppError catch (e) {
      if (mounted) setState(() => _error = numberErrorText(l, e) ?? l.errGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsProvider);
    ref.watch(unitsByIdProvider); // loaded before the first receipt
    final suppliersAsync = ref.watch(suppliersProvider);
    final canCost = ref.watch(sessionActorProvider)?.can(Permission.purchaseCost) ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l.receiveStock)),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (products) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _productId,
              decoration: InputDecoration(labelText: l.products, border: const OutlineInputBorder()),
              items: [for (final p in products) DropdownMenuItem(value: p.id, child: Text(p.name))],
              onChanged: (v) => setState(() => _productId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l.quantityReceived, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (canCost) ...[
              TextField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.unitCost, suffixText: 'AFN', border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
            ],
            if (canCost)
              suppliersAsync.maybeWhen(
              data: (suppliers) => DropdownButtonFormField<String>(
                initialValue: _supplierId,
                decoration: InputDecoration(labelText: l.supplier, border: const OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  for (final s in suppliers) DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _supplierId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : () => _receive(products),
              icon: const Icon(Icons.add_box_outlined),
              label: Text(l.receive),
            ),
          ],
        ),
      ),
    );
  }
}
