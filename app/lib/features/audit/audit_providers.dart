import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/audit_api.dart';
import '../auth/session.dart';

/// The audit-trail API. Overridden in main with a [DioAuditApi]; tests fake it.
final auditApiProvider = Provider<AuditApi>(
    (ref) => throw UnimplementedError('override auditApiProvider in main'));

/// The recent audit trail (newest first).
final auditLogProvider = FutureProvider<List<AuditEntryDto>>(
  (ref) {
    ref.watch(sessionUserIdProvider);
    return ref.watch(auditApiProvider).list();
  },
);
