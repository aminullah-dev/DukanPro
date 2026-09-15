import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/iam_api.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/labels.dart';
import '../../widgets/error_text.dart';
import '../../widgets/shell_scope.dart';
import 'iam_providers.dart';
import 'iam_ui.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(branchesControllerProvider);
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.branches)),
      floatingActionButton: FloatingActionButton.extended(heroTag: null,
        onPressed: () => _add(context, ref, l),
        icon: const Icon(Icons.add_business_outlined),
        label: Text(l.addBranch),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorMessage(e),
        data: (branches) => branches.isEmpty
            ? Center(child: Text(l.noBranches))
            : ListView.separated(
                itemCount: branches.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _BranchTile(branches[i]),
              ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _BranchNameDialog(title: l.addBranch),
    );
    if (name == null || !context.mounted) return;
    await runIam(context, l, () => ref.read(branchesControllerProvider.notifier).create(name));
  }
}

class _BranchTile extends ConsumerWidget {
  const _BranchTile(this.branch);
  final BranchDto branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.store_mall_directory_outlined),
      title: Text(branch.name),
      subtitle: Text(l.branchZoneCurrency(timeZoneLabel(l, branch.timezone), currencyLabel(l, branch.currencyDefault))),
      trailing: Chip(
        label: Text(branch.isActive ? l.statusActive : l.statusDisabled),
        backgroundColor: branch.isActive ? null : Theme.of(context).colorScheme.errorContainer,
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
            ListTile(title: Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.rename),
              onTap: () async {
                Navigator.pop(sheet);
                final name = await showDialog<String>(
                  context: context,
                  builder: (_) => _BranchNameDialog(title: l.rename, initial: branch.name),
                );
                if (name == null || !context.mounted) return;
                await runIam(context, l,
                    () => ref.read(branchesControllerProvider.notifier).rename(branch.id, name));
              },
            ),
            ListTile(
              leading: Icon(branch.isActive ? Icons.block : Icons.check_circle_outline),
              title: Text(branch.isActive ? l.deactivate : l.activate),
              onTap: () async {
                Navigator.pop(sheet);
                await runIam(context, l, () => ref
                    .read(branchesControllerProvider.notifier)
                    .setActive(branch.id, active: !branch.isActive));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchNameDialog extends StatefulWidget {
  const _BranchNameDialog({required this.title, this.initial});
  final String title;
  final String? initial;
  @override
  State<_BranchNameDialog> createState() => _BranchNameDialogState();
}

class _BranchNameDialogState extends State<_BranchNameDialog> {
  late final _name = TextEditingController(text: widget.initial ?? '');
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(widget.title),
      content: TextField(
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(labelText: l.branchNameLabel),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            Navigator.pop(context, _name.text.trim());
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}
