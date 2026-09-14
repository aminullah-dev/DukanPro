import 'package:dukan_data/dukan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/error_text.dart';
import 'sync_providers.dart';

String _what(AppLocalizations l, String table) => switch (table) {
      'products' => l.products,
      'customers' => l.customers,
      'suppliers' => l.supplier,
      'units' => l.unit,
      'sales' || 'sale_lines' || 'payments' => l.pos,
      'stock_movements' => l.adjustStock,
      'customer_ledger' => l.recordPayment,
      'supplier_ledger' => l.receiveStock,
      _ => table,
    };

/// Changes the server did not take: an edit someone else made first (the
/// server's version is on this device now; the edit can be applied again) or a
/// refusal. Each can be set aside.
class SyncIssuesScreen extends ConsumerWidget {
  const SyncIssuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final issues = ref.watch(syncIssuesProvider);
    final engine = ref.read(syncEngineProvider);
    final error = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: Text(l.syncIssuesTitle)),
      body: issues.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errGeneric)),
        data: (items) => items.isEmpty
            ? Center(child: Text(l.syncIssuesEmpty))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final SyncIssue issue = items[i];
                  final conflict = issue.status == 'conflict';
                  return ListTile(
                    leading: Icon(conflict ? Icons.call_split : Icons.block, color: error),
                    title: Text(
                      '${_what(l, issue.table)} · ${conflict ? l.syncIssueConflict : l.syncIssueRejected}',
                    ),
                    subtitle: Text(
                      '${DateFormat.yMd().add_Hm().format(issue.createdAt.toLocal())}'
                      '${issue.code == null ? '' : ' · ${errorCodeText(l, issue.code!)}'}',
                    ),
                    trailing: Wrap(spacing: 4, children: [
                      if (issue.canRetry)
                        TextButton(
                          onPressed: () => engine.retry(issue.opId),
                          child: Text(l.syncIssueRetry),
                        ),
                      TextButton(
                        onPressed: () => engine.dismiss(issue.opId),
                        child: Text(l.syncIssueDismiss),
                      ),
                    ]),
                  );
                },
              ),
      ),
    );
  }
}
