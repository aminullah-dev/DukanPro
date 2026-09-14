import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/number_input.dart';
import '../auth/session.dart';
import 'catalog_providers.dart';

class StockAdjustScreen extends ConsumerStatefulWidget {
  const StockAdjustScreen({super.key, required this.product});
  final Product product;
  @override
  ConsumerState<StockAdjustScreen> createState() => _StockAdjustScreenState();
}

class _StockAdjustScreenState extends ConsumerState<StockAdjustScreen> {
  final _qty = TextEditingController();
  bool _busy = false;
  String? _error; // a message ready to show

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  Future<void> _apply(int decimalPlaces) async {
    final l = AppLocalizations.of(context);
    final actor = ref.read(sessionActorProvider);
    if (actor == null || !actor.can(Permission.stockAdjust)) {
      setState(() => _error = l.permissionDenied);
      return;
    }
    late final int qtyDelta;
    try {
      qtyDelta = quantityToMinor(_qty.text, decimalPlaces);
    } on AppError catch (e) {
      setState(() => _error = numberErrorText(l, e) ?? l.errGeneric);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final branchId = actor.branchId;
    try {
      await ref.read(localCatalogProvider).adjust(
            productId: widget.product.id,
            branchId: branchId,
            qtyDelta: qtyDelta,
            actorId: actor.user.id,
            deviceId: 'app',
          );
      ref.invalidate(onHandProvider((widget.product.id, branchId)));
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
    final actor = ref.watch(sessionActorProvider);
    final branchId = actor?.branchId ?? '';
    final units = ref.watch(unitsProvider);
    final onHand = ref.watch(onHandProvider((widget.product.id, branchId)));

    return Scaffold(
      appBar: AppBar(title: Text('${l.adjustStock} · ${widget.product.name}')),
      body: units.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (unitRows) {
          var decimalPlaces = 0;
          for (final u in unitRows) {
            if (u.id == widget.product.unitId) {
              decimalPlaces = u.decimalPlaces;
              break;
            }
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(l.onHand),
                trailing: Text(
                  onHand.maybeWhen(data: (n) => '$n', orElse: () => '…'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qty,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(labelText: l.quantityDelta, border: const OutlineInputBorder()),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : () => _apply(decimalPlaces),
                child: _busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
