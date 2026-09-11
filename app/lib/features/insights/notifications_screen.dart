import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'insights_providers.dart';
import 'insights_ui.dart';

/// The notification feed: server-generated insights (reorder, dead stock,
/// debtor risk) plus a live insights section. Tap to mark read; refresh
/// recomputes the feed.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final feed = ref.watch(notificationsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications),
        actions: [
          IconButton(
            tooltip: l.refreshInsights,
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(notificationsControllerProvider.notifier).refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_none, size: 48),
                    const SizedBox(height: 8),
                    Text(l.noNotifications),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () => ref.read(notificationsControllerProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l.refreshInsights),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final n = items[i];
                  final style = severityStyle(context, n.severity);
                  return ListTile(
                    leading: Icon(style.icon, color: style.color),
                    title: Text(insightMessage(l, n.code, n.data)),
                    trailing: n.read
                        ? null
                        : Icon(Icons.circle, size: 10, color: Theme.of(context).colorScheme.primary),
                    onTap: n.read
                        ? null
                        : () => ref.read(notificationsControllerProvider.notifier).markRead(n.id),
                  );
                },
              ),
      ),
    );
  }
}
