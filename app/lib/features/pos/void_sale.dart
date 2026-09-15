import 'package:dukan_core/dukan_core.dart' show AppError, Permission;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/error_text.dart';
import '../auth/session.dart';
import 'pos_providers.dart';

/// Voids the sale on show, for someone allowed to (sale.void). It asks why;
/// then the server takes the stock back, and what the customer still owes for
/// it. Hidden from anyone else, and once the sale is not settled.
class VoidSaleButton extends ConsumerStatefulWidget {
  const VoidSaleButton({required this.saleId, required this.settled, required this.onVoided, super.key});
  final String saleId;
  final bool settled;
  final VoidCallback onVoided;

  @override
  ConsumerState<VoidSaleButton> createState() => _VoidSaleButtonState();
}

class _VoidSaleButtonState extends ConsumerState<VoidSaleButton> {
  bool _busy = false;

  Future<void> _void(AppLocalizations l) async {
    final reason = await showDialog<String>(context: context, builder: (_) => const _VoidReasonDialog());
    if (reason == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(tillVoidProvider)(widget.saleId, reason: reason);
      messenger.showSnackBar(SnackBar(content: Text(l.saleVoidedOk)));
      widget.onVoided();
    } on AppError catch (e) {
      // A cash sale whose shift has closed is in that shift's count already.
      messenger.showSnackBar(SnackBar(
        content: Text(e.code == 'SALE_SHIFT_CLOSED' ? l.errVoidShiftClosed : appErrorText(l, e)),
      ));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(appErrorText(l, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canVoid = ref.watch(sessionActorProvider)?.can(Permission.saleVoid) ?? false;
    if (!canVoid || !widget.settled) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: _busy ? null : () => _void(l),
      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
      icon: _busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.undo),
      label: Text(l.voidSale),
    );
  }
}

/// Why the sale is voided: required, and kept with the void in the audit trail.
class _VoidReasonDialog extends StatefulWidget {
  const _VoidReasonDialog();
  @override
  State<_VoidReasonDialog> createState() => _VoidReasonDialogState();
}

class _VoidReasonDialogState extends State<_VoidReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reason = _reason.text.trim();
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.voidSaleTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.voidSaleBody),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            autofocus: true,
            maxLength: 200,
            decoration: InputDecoration(labelText: l.voidReason),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: reason.isEmpty ? null : () => Navigator.pop(context, reason),
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: Text(l.voidSale),
        ),
      ],
    );
  }
}
