import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/insights_api.dart';
import '../auth/session.dart';

/// The insights/notifications API. Overridden in main with a [DioInsightsApi];
/// tests inject a fake.
final insightsApiProvider = Provider<InsightsApi>(
    (ref) => throw UnimplementedError('override insightsApiProvider in main'));

/// Live business insights (recomputed on demand).
final insightsProvider = FutureProvider<List<InsightDto>>(
  (ref) {
    ref.watch(sessionUserIdProvider);
    return ref.watch(insightsApiProvider).listInsights();
  },
);

/// The persisted notification feed; mutations go through [NotificationsController].
class NotificationsController extends AsyncNotifier<List<NotificationDto>> {
  InsightsApi get _api => ref.read(insightsApiProvider);

  @override
  Future<List<NotificationDto>> build() {
    ref.watch(sessionUserIdProvider);
    return _api.listNotifications();
  }

  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }

  /// Recompute insights into the feed, then reload.
  Future<int> refresh() async {
    final created = await _api.refresh();
    await _reload();
    return created;
  }

  Future<void> markRead(String id) async {
    await _api.markRead(id);
    await _reload();
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<NotificationDto>>(NotificationsController.new);

/// Unread badge count for the shell bell.
final unreadNotificationsProvider = Provider<int>((ref) {
  final feed = ref.watch(notificationsControllerProvider).asData?.value;
  if (feed == null) return 0;
  return feed.where((n) => !n.read).length;
});
