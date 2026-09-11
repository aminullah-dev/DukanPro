import 'package:dukanpro/features/insights/insights_providers.dart';
import 'package:dukanpro/features/insights/insights_ui.dart';
import 'package:dukanpro/l10n/app_localizations_en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('insightMessage renders codes with data in the active locale', () {
    final l = AppLocalizationsEn();
    expect(insightMessage(l, 'insight.reorder', {'product': 'Soap'}), 'Restock Soap — running low');
    expect(insightMessage(l, 'insight.debt_risk', {'customer': 'Karim'}),
        'Karim is near their credit limit');
    expect(insightMessage(l, 'insight.digest', {'count': 3}), '3 sales today');
    expect(insightMessage(l, 'insight.unknown_code', const {}), 'New insight');
  });

  test('NotificationsController refresh materializes the feed and marks read', () async {
    final api = FakeInsightsApi();
    final container = ProviderContainer(overrides: [insightsApiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);

    expect(await container.read(notificationsControllerProvider.future), isEmpty);

    final created = await container.read(notificationsControllerProvider.notifier).refresh();
    expect(created, 2); // reorder + debt_risk (digest is live-only)

    var feed = await container.read(notificationsControllerProvider.future);
    expect(feed.length, 2);
    expect(container.read(unreadNotificationsProvider), 2);

    await container.read(notificationsControllerProvider.notifier).markRead(feed.first.id);
    feed = await container.read(notificationsControllerProvider.future);
    expect(feed.where((n) => n.read).length, 1);
    expect(container.read(unreadNotificationsProvider), 1);
  });

  test('refresh is idempotent (no duplicate feed rows)', () async {
    final api = FakeInsightsApi();
    final container = ProviderContainer(overrides: [insightsApiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);

    await container.read(notificationsControllerProvider.future);
    await container.read(notificationsControllerProvider.notifier).refresh();
    final second = await container.read(notificationsControllerProvider.notifier).refresh();
    expect(second, 0);
    expect((await container.read(notificationsControllerProvider.future)).length, 2);
  });
}
