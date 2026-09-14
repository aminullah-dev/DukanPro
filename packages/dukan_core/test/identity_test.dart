import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// Mirrors the test table in docs/domain/identity-access.md. The same rows run
/// in server/tests/unit/test_identity.py.
void main() {
  const policy = PermissionPolicy();

  User userWith(List<BranchAssignment> assignments, {UserStatus status = UserStatus.active}) =>
      User(
        id: newId(), username: 'u', displayName: 'U',
        status: status, assignments: assignments,
      );

  group('PermissionPolicy', () {
    test('cashier cannot change price', () {
      final u = userWith([const BranchAssignment(branchId: 'B1', roleName: 'cashier')]);
      expect(policy.can(u, Permission.priceChange, 'B1'), isFalse);
      expect(
        () => requirePermission(
            policy: policy, actor: u, permission: Permission.priceChange, branchId: 'B1'),
        throwsA(isA<PermissionDeniedError>()
            .having((e) => e.code, 'code', 'ACCESS_DENIED')),
      );
    });

    test('owner can manage users', () {
      final u = userWith([const BranchAssignment(branchId: 'B1', roleName: 'owner')]);
      expect(policy.can(u, Permission.userManage, 'B1'), isTrue);
    });

    test('role is scoped per branch', () {
      final u = userWith([
        const BranchAssignment(branchId: 'B1', roleName: 'manager'),
        const BranchAssignment(branchId: 'B2', roleName: 'cashier'),
      ]);
      expect(policy.can(u, Permission.priceChange, 'B1'), isTrue);
      expect(policy.can(u, Permission.priceChange, 'B2'), isFalse);
    });

    test('disabled user has no permissions', () {
      final u = userWith(
        [const BranchAssignment(branchId: 'B1', roleName: 'owner')],
        status: UserStatus.disabled,
      );
      expect(policy.can(u, Permission.saleCreate, 'B1'), isFalse);
    });

    test('only owner can view the audit trail', () {
      final owner = userWith([const BranchAssignment(branchId: 'B1', roleName: 'owner')]);
      final manager = userWith([const BranchAssignment(branchId: 'B1', roleName: 'manager')]);
      expect(policy.can(owner, Permission.auditView, 'B1'), isTrue);
      expect(policy.can(manager, Permission.auditView, 'B1'), isFalse);
    });
  });

  group('invariants', () {
    test('every branch keeps an owner', () {
      expect(
        () => assertBranchKeepsOwner(branchId: 'B1', ownersAfter: 0),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'USER_LAST_OWNER')),
      );
      assertBranchKeepsOwner(branchId: 'B1', ownersAfter: 1); // no throw
    });

    test('a user keeps an assignment', () {
      expect(
        () => assertKeepsAnAssignment(userId: 'u', remaining: 0),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'USER_LAST_ASSIGNMENT')),
      );
      assertKeepsAnAssignment(userId: 'u', remaining: 1); // no throw
    });

    test('only built-in roles are assignable', () {
      expect(
        () => assertRoleKnown(roleName: 'admin'),
        throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'ROLE_UNKNOWN')),
      );
      assertRoleKnown(roleName: 'stock_keeper'); // no throw
    });

    test('money permissions belong to owner and manager', () {
      const money = [
        Permission.saleVoid, Permission.saleDiscount, Permission.customerCredit, Permission.purchaseCost,
      ];
      const allowed = {'owner': true, 'manager': true, 'cashier': false, 'stock_keeper': false, 'accountant': false};
      allowed.forEach((role, can) {
        final u = userWith([BranchAssignment(branchId: 'B1', roleName: role)]);
        expect(money.every((p) => policy.can(u, p, 'B1') == can), isTrue, reason: role);
      });
    });

    test('duplicate username rejected', () {
      expect(
        () => assertUsernameAvailable(username: 'ahmad', taken: true),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'USER_DUPLICATE_USERNAME')),
      );
      assertUsernameAvailable(username: 'ahmad', taken: false); // no throw
    });

    test('built-in role is immutable', () {
      expect(
        () => assertRoleMutable(roleName: 'cashier'),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'ROLE_BUILTIN_IMMUTABLE')),
      );
    });

    test('weak password is rejected', () {
      expect(
        () => assertPasswordStrong(password: 'short'),
        throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'WEAK_PASSWORD')),
      );
      assertPasswordStrong(password: 'longenough'); // no throw
    });
  });
}
