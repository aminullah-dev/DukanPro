import 'package:dukanpro/features/audit/audit_providers.dart';
import 'package:dukanpro/infrastructure/audit_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('auditLogProvider returns the trail newest-first', () async {
    final api = FakeAuditApi([
      AuditEntryDto(id: 'a1', occurredAt: DateTime(2026, 9, 11, 10), action: 'owner.bootstrapped'),
      AuditEntryDto(
        id: 'a2', occurredAt: DateTime(2026, 9, 11, 11), action: 'user.created',
        actorId: 'u1', entityType: 'user', entityId: 'u2',
      ),
    ]);
    final container = ProviderContainer(overrides: [auditApiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);

    final entries = await container.read(auditLogProvider.future);
    expect(entries.length, 2);
    expect(entries.first.action, 'owner.bootstrapped');
  });

  test('AuditApi filters by action', () async {
    final api = FakeAuditApi([
      AuditEntryDto(id: 'a1', occurredAt: DateTime(2026), action: 'user.login_failed'),
      AuditEntryDto(id: 'a2', occurredAt: DateTime(2026), action: 'user.created'),
    ]);
    final failed = await api.list(action: 'user.login_failed');
    expect(failed.single.action, 'user.login_failed');
  });
}
