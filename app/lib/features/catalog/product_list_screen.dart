import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/digits.dart';
import '../../widgets/bidi.dart';
import '../../widgets/money.dart';
import '../../widgets/labels.dart';
import '../../widgets/error_text.dart';
import '../../widgets/shell_scope.dart';
import '../auth/session.dart';
import 'catalog_providers.dart';
import 'product_edit_screen.dart';
import 'stock_adjust_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _query = '';

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    ref.invalidate(productsProvider);
  }

  Future<void> _onScan(String code) async {
    final product = await ref.read(localCatalogProvider).products.findByBarcode(normalizeDigits(code));
    if (!mounted || product == null) return;
    await _open(ProductEditScreen(product: product));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actor = ref.watch(sessionActorProvider);
    final canManage = actor?.can(Permission.productManage) ?? false;
    final async = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.products)),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(heroTag: null,
              onPressed: () => _open(const ProductEditScreen()),
              icon: const Icon(Icons.add),
              label: Text(l.addProduct),
            )
          : null,
      body: Column(
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
              onSubmitted: _onScan,
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorMessage(e),
              data: (products) {
                // A Dari keyboard's digits find what Latin ones do.
                final q = latinDigits(_query.trim()).toLowerCase();
                bool hit(String s) => latinDigits(s).toLowerCase().contains(q);
                final items = q.isEmpty ? products : products.where((p) => hit(p.name) || hit(p.sku)).toList();
                if (items.isEmpty) return Center(child: Text(l.noProducts));
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(ltr(p.sku)),
                      onTap: canManage ? () => _open(ProductEditScreen(product: p)) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.trackStock) _OnHandBadge(productId: p.id, branchId: actor?.branchId ?? '', unitId: p.unitId),
                          const SizedBox(width: 10),
                          Text(
                            formatMoney(AppLocalizations.of(context), p.sellPrice.amountMinor, p.sellPrice.currency),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (p.trackStock && (actor?.can(Permission.stockAdjust) ?? false))
                            IconButton(
                              tooltip: l.adjustStock,
                              icon: const Icon(Icons.tune),
                              onPressed: () => _open(StockAdjustScreen(product: p)),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OnHandBadge extends ConsumerWidget {
  const _OnHandBadge({required this.productId, required this.branchId, required this.unitId});
  final String productId;
  final String branchId;
  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(onHandProvider((productId, branchId)));
    final unit = ref.watch(unitsByIdProvider).value?[unitId];
    return async.maybeWhen(
      // In the product's unit: 2.500 kg, not 2500.
      data: (n) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text('${l.onHand}: ${unit == null ? '…' : '${formatQuantity(n, unit.decimalPlaces)} ${unitLabel(l, unit.id, unit.name)}'}'),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
