import '../domain/identity.dart';
import '../shared/errors.dart';

/// Application-layer access guard. ACCESS_DENIED is a permission concern, so it
/// is raised here (as [PermissionDeniedError]) — never from the domain, which
/// only answers the pure boolean [PermissionPolicy.can].
void requirePermission({
  required PermissionPolicy policy,
  required User actor,
  required Permission permission,
  required String branchId,
}) {
  if (!policy.can(actor, permission, branchId)) {
    throw PermissionDeniedError('ACCESS_DENIED', {
      'permission': permission.code,
      'branchId': branchId,
      'actorId': actor.id,
    });
  }
}
