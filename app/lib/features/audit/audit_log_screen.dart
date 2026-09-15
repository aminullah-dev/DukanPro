import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/dates.dart';
import '../auth/session.dart';
import '../../widgets/labels.dart';
import '../../widgets/error_text.dart';
import '../../widgets/shell_scope.dart';
import 'audit_providers.dart';

/// The audit trail (owner-only). Read-only list of who did what, when — the
/// append-only record written in-transaction by every service.
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(auditLogProvider);
    final zone = ref.watch(branchZoneProvider);
    return Scaffold(
      appBar: AppBar(
        leading: ShellScope.menuButton(context),
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
        error: (e, _) => ErrorMessage(e),
        data: (entries) => entries.isEmpty
            ? Center(child: Text(l.noAuditEntries))
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = entries[i];
                  final time = formatDateTime(l, e.occurredAt, zone);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(auditActionLabel(l, e.action)),
                    subtitle: Text(l.auditBy(e.actorName ?? l.auditSystem, time)),
                  );
                },
              ),
      ),
    );
  }
}
