import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/camera_scan_button.dart';
import '../../widgets/digits.dart';
import '../../widgets/money.dart';
import '../../widgets/labels.dart';
import '../../widgets/shell_scope.dart';
import '../../widgets/error_text.dart';
import '../../widgets/number_input.dart';
import '../auth/providers.dart';
import '../auth/session.dart';
import '../catalog/catalog_providers.dart';
import '../customers/customers_providers.dart';
import '../read_models.dart';

class ReceiveStockScreen extends ConsumerStatefulWidget {
  const ReceiveStockScreen({super.key});
  @override
  ConsumerState<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends ConsumerState<ReceiveStockScreen> {
  Product? _product;
  String? _supplierId;
  final _qty = TextEditingController();
  final _cost = TextEditingController();
  int _form = 0; // a fresh form after each receipt: the product picker starts empty
  bool _busy = false;
  String? _error; // a message ready to show

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _receive() async {
    final l = AppLocalizations.of(context);
    final actor = ref.read(sessionActorProvider);
    if (actor == null || !actor.can(Permission.stockAdjust)) {
      setState(() => _error = l.permissionDenied);
      return;
    }
    final product = _product;
    if (product == null) {
      setState(() => _error = l.errChooseProduct);
      return;
    }
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
      setState(() => _error = appErrorText(l, e));
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
            branchId: actor.branchId, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider),
          );
      refreshReadModels(ref.invalidate);
      if (!mounted) return;
      // Pushed from a phone's home, the screen goes back; as a pane of the shell
      // it stays, cleared and ready for the next delivery.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.receivedOk)));
      setState(() {
        _product = null;
        _qty.clear();
        _cost.clear();
        _form++;
      });
    } on AppError catch (e) {
      if (mounted) setState(() => _error = appErrorText(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final productsAsync = ref.watch(productsProvider);
    final units = ref.watch(unitsByIdProvider).value; // loaded before the first receipt
    final suppliersAsync = ref.watch(suppliersProvider);
    final canCost = ref.watch(sessionActorProvider)?.can(Permission.purchaseCost) ?? false;
    final unit = _product == null ? null : units?[_product!.unitId];
    final unitName = unit == null ? null : unitLabel(AppLocalizations.of(context), unit.id, unit.name);
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.receiveStock)),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorMessage(e),
        data: (products) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // A search, not a list of every product: a shop has thousands.
            Autocomplete<Product>(
              key: ValueKey(_form),
              displayStringForOption: (p) => p.name,
              optionsBuilder: (value) {
                // A Dari keyboard's digits find what Latin ones do.
                final q = latinDigits(value.text.trim()).toLowerCase();
                if (q.isEmpty) return const Iterable<Product>.empty();
                bool hit(String s) => latinDigits(s).toLowerCase().contains(q);
                return products.where((p) => hit(p.name) || hit(p.sku)).take(20);
              },
              onSelected: (p) => setState(() => _product = p),
              fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
                controller: controller,
                focusNode: focus,
                onSubmitted: (_) => onSubmit(),
                onChanged: (_) {
                  if (_product != null && controller.text != _product!.name) setState(() => _product = null);
                },
                decoration: InputDecoration(
                  labelText: l.products, hintText: l.searchHint, border: const OutlineInputBorder(),
                  // The search matches names and SKUs; a barcode the camera read picks its product.
                  suffixIcon: ref.watch(cameraScanProvider) == null
                      ? null
                      : CameraScanButton(
                          onScanned: (code) async {
                            final p = await ref.read(localCatalogProvider).products.findByBarcode(normalizeDigits(code));
                            if (!mounted) return;
                            if (p == null) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(this.context).barcodeNoProduct)),
                              );
                              return;
                            }
                            controller.text = p.name;
                            focus.unfocus();
                            setState(() => _product = p);
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l.quantityReceived, suffixText: unitName, border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (canCost) ...[
              TextField(
                controller: _cost,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.unitCost, suffixText: currencySymbol(l, shopCurrencyOf(context)), border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              suppliersAsync.maybeWhen(
                data: (suppliers) => DropdownButtonFormField<String>(
                  initialValue: _supplierId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.supplier, border: const OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('—')),
                    for (final s in suppliers)
                      DropdownMenuItem(value: s.id, child: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) => setState(() => _supplierId = v),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _receive,
              icon: const Icon(Icons.add_box_outlined),
              label: Text(l.receive),
            ),
          ],
        ),
      ),
    );
  }
}
