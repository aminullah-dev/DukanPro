import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/money.dart';
import '../../widgets/labels.dart';
import '../../widgets/error_text.dart';
import '../../widgets/number_input.dart';
import '../auth/session.dart';
import '../auth/providers.dart';
import 'catalog_providers.dart';

// Field bounds mirror the server's columns (docs/sync-protocol.md, "Push
// validation"), so a product saved here is never rejected at sync.

String? _requiredText(AppLocalizations l, String? v, int maxLength) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return l.errRequired;
  return t.length > maxLength ? l.errTooLong : null;
}

/// A price: an amount of zero or more, typed with Persian or Latin digits.
String? _priceError(AppLocalizations l, String? v) {
  try {
    final minor = amountOrNull(v ?? '');
    if (minor == null) return l.errRequired;
    assertPriceValid(sellPriceMinor: minor);
    return null;
  } on AppError catch (e) {
    return numberErrorText(l, e) ?? l.errAmountInvalid;
  }
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
  bool _active = true;
  bool _busy = false;
  String? _error; // a message ready to show

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _price = TextEditingController(
        text: p == null ? '' : formatQuantity(p.sellPrice.amountMinor, 2));
    _barcode = TextEditingController();
    _unitId = p?.unitId;
    _track = p?.trackStock ?? true;
    _active = p?.isActive ?? true;
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
    final l = AppLocalizations.of(context);
    final actor = ref.read(sessionActorProvider);
    if (actor == null || !actor.can(Permission.productManage)) {
      setState(() => _error = l.permissionDenied);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final catalog = ref.read(localCatalogProvider);
    final priceMinor = amountOrNull(_price.text) ?? 0; // the form validated it
    try {
      if (_isNew) {
        if (await catalog.products.skuTaken(_sku.text.trim())) {
          setState(() {
            _busy = false;
            _error = l.skuTaken;
          });
          return;
        }
        final id = newId();
        final product = Product(
          id: id, sku: _sku.text.trim(), name: _name.text.trim(), unitId: _unitId!,
          sellPrice: Money(priceMinor, ref.read(shopCurrencyProvider)), trackStock: _track,
        );
        final barcodes = _barcode.text.trim().isEmpty
            ? <Barcode>[]
            : [Barcode(id: newId(), productId: id, code: _barcode.text.trim())];
        await catalog.createProduct(product, barcodes: barcodes, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider));
      } else {
        final p = widget.product!;
        final product = Product(
          id: p.id, sku: _sku.text.trim(), name: _name.text.trim(), unitId: p.unitId,
          sellPrice: Money(priceMinor, p.sellPrice.currency), categoryId: p.categoryId, cost: p.cost, // keeps its currency
          trackStock: _track, isActive: _active, version: p.version,
        );
        await catalog.updateProduct(product, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider));
      }
      if (mounted) Navigator.of(context).pop();
    } on AppError catch (e) {
      if (mounted) setState(() => _error = appErrorText(l, e));
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
        error: (e, _) => ErrorMessage(e),
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
                  validator: (v) => _requiredText(l, v, 200),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sku, // a mistyped SKU can be corrected
                  decoration: InputDecoration(labelText: l.sku, border: const OutlineInputBorder()),
                  validator: (v) => _requiredText(l, v, 64),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _unitId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.unit, border: const OutlineInputBorder()),
                  items: [
                    for (final u in unitRows)
                      DropdownMenuItem(value: u.id, child: Text(unitLabel(l, u.id, u.name), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: _isNew ? (v) => setState(() => _unitId = v) : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.price, suffixText: currencySymbol(l, widget.product?.sellPrice.currency ?? ref.watch(shopCurrencyProvider)), border: const OutlineInputBorder()),
                  validator: (v) => _priceError(l, v),
                ),
                const SizedBox(height: 12),
                if (_isNew)
                  TextFormField(
                    controller: _barcode,
                    decoration: InputDecoration(labelText: l.barcodeLabel, border: const OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().length > 64 ? l.errTooLong : null,
                  ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.trackStock),
                  value: _track,
                  onChanged: (v) => setState(() => _track = v),
                ),
                if (!_isNew) ...[
                  // An inactive product is not sold, and keeps its barcodes.
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.productActive),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  _Barcodes(productId: widget.product!.id),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _error!,
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

/// A product's barcodes: a code is on one product only, so moving one means
/// taking it off here first.
class _Barcodes extends ConsumerStatefulWidget {
  const _Barcodes({required this.productId});
  final String productId;
  @override
  ConsumerState<_Barcodes> createState() => _BarcodesState();
}

class _BarcodesState extends ConsumerState<_Barcodes> {
  final _code = TextEditingController();
  List<Barcode> _codes = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final codes = await ref.read(localCatalogProvider).products.barcodesFor(widget.productId);
    if (mounted) setState(() => _codes = codes);
  }

  Future<void> _change(Future<void> Function(LocalCatalog catalog, String actorId, String deviceId) write) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    try {
      await write(ref.read(localCatalogProvider), actor.user.id, ref.read(deviceIdProvider));
      if (mounted) setState(() => _error = null);
      _code.clear();
    } on AppError catch (e) {
      if (mounted) setState(() => _error = appErrorText(AppLocalizations.of(context), e));
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(l.barcodes, style: Theme.of(context).textTheme.titleSmall),
        for (final b in _codes)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(b.code),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l.removeBarcode,
              onPressed: () => _change((c, actor, device) => c.removeBarcode(b.id, actorId: actor, deviceId: device)),
            ),
          ),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _code,
              decoration: InputDecoration(labelText: l.barcodeLabel, errorText: _error, isDense: true),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l.addBarcode,
            onPressed: () {
              final code = _code.text.trim();
              if (code.isEmpty || code.length > 64) return;
              _change((c, actor, device) => c.addBarcode(widget.productId, code, actorId: actor, deviceId: device));
            },
          ),
        ]),
      ],
    );
  }
}
