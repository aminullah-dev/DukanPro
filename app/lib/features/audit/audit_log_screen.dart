import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import 'audit_providers.dart';

/// The audit trail (owner-only). Read-only list of who did what, when — the
/// append-only record written in-transaction by every service.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(auditLogProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.auditLog),
        actions: [
          IconButton(
            tooltip: l.refreshInsights,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(auditLogProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (entries) => entries.isEmpty
            ? Center(child: Text(l.noAuditEntries))
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = entries[i];
                  final subtitle = [
                    if (e.entityType != null) e.entityType!,
                    DateFormat.yMd().add_Hm().format(e.occurredAt),
                  ].join(' · ');
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(e.action, style: const TextStyle(fontFamily: 'monospace')),
                    subtitle: Text(subtitle),
                  );
                },
              ),
      ),
    );
  }
}
