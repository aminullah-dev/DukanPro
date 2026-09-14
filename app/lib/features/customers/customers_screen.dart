import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../auth/session.dart';
import 'customers_providers.dart';

String _afn(int minor) => (minor / 100).toStringAsFixed(2);

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final created = await showDialog<Customer>(
      context: context,
      builder: (_) => _AddCustomerDialog(canGrantCredit: actor.can(Permission.customerCredit)),
    );
    if (created == null) return;
    await ref.read(localCustomersProvider).createCustomer(created, actorId: actor.user.id, deviceId: 'app');
    ref.invalidate(customersProvider);
  }

  Future<void> _setCredit(BuildContext context, WidgetRef ref, Customer c) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final result = await showDialog<({int? limit})>(
      context: context,
      builder: (_) => _CreditLimitDialog(customer: c),
    );
    if (result == null) return;
    await ref.read(localCustomersProvider).setCreditLimit(
          c, result.limit, actorId: actor.user.id, deviceId: 'app');
    ref.invalidate(customersProvider);
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, Customer c) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final amount = await showDialog<int>(context: context, builder: (_) => _PaymentDialog(customer: c));
    if (amount == null) return;
    try {
      await ref.read(localCustomersProvider).recordPayment(
            customerId: c.id, amountMinor: amount, actorId: actor.user.id, deviceId: 'app');
      ref
        ..invalidate(customersProvider)
        ..invalidate(customerBalanceProvider(c.id));
    } on AppError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final actor = ref.watch(sessionActorProvider);
    final canManage = actor?.can(Permission.saleCreate) ?? false;
    final canCredit = actor?.can(Permission.customerCredit) ?? false;
    final async = ref.watch(customersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.customers)),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _add(context, ref), icon: const Icon(Icons.person_add), label: Text(l.addCustomer))
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (customers) => customers.isEmpty
            ? Center(child: Text(l.noCustomers))
            : ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = customers[i];
                  return ListTile(
                    title: Text(c.name),
                    subtitle: c.phone != null ? Text(c.phone!) : null,
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      _BalanceChip(customerId: c.id),
                      if (canCredit)
                        IconButton(
                          icon: const Icon(Icons.credit_score_outlined),
                          tooltip: l.setCreditLimit,
                          onPressed: () => _setCredit(context, ref, c),
                        ),
                    ]),
                    onTap: canManage ? () => _pay(context, ref, c) : null,
                  );
                },
              ),
      ),
    );
  }
}

class _BalanceChip extends ConsumerWidget {
  const _BalanceChip({required this.customerId});
  final String customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(customerBalanceProvider(customerId));
    return async.maybeWhen(
      data: (b) => Text('${l.balance}: ${_afn(b)}',
          style: TextStyle(fontWeight: FontWeight.w600, color: b > 0 ? Theme.of(context).colorScheme.error : null)),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _AddCustomerDialog extends StatefulWidget {
  const _AddCustomerDialog({required this.canGrantCredit});

  /// Credit is a manager's decision: without customer.credit the customer gets
  /// none (limit 0) and the field is hidden.
  final bool canGrantCredit;
  @override
  State<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<_AddCustomerDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _limit = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addCustomer),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: l.customerName)),
        TextField(controller: _phone, decoration: InputDecoration(labelText: l.phone)),
        if (widget.canGrantCredit)
          TextField(
          controller: _limit,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.creditLimit, suffixText: 'AFN'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            // Bounds mirror the server's columns so a saved customer is never
            // rejected at sync: name ≤ 128, phone ≤ 32, credit limit ≥ 0.
            final name = _name.text.trim();
            final phone = _phone.text.trim();
            final limit = double.tryParse(_limit.text);
            if (name.isEmpty || name.length > 128 || phone.length > 32) return;
            if (limit != null && (!limit.isFinite || limit < 0)) return;
            Navigator.pop(
              context,
              Customer(
                id: newId(), name: name,
                phone: phone.isEmpty ? null : phone,
                creditLimitMinor: !widget.canGrantCredit ? 0 : (limit == null ? null : (limit * 100).round()),
              ),
            );
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

/// A manager changes a customer's credit limit; empty means no limit.
class _CreditLimitDialog extends StatefulWidget {
  const _CreditLimitDialog({required this.customer});
  final Customer customer;
  @override
  State<_CreditLimitDialog> createState() => _CreditLimitDialogState();
}

class _CreditLimitDialogState extends State<_CreditLimitDialog> {
  late final _limit = TextEditingController(
    text: switch (widget.customer.creditLimitMinor) { null => '', final v => _afn(v) },
  );

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text('${l.setCreditLimit} · ${widget.customer.name}'),
      content: TextField(
        controller: _limit,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: l.creditLimit, suffixText: 'AFN', helperText: l.creditLimitHelp,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            final text = _limit.text.trim();
            final v = double.tryParse(text);
            if (text.isNotEmpty && (v == null || !v.isFinite || v < 0)) return;
            Navigator.pop<({int? limit})>(context, (limit: v == null ? null : (v * 100).round()));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

class _PaymentDialog extends ConsumerStatefulWidget {
  const _PaymentDialog({required this.customer});
  final Customer customer;
  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  final _amount = TextEditingController();
  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final balance = ref.watch(customerBalanceProvider(widget.customer.id));
    return AlertDialog(
      title: Text('${l.recordPayment} · ${widget.customer.name}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l.balance),
          Text(balance.maybeWhen(data: (b) => _afn(b), orElse: () => '…'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.amount, suffixText: 'AFN'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(_amount.text);
            if (v == null || !v.isFinite || v <= 0) return;
            Navigator.pop(context, (v * 100).round());
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
