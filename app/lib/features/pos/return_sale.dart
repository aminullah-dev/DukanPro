import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/bidi.dart';
import '../../widgets/error_text.dart';
import '../../widgets/money.dart';
import '../auth/session.dart';
import 'pos_providers.dart';

/// Takes goods back from the sale on show, for someone allowed to (sale.void):
/// a settled sale that is not itself a return. What it can still take back
/// comes from the returns this device has pulled.
class ReturnItemsButton extends ConsumerWidget {
  const ReturnItemsButton({
    required this.sale,
    required this.lines,
    required this.settled,
    required this.onReturned,
    super.key,
  });
  final SaleRow sale;
  final List<SaleLineRow> lines;
  final bool settled;
  final ValueChanged<RefundDone> onReturned;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sales = ref.read(localSalesProvider);
    final returnable = await sales.returnable(sale.id);
    final earlier = await sales.returnsOf(sale.id);
    if (!context.mounted) return;
    if (returnable.values.every((q) => q <= 0)) {
      messenger.showSnackBar(SnackBar(content: Text(l.returnNothingLeft)));
      return;
    }
    final done = await showDialog<RefundDone>(
      context: context,
      builder: (_) => ReturnDialog(
        sale: sale,
        lines: lines,
        returnable: returnable,
        earlierReturnsMinor: earlier.fold(0, (sum, r) => sum + r.totalMinor),
      ),
    );
    if (done == null) return;
    messenger.showSnackBar(SnackBar(
      content: Text(done.moneyBackMinor > 0
          ? l.returnDoneGiveBack(formatMoney(l, done.moneyBackMinor, sale.currency))
          : l.returnDoneAccount),
    ));
    onReturned(done);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final allowed = ref.watch(sessionActorProvider)?.can(Permission.saleVoid) ?? false;
    if (!allowed || !settled || sale.refundOf != null) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: () => _open(context, ref),
      icon: const Icon(Icons.assignment_return_outlined),
      label: Text(l.returnItems),
    );
  }
}

/// One product of the sale: its lines taken together.
final class _Product {
  _Product(this.id, this.name, this.decimalPlaces);
  final String id;
  final String name;
  final int decimalPlaces;
  int soldQty = 0;
  int soldValue = 0;
}

/// Picks what comes back and how the money goes back, and shows what it is
/// worth before anything is asked of the server.
class ReturnDialog extends ConsumerStatefulWidget {
  const ReturnDialog({
    required this.sale,
    required this.lines,
    required this.returnable,
    required this.earlierReturnsMinor,
    super.key,
  });
  final SaleRow sale;
  final List<SaleLineRow> lines;

  /// What of each product can still come back.
  final Map<String, int> returnable;

  /// The totals of the returns already made (negative).
  final int earlierReturnsMinor;

  @override
  ConsumerState<ReturnDialog> createState() => _ReturnDialogState();
}

class _ReturnDialogState extends ConsumerState<ReturnDialog> {
  late final List<_Product> _products;
  final _qty = <String, TextEditingController>{};
  final _reason = TextEditingController();
  String _method = 'cash';
  bool _busy = false;
  String? _refusal; // the server's answer, until the next edit

  @override
  void initState() {
    super.initState();
    final byId = <String, _Product>{};
    for (final line in widget.lines) {
      final p = byId.putIfAbsent(line.productId, () => _Product(line.productId, line.name, line.decimalPlaces));
      p.soldQty += line.qtyMinor;
      p.soldValue += line.lineTotalMinor;
    }
    _products = [for (final p in byId.values) if ((widget.returnable[p.id] ?? 0) > 0) p];
    for (final p in _products) {
      _qty[p.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _qty.values) {
      c.dispose();
    }
    _reason.dispose();
    super.dispose();
  }

  void _edited() => setState(() => _refusal = null);

  /// The typed quantities by product, or the sentence for the first one that
  /// is not a quantity or is more than can come back.
  (Map<String, int>, String?) _wanted(AppLocalizations l) {
    final wanted = <String, int>{};
    for (final p in _products) {
      final text = _qty[p.id]!.text.trim();
      if (text.isEmpty) continue;
      final int qty;
      try {
        qty = quantityToMinor(text, p.decimalPlaces);
      } on AppError catch (e) {
        return (wanted, appErrorText(l, e));
      }
      if (qty == 0) continue;
      if (qty < 0 || qty > (widget.returnable[p.id] ?? 0)) return (wanted, l.errRefundQty);
      wanted[p.id] = qty;
    }
    return (wanted, null);
  }

  /// What [wanted] is worth, as the server counts it: the last return takes
  /// what is left of the sale.
  int _worth(Map<String, int> wanted) {
    var gross = 0;
    for (final p in _products) {
      final q = wanted[p.id];
      if (q != null) {
        gross += returnedValueMinor(lineTotalMinor: p.soldValue, soldQtyMinor: p.soldQty, returnedQtyMinor: q);
      }
    }
    final left = widget.sale.totalMinor + widget.earlierReturnsMinor;
    if (widget.returnable.entries.every((e) => (wanted[e.key] ?? 0) == e.value)) return left;
    final worth = refundTotalMinor(
      grossMinor: gross,
      saleSubtotalMinor: widget.sale.subtotalMinor,
      saleDiscountMinor: widget.sale.discountMinor,
    );
    return worth < left ? worth : left;
  }

  Future<void> _submit(AppLocalizations l, Map<String, int> wanted) async {
    setState(() => _busy = true);
    try {
      final done = await ref.read(tillRefundProvider)(
        widget.sale.id, lines: wanted, reason: _reason.text.trim(), method: _method,
      );
      if (mounted) Navigator.pop(context, done);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _refusal = appErrorText(l, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (wanted, invalid) = _wanted(l);
    final worth = invalid == null && wanted.isNotEmpty ? _worth(wanted) : null;
    final ready = worth != null && _reason.text.trim().isNotEmpty && !_busy;
    final problem = invalid ?? _refusal;
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.returnTitle),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final p in _products)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name),
                      Text(
                        l.returnUpTo(ltr(formatQuantity(widget.returnable[p.id]!, p.decimalPlaces))),
                        style: theme.textTheme.bodySmall,
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      controller: _qty[p.id],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.numberWithOptions(decimal: p.decimalPlaces > 0),
                      onChanged: (_) => _edited(),
                    ),
                  ),
                ]),
              ),
            const SizedBox(height: 8),
            Text(l.returnPayBack, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'cash', label: Text(l.cash)),
                ButtonSegment(value: 'card', label: Text(l.card)),
                ButtonSegment(value: 'transfer', label: Text(l.transfer)),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() {
                _method = s.first;
                _refusal = null;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              maxLength: 200,
              decoration: InputDecoration(labelText: l.voidReason),
              onChanged: (_) => _edited(),
            ),
            if (worth != null) Text(l.returnWorth(formatMoney(l, worth, widget.sale.currency)), style: theme.textTheme.titleMedium),
            if (problem != null) Text(problem, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: ready ? () => _submit(l, wanted) : null,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.returnConfirm),
        ),
      ],
    );
  }
}
