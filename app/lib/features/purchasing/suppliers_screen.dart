import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/shell_scope.dart';
import '../../widgets/error_text.dart';
import '../../widgets/number_input.dart';
import '../auth/providers.dart';
import '../auth/session.dart';
import '../customers/customers_providers.dart';
import '../pos/pos_providers.dart';

String _afn(int minor) => formatQuantity(minor, 2);

typedef _Payment = ({int amount, PaymentMethod method});

/// The shop's suppliers and what it owes each. Paying one is money out
/// (purchase.cost); cash paid at the till comes out of the open shift's drawer.
class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final added = await showDialog<({String name, String? phone})>(
      context: context,
      builder: (_) => const _AddSupplierDialog(),
    );
    if (added == null) return;
    await ref.read(localPurchasingProvider).createSupplier(
          Supplier(id: newId(), name: added.name, phone: added.phone),
          actorId: actor.user.id, deviceId: ref.read(deviceIdProvider),
        );
    ref.invalidate(suppliersProvider);
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, Supplier s) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final paid = await showDialog<_Payment>(context: context, builder: (_) => _PayDialog(supplier: s));
    if (paid == null) return;
    try {
      await ref.read(localPurchasingProvider).paySupplier(
            supplier: s, amountMinor: paid.amount, method: paid.method,
            shiftId: ref.read(currentShiftProvider).value?.id,
            actorId: actor.user.id, deviceId: ref.read(deviceIdProvider),
          );
      ref.invalidate(supplierBalanceProvider(s.id));
    } on AppError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(appErrorText(AppLocalizations.of(context), e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final actor = ref.watch(sessionActorProvider);
    final canPay = actor?.can(Permission.purchaseCost) ?? false;
    final canAdd = actor?.can(Permission.productManage) ?? false;
    final async = ref.watch(suppliersProvider);
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.suppliers)),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add_business_outlined),
              label: Text(l.addSupplier),
            )
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorMessage(e),
        data: (suppliers) => suppliers.isEmpty
            ? Center(child: Text(l.noSuppliers))
            : ListView.separated(
                itemCount: suppliers.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = suppliers[i];
                  return ListTile(
                    title: Text(s.name),
                    subtitle: s.phone == null ? null : Text(s.phone!),
                    trailing: ref.watch(supplierBalanceProvider(s.id)).maybeWhen(
                          data: (b) => Text(
                            '${l.balance}: ${_afn(b)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: b > 0 ? Theme.of(context).colorScheme.error : null,
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                    onTap: canPay ? () => _pay(context, ref, s) : null,
                  );
                },
              ),
      ),
    );
  }
}

class _AddSupplierDialog extends StatefulWidget {
  const _AddSupplierDialog();
  @override
  State<_AddSupplierDialog> createState() => _AddSupplierDialogState();
}

class _AddSupplierDialogState extends State<_AddSupplierDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.addSupplier),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _name, autofocus: true, decoration: InputDecoration(labelText: l.supplierName)),
        TextField(controller: _phone, decoration: InputDecoration(labelText: l.phone)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            // Bounds mirror the server's columns: name up to 128, phone up to 32.
            final name = _name.text.trim();
            final phone = _phone.text.trim();
            if (name.isEmpty || name.length > 128 || phone.length > 32) return;
            Navigator.pop(context, (name: name, phone: phone.isEmpty ? null : phone));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

class _PayDialog extends ConsumerStatefulWidget {
  const _PayDialog({required this.supplier});
  final Supplier supplier;
  @override
  ConsumerState<_PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends ConsumerState<_PayDialog> {
  final _amount = TextEditingController();
  PaymentMethod _method = PaymentMethod.cash;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final balance = ref.watch(supplierBalanceProvider(widget.supplier.id));
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text('${l.paySupplier} · ${widget.supplier.name}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l.balance),
          Text(balance.maybeWhen(data: (b) => _afn(b), orElse: () => '…'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.amount, suffixText: 'AFN', errorText: _error),
        ),
        const SizedBox(height: 12),
        SegmentedButton<PaymentMethod>(
          segments: [
            ButtonSegment(value: PaymentMethod.cash, label: Text(l.cash)),
            ButtonSegment(value: PaymentMethod.card, label: Text(l.card)),
            ButtonSegment(value: PaymentMethod.transfer, label: Text(l.transfer)),
          ],
          selected: {_method},
          onSelectionChanged: (s) => setState(() => _method = s.first),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            try {
              final amount = amountOrNull(_amount.text);
              if (amount == null || amount <= 0) {
                setState(() => _error = l.errMustBePositive);
                return;
              }
              Navigator.pop<_Payment>(context, (amount: amount, method: _method));
            } on AppError catch (e) {
              setState(() => _error = numberErrorText(l, e));
            }
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
