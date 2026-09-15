import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/digits.dart';
import '../../widgets/bidi.dart';
import '../../widgets/money.dart';
import '../../widgets/shell_scope.dart';
import '../../widgets/error_text.dart';
import '../../widgets/number_input.dart';
import '../auth/session.dart';
import '../auth/providers.dart';
import '../pos/pos_providers.dart';
import 'customers_providers.dart';

String _afn(int minor) => formatQuantity(minor, 2);

enum _CustomerAction { creditLimit, toggleActive, writeOff }

typedef _Amount = ({int amount, PaymentMethod method});

Widget? _subtitle(AppLocalizations l, Customer c) {
  final parts = [if (c.phone != null) ltr(c.phone!), if (!c.isActive) l.customerInactive];
  return parts.isEmpty ? null : Text(parts.join(' · '));
}

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
    await ref.read(localCustomersProvider).createCustomer(created, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider));
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
          c, result.limit, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider));
    ref.invalidate(customersProvider);
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, Customer c) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final paid = await showDialog<_Amount>(context: context, builder: (_) => _PaymentDialog(customer: c));
    if (paid == null) return;
    try {
      // Cash collected at the till counts in the seller's open shift.
      await ref.read(localCustomersProvider).recordPayment(
            customerId: c.id, amountMinor: paid.amount, method: paid.method,
            shiftId: ref.read(currentShiftProvider).value?.id,
            actorId: actor.user.id, deviceId: ref.read(deviceIdProvider));
      ref
        ..invalidate(customersProvider)
        ..invalidate(customerBalanceProvider(c.id));
    } on AppError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(appErrorText(AppLocalizations.of(context), e))));
      }
    }
  }

  /// Close an account to credit, or reopen it (customer.credit).
  Future<void> _setActive(WidgetRef ref, Customer c, bool active) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    await ref
        .read(localCustomersProvider)
        .setActive(c, active, actorId: actor.user.id, deviceId: ref.read(deviceIdProvider));
    ref.invalidate(customersProvider);
  }

  /// Forgive part or all of a customer's debt (debt.write_off).
  Future<void> _writeOff(BuildContext context, WidgetRef ref, Customer c) async {
    final actor = ref.read(sessionActorProvider);
    if (actor == null) return;
    final forgiven = await showDialog<_Amount>(
      context: context,
      builder: (_) => _PaymentDialog(customer: c, writeOff: true),
    );
    if (forgiven == null) return;
    try {
      await ref.read(localCustomersProvider).writeOff(
            customer: c, amountMinor: forgiven.amount, actorId: actor.user.id,
            deviceId: ref.read(deviceIdProvider));
      ref
        ..invalidate(customersProvider)
        ..invalidate(customerBalanceProvider(c.id));
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
    final canManage = actor?.can(Permission.saleCreate) ?? false;
    final canCredit = actor?.can(Permission.customerCredit) ?? false;
    final canWriteOff = actor?.can(Permission.debtWriteOff) ?? false;
    final async = ref.watch(customersProvider);
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.customers)),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(heroTag: null,
              onPressed: () => _add(context, ref), icon: const Icon(Icons.person_add), label: Text(l.addCustomer))
          : null,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorMessage(e),
        data: (customers) => customers.isEmpty
            ? Center(child: Text(l.noCustomers))
            : ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = customers[i];
                  return ListTile(
                    title: Text(c.name, style: c.isActive ? null : TextStyle(color: Theme.of(context).disabledColor)),
                    subtitle: _subtitle(l, c),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      _BalanceChip(customerId: c.id),
                      if (canCredit || canWriteOff)
                        PopupMenuButton<_CustomerAction>(
                          onSelected: (a) => switch (a) {
                            _CustomerAction.creditLimit => _setCredit(context, ref, c),
                            _CustomerAction.toggleActive => _setActive(ref, c, !c.isActive),
                            _CustomerAction.writeOff => _writeOff(context, ref, c),
                          },
                          itemBuilder: (_) => [
                            if (canCredit)
                              PopupMenuItem(value: _CustomerAction.creditLimit, child: Text(l.setCreditLimit)),
                            if (canCredit)
                              PopupMenuItem(
                                value: _CustomerAction.toggleActive,
                                child: Text(c.isActive ? l.deactivateCustomer : l.reactivateCustomer),
                              ),
                            if (canWriteOff)
                              PopupMenuItem(value: _CustomerAction.writeOff, child: Text(l.writeOffDebt)),
                          ],
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
      data: (b) => Text('${l.balance}: ${formatMoney(l, b, shopCurrencyOf(context))}',
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
  String? _limitError;

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
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.addCustomer),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: l.customerName)),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr, // digit groups keep their order in Dari
          decoration: InputDecoration(labelText: l.phone),
        ),
        if (widget.canGrantCredit)
          TextField(
            controller: _limit,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.creditLimit, suffixText: currencySymbol(l, shopCurrencyOf(context)), helperText: l.creditLimitHelp,
              errorText: _limitError,
            ),
          ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            // Bounds mirror the server's columns so a saved customer is never
            // rejected at sync: name ≤ 128, phone ≤ 32, credit limit ≥ 0.
            final name = _name.text.trim();
            final phone = latinDigits(_phone.text.trim()); // stored with Latin digits, found with either
            if (name.isEmpty || name.length > 128 || phone.length > 32) return;
            int? limit;
            try {
              // Without customer.credit the customer gets no credit (limit 0).
              limit = widget.canGrantCredit ? amountOrNull(_limit.text) : 0;
            } on AppError catch (e) {
              setState(() => _limitError = numberErrorText(l, e));
              return;
            }
            Navigator.pop(
              context,
              Customer(
                id: newId(), name: name,
                phone: phone.isEmpty ? null : phone,
                creditLimitMinor: limit,
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
  String? _error;

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text('${l.setCreditLimit} · ${widget.customer.name}'),
      content: TextField(
        controller: _limit,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: l.creditLimit, suffixText: currencySymbol(l, shopCurrencyOf(context)), helperText: l.creditLimitHelp,
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            try {
              final limit = amountOrNull(_limit.text);
              Navigator.pop<({int? limit})>(context, (limit: limit));
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

/// An amount against a customer's balance: a payment, or debt forgiven
/// ([writeOff]).
class _PaymentDialog extends ConsumerStatefulWidget {
  const _PaymentDialog({required this.customer, this.writeOff = false});
  final Customer customer;
  final bool writeOff;
  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
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
    final balance = ref.watch(customerBalanceProvider(widget.customer.id));
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text('${widget.writeOff ? l.writeOffDebt : l.recordPayment} · ${widget.customer.name}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l.balance),
          Text(balance.maybeWhen(data: (b) => formatMoney(l, b, shopCurrencyOf(context)), orElse: () => '…'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: l.amount, suffixText: currencySymbol(l, shopCurrencyOf(context)), errorText: _error),
        ),
        if (!widget.writeOff) ...[
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
        ],
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
              Navigator.pop<_Amount>(context, (amount: amount, method: _method));
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
