import '../shared/errors.dart';

/// Identity & Access domain. Mirrors docs/domain/identity-access.md and
/// server/dukan/domain/identity.py (the SAME rules run in both languages).
/// Pure: imports only the shared error contract.

/// Permissions — dotted codes. The set grows per phase.
enum Permission {
  saleCreate('sale.create'),
  priceChange('price.change'),
  stockAdjust('stock.adjust'),
  userManage('user.manage'),
  reportView('report.view'),
  branchManage('branch.manage'),
  debtWriteOff('debt.write_off');

  const Permission(this.code);
  final String code;
}

/// Built-in roles.
enum BuiltinRole {
  owner,
  manager,
  cashier,
  stockKeeper,
  accountant;

  /// Resolve from the stored role name (`owner`, `stock_keeper`, …).
  static BuiltinRole? fromName(String name) {
    switch (name) {
      case 'owner':
        return BuiltinRole.owner;
      case 'manager':
        return BuiltinRole.manager;
      case 'cashier':
        return BuiltinRole.cashier;
      case 'stock_keeper':
        return BuiltinRole.stockKeeper;
      case 'accountant':
        return BuiltinRole.accountant;
    }
    return null;
  }
}

/// The built-in role → permission mapping. Single source for [PermissionPolicy].
const Map<BuiltinRole, Set<Permission>> kBuiltinRolePermissions = {
  BuiltinRole.owner: {
    Permission.saleCreate,
    Permission.priceChange,
    Permission.stockAdjust,
    Permission.userManage,
    Permission.reportView,
    Permission.branchManage,
    Permission.debtWriteOff,
  },
  BuiltinRole.manager: {
    Permission.saleCreate,
    Permission.priceChange,
    Permission.stockAdjust,
    Permission.reportView,
    Permission.debtWriteOff,
  },
  BuiltinRole.cashier: {Permission.saleCreate},
  BuiltinRole.stockKeeper: {Permission.stockAdjust},
  BuiltinRole.accountant: {Permission.reportView, Permission.debtWriteOff},
};

enum UserStatus { active, disabled }

/// A user's role assignment within a single branch.
final class BranchAssignment {
  const BranchAssignment({required this.branchId, required this.roleName});
  final String branchId;
  final String roleName;
}

final class User {
  const User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.status,
    required this.assignments,
    this.defaultBranchId,
    this.version = 0,
  });

  final String id;
  final String username;
  final String displayName;
  final UserStatus status;
  final List<BranchAssignment> assignments;
  final String? defaultBranchId;
  final int version;

  bool get isActive => status == UserStatus.active;
  bool get isOwner => assignments.any((a) => a.roleName == 'owner');
}

/// The only place access is decided. Pure.
final class PermissionPolicy {
  const PermissionPolicy();

  /// Effective permissions a user has in [branchId] (union across that
  /// branch's role assignments).
  Set<Permission> permissionsFor(User user, String branchId) {
    final perms = <Permission>{};
    for (final a in user.assignments.where((a) => a.branchId == branchId)) {
      final role = BuiltinRole.fromName(a.roleName);
      if (role != null) perms.addAll(kBuiltinRolePermissions[role] ?? const {});
    }
    return perms;
  }

  bool can(User user, Permission permission, String branchId) {
    if (!user.isActive) return false;
    return permissionsFor(user, branchId).contains(permission);
  }
}

/// Domain invariant: a shop must always retain at least one active owner.
/// Raises [ConflictError] `USER_LAST_OWNER`. `activeOwnerCount` is the count of
/// active owners *including* [target] before the change.
void assertNotLastOwner({required User target, required int activeOwnerCount}) {
  if (target.isOwner && activeOwnerCount <= 1) {
    throw ConflictError('USER_LAST_OWNER', {'userId': target.id});
  }
}

/// Domain invariant: usernames are unique among active users.
/// Raises [ConflictError] `USER_DUPLICATE_USERNAME`.
void assertUsernameAvailable({
  required String username,
  required bool taken,
}) {
  if (taken) {
    throw ConflictError('USER_DUPLICATE_USERNAME', {'username': username});
  }
}

/// Domain invariant: a built-in role's core permissions are immutable.
/// Raises [ConflictError] `ROLE_BUILTIN_IMMUTABLE`.
void assertRoleMutable({required String roleName}) {
  if (BuiltinRole.fromName(roleName) != null) {
    throw ConflictError('ROLE_BUILTIN_IMMUTABLE', {'role': roleName});
  }
}
