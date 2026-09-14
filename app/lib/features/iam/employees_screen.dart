import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/iam_api.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/error_text.dart';
import '../../widgets/shell_scope.dart';
import 'iam_providers.dart';
import 'iam_ui.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(employeesControllerProvider);
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.employees)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref, l),
        icon: const Icon(Icons.person_add),
        label: Text(l.addEmployee),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorMessage(e),
        data: (employees) => employees.isEmpty
            ? Center(child: Text(l.noEmployees))
            : ListView.separated(
                itemCount: employees.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _EmployeeTile(employees[i]),
              ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final draft = await showDialog<_NewEmployee>(context: context, builder: (_) => const _AddEmployeeDialog());
    if (draft == null || !context.mounted) return;
    await runIam(context, l, () => ref.read(employeesControllerProvider.notifier).create(
          username: draft.username,
          password: draft.password,
          displayName: draft.displayName,
          roleName: draft.roleName,
        ));
  }
}

class _EmployeeTile extends ConsumerWidget {
  const _EmployeeTile(this.employee);
  final EmployeeDto employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final roles = employee.branches
        .map((b) => '${b.branchName.isEmpty ? b.branchId : b.branchName} · ${roleLabel(l, b.roleName)}')
        .join('   ');
    return ListTile(
      leading: CircleAvatar(child: Text(employee.displayName.isNotEmpty ? employee.displayName[0] : '?')),
      title: Text('${employee.displayName}  (@${employee.username})'),
      subtitle: roles.isEmpty ? null : Text(roles),
      trailing: Chip(
        label: Text(employee.isActive ? l.statusActive : l.statusDisabled),
        backgroundColor: employee.isActive ? null : Theme.of(context).colorScheme.errorContainer,
      ),
      onTap: () => _openActions(context, ref, l),
    );
  }

  void _openActions(BuildContext context, WidgetRef ref, AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(employee.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('@${employee.username}'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(employee.isActive ? Icons.block : Icons.check_circle_outline),
              title: Text(employee.isActive ? l.disable : l.enable),
              onTap: () async {
                Navigator.pop(sheet);
                await runIam(context, l, () => ref
                    .read(employeesControllerProvider.notifier)
                    .setStatus(employee.id, active: !employee.isActive));
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l.assignRole),
              onTap: () {
                Navigator.pop(sheet);
                _assignRole(context, ref, l);
              },
            ),
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: Text(l.resetPassword),
              onTap: () {
                Navigator.pop(sheet);
                _resetPassword(context, ref, l);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignRole(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final branches = await ref.read(branchesControllerProvider.future);
    if (!context.mounted || branches.isEmpty) return;
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => _AssignRoleDialog(branches: branches),
    );
    if (result == null || !context.mounted) return;
    await runIam(
      context, l,
      () => ref.read(employeesControllerProvider.notifier).assignRole(
            employee.id, branchId: result.$1, roleName: result.$2,
          ),
      okMessage: l.savedOk,
    );
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final pw = await showDialog<String>(context: context, builder: (_) => const _ResetPasswordDialog());
    if (pw == null || !context.mounted) return;
    await runIam(
      context, l,
      () => ref.read(employeesControllerProvider.notifier).resetPassword(employee.id, pw),
      okMessage: l.savedOk,
    );
  }
}

class _NewEmployee {
  const _NewEmployee(this.username, this.password, this.displayName, this.roleName);
  final String username;
  final String password;
  final String displayName;
  final String roleName;
}

class _AddEmployeeDialog extends StatefulWidget {
  const _AddEmployeeDialog();
  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  String _role = 'cashier';

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.addEmployee),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _name, decoration: InputDecoration(labelText: l.displayName)),
        TextField(controller: _username, decoration: InputDecoration(labelText: l.username)),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(labelText: l.password),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _role,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.role),
          items: [
            for (final r in kRoleNames) DropdownMenuItem(value: r, child: Text(roleLabel(l, r))),
          ],
          onChanged: (v) => setState(() => _role = v ?? _role),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (_username.text.trim().isEmpty || _password.text.isEmpty) return;
            Navigator.pop(
              context,
              _NewEmployee(_username.text.trim(), _password.text, _name.text.trim(), _role),
            );
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

class _AssignRoleDialog extends StatefulWidget {
  const _AssignRoleDialog({required this.branches});
  final List<BranchDto> branches;
  @override
  State<_AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends State<_AssignRoleDialog> {
  late String _branchId = widget.branches.first.id;
  String _role = 'cashier';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.assignRole),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          initialValue: _branchId,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.branches),
          items: [
            for (final b in widget.branches) DropdownMenuItem(value: b.id, child: Text(b.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _branchId = v ?? _branchId),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _role,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.role),
          items: [
            for (final r in kRoleNames) DropdownMenuItem(value: r, child: Text(roleLabel(l, r))),
          ],
          onChanged: (v) => setState(() => _role = v ?? _role),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () => Navigator.pop(context, (_branchId, _role)),
          child: Text(l.save),
        ),
      ],
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog();
  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _password = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(l.resetPassword),
      content: TextField(
        controller: _password,
        autofocus: true,
        obscureText: true,
        decoration: InputDecoration(labelText: l.newPassword),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (_password.text.isEmpty) return;
            Navigator.pop(context, _password.text);
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
