import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/dates.dart';
import '../auth/session.dart';
import 'sync_issues_screen.dart';
import 'sync_providers.dart';

/// AppBar action: a cloud icon that triggers [SyncController.syncNow], badged
/// with the pending-op count and spinning while a sync is in flight.
class SyncAction extends ConsumerWidget {
  const SyncAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    final Widget icon;
    if (status.syncing) {
      icon = const SizedBox(
        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      icon = Icon(status.failed
          ? Icons.sync_problem
          : (status.pending > 0 ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined));
    }

    return IconButton(
      tooltip: l.syncNow,
      onPressed: status.syncing ? null : () => ref.read(syncControllerProvider.notifier).syncNow(),
      icon: Badge(
        isLabelVisible: status.pending > 0 && !status.syncing,
        label: Text('${status.pending}'),
        backgroundColor: scheme.error,
        child: icon,
      ),
    );
  }
}

/// A status line for the shell body: pending count / syncing / last-synced,
/// plus a conflict hint and a prominent "Sync now" button.
class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);
    final theme = Theme.of(context);

    final String summary;
    if (status.syncing) {
      summary = l.syncing;
    } else if (status.failed) {
      summary = l.syncFailed;
    } else if (status.pending > 0) {
      summary = l.syncPending(status.pending);
    } else if (status.lastSyncedAt != null) {
      summary = l.lastSyncedAt(formatTime(l, status.lastSyncedAt!, ref.watch(branchZoneProvider)));
    } else {
      summary = l.syncUpToDate;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.failed ? Icons.sync_problem : Icons.sync,
              color: status.failed ? theme.colorScheme.error : null,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(summary, style: theme.textTheme.bodyMedium),
                  if (status.conflicts > 0)
                    Text(
                      l.syncConflicts(status.conflicts),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    ),
                  if (status.rejected > 0)
                    Text(
                      l.syncRejected(status.rejected),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    ),
                  if (status.conflicts > 0 || status.rejected > 0)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => const SyncIssuesScreen())),
                      child: Text(l.syncIssuesReview),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed:
                  status.syncing ? null : () => ref.read(syncControllerProvider.notifier).syncNow(),
              icon: const Icon(Icons.sync, size: 18),
              label: Text(l.syncNow),
            ),
          ],
        ),
      ),
    );
  }
}
