import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import 'catalog_providers.dart';

// Field bounds mirror the server's columns (docs/sync-protocol.md, "Push
// validation"), so a product saved here is never rejected at sync.

String? _requiredText(String? v, int maxLength) {
  final t = (v ?? '').trim();
  return (t.isEmpty || t.length > maxLength) ? '' : null;
}

String? _nonNegativeAmount(String? v) {
  final amount = double.tryParse(v ?? '');
  return (amount == null || !amount.isFinite || amount < 0) ? '' : null;
}

class ProductEditScreen extends ConsumerStatefulWidget {
  const ProductEditScreen({super.key, this.product});
  final Product? product;
  @override
  ConsumerState<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends ConsumerState<ProductEditScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _price;
  late final TextEditingController _barcode;
  String? _unitId;
  bool _track = true;
  bool _busy = false;
  String? _error; // 'PERM' | 'SKU'

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _price = TextEditingController(
        text: p == null ? '' : (p.sellPrice.amountMinor / 100).toStringAsFixed(2));
    _barcode = TextEditingController();
    _unitId = p?.unitId;
    _track = p?.trackStock ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _price.dispose();
    _barcode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final actor = ref.read(sessionActorProvider);
    if (actor == null || !actor.can(Permission.productManage)) {
      setState(() => _error = 'PERM');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final catalog = ref.read(localCatalogProvider);
    final priceMinor = ((double.tryParse(_price.text) ?? 0) * 100).round();
    try {
      if (_isNew) {
        if (await catalog.products.skuTaken(_sku.text.trim())) {
          setState(() {
            _busy = false;
            _error = 'SKU';
          });
          return;
        }
        final id = newId();
        final product = Product(
          id: id, sku: _sku.text.trim(), name: _name.text.trim(), unitId: _unitId!,
          sellPrice: Money(priceMinor, 'AFN'), trackStock: _track,
        );
        final barcodes = _barcode.text.trim().isEmpty
            ? <Barcode>[]
            : [Barcode(id: newId(), productId: id, code: _barcode.text.trim())];
        await catalog.createProduct(product, barcodes: barcodes, actorId: actor.user.id, deviceId: 'app');
      } else {
        final p = widget.product!;
        final product = Product(
          id: p.id, sku: p.sku, name: _name.text.trim(), unitId: p.unitId,
          sellPrice: Money(priceMinor, 'AFN'), categoryId: p.categoryId, cost: p.cost,
          trackStock: _track, isActive: p.isActive, version: p.version,
        );
        await catalog.updateProduct(product, actorId: actor.user.id, deviceId: 'app');
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final units = ref.watch(unitsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l.addProduct : l.editProduct)),
      body: units.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (unitRows) {
          _unitId ??= unitRows.isNotEmpty ? unitRows.first.id : null;
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l.productName, border: const OutlineInputBorder()),
                  validator: (v) => _requiredText(v, 200),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sku,
                  readOnly: !_isNew,
                  decoration: InputDecoration(labelText: l.sku, border: const OutlineInputBorder()),
                  validator: (v) => _requiredText(v, 64),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _unitId,
                  decoration: InputDecoration(labelText: l.unit, border: const OutlineInputBorder()),
                  items: [for (final u in unitRows) DropdownMenuItem(value: u.id, child: Text(u.name))],
                  onChanged: _isNew ? (v) => setState(() => _unitId = v) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.price, suffixText: 'AFN', border: const OutlineInputBorder()),
                  validator: _nonNegativeAmount,
                ),
                const SizedBox(height: 12),
                if (_isNew)
                  TextFormField(
                    controller: _barcode,
                    decoration: InputDecoration(labelText: l.barcodeLabel, border: const OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().length > 64 ? '' : null,
                  ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.trackStock),
                  value: _track,
                  onChanged: (v) => setState(() => _track = v),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _error == 'PERM' ? l.permissionDenied : l.skuTaken,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
