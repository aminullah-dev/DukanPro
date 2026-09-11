import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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
    final product = await ref.read(localCatalogProvider).products.findByBarcode(code.trim());
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
      appBar: AppBar(title: Text(l.products)),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
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
              error: (e, _) => Center(child: Text('$e')),
              data: (products) {
                final q = _query.toLowerCase();
                final items = q.isEmpty
                    ? products
                    : products
                        .where((p) => p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
                        .toList();
                if (items.isEmpty) return Center(child: Text(l.noProducts));
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(p.sku),
                      onTap: canManage ? () => _open(ProductEditScreen(product: p)) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.trackStock) _OnHandBadge(productId: p.id, branchId: actor?.branchId ?? ''),
                          const SizedBox(width: 10),
                          Text(
                            '${(p.sellPrice.amountMinor / 100).toStringAsFixed(2)} ${p.sellPrice.currency}',
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
  const _OnHandBadge({required this.productId, required this.branchId});
  final String productId;
  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(onHandProvider((productId, branchId)));
    return async.maybeWhen(
      data: (n) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text('${l.onHand}: $n'),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
