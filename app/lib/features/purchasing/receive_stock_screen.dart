import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import '../customers/customers_providers.dart';
import '../pos/pos_providers.dart';

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
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _receive(List<Product> products) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null || !actor.can(Permission.stockAdjust) || _productId == null) {
      setState(() => _error = 'PERM');
      return;
    }
    final product = products.firstWhere((p) => p.id == _productId);
    final dp = ref.read(unitDecimalsProvider).maybeWhen(data: (m) => m[product.unitId] ?? 0, orElse: () => 0);
    int qtyMinor;
    try {
      qtyMinor = quantityToMinor(_qty.text, dp);
    } on AppError {
      setState(() => _error = 'QTY');
      return;
    }
    final costMinor = ((double.tryParse(_cost.text) ?? 0) * 100).round();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(localPurchasingProvider).receiveGoods(
            supplierId: _supplierId,
            lines: [ReceiptLine(productId: product.id, qtyMinor: qtyMinor, unitCostMinor: costMinor)],
            branchId: actor.branchId, actorId: actor.user.id, deviceId: 'app',
          );
      ref
        ..invalidate(productsProvider)
        ..invalidate(suppliersProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
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
              decoration: InputDecoration(labelText: l.quantityDelta, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cost,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l.unitCost, suffixText: 'AFN', border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
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
                child: Text(_error == 'PERM' ? l.permissionDenied : l.wrongSecret,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
