import 'dart:convert';

import 'package:dukan_core/dukan_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'auth_state.dart';

/// The signed-in actor + active branch, reconstructed from the cached profile
/// so the same [PermissionPolicy] used on the server gates the UI.
class SessionActor {
  const SessionActor(this.user, this.branchId);
  final User user;
  final String branchId;

  bool can(Permission permission) => const PermissionPolicy().can(user, permission, branchId);
}

final sessionActorProvider = Provider<SessionActor?>((ref) {
  final state = ref.watch(authControllerProvider);
  if (state is! AuthLoggedIn) return null;
  final p = state.profile;
  final branchId = p.defaultBranchId ?? '';
  final assignments = <BranchAssignment>[];
  try {
    for (final b in (jsonDecode(p.branches) as List).cast<Map<String, dynamic>>()) {
      assignments.add(BranchAssignment(branchId: b['branch_id'] as String, roleName: b['role_name'] as String));
    }
  } on Object {
    // leave assignments empty on a malformed cache
  }
  final user = User(
    id: p.userId,
    username: p.username,
    displayName: p.displayName,
    status: UserStatus.active,
    assignments: assignments,
    defaultBranchId: p.defaultBranchId,
  );
  return SessionActor(user, branchId);
});

/// The signed-in user's id, kept while the app is locked or another account is
/// being tried. Session state (the POS cart, admin lists, the notification
/// feed) watches it, so it resets when another user signs in on this device but
/// survives a lock.
final sessionUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider.select((s) => switch (s) {
        AuthLoggedIn(:final profile) || AuthLocked(:final profile) => profile.userId,
        AuthLoggedOut(:final returnTo?) => returnTo.userId,
        _ => null,
      })),
);

/// The active branch's name — used as the receipt header. The bootstrap owner's
/// default branch is the shop itself. Falls back to the app name.
final shopNameProvider = Provider<String>((ref) {
  final state = ref.watch(authControllerProvider);
  if (state is! AuthLoggedIn) return 'DukanPro';
  try {
    final branches = (jsonDecode(state.profile.branches) as List).cast<Map<String, dynamic>>();
    if (branches.isEmpty) return 'DukanPro';
    final def = state.profile.defaultBranchId;
    final match = branches.firstWhere(
      (b) => b['branch_id'] == def,
      orElse: () => branches.first,
    );
    final name = match['branch_name'] as String?;
    return (name == null || name.isEmpty) ? 'DukanPro' : name;
  } on Object {
    return 'DukanPro';
  }
});

/// The active branch's entry in the cached profile (its default branch), or null.
Map<String, dynamic>? _activeBranchOf(Ref ref) {
  final profile = switch (ref.watch(authControllerProvider)) {
    AuthLoggedIn(:final profile) || AuthLocked(:final profile) => profile,
    _ => null,
  };
  if (profile == null) return null;
  try {
    final branches = (jsonDecode(profile.branches) as List).cast<Map<String, dynamic>>();
    if (branches.isEmpty) return null;
    return branches.firstWhere((b) => b['branch_id'] == profile.defaultBranchId, orElse: () => branches.first);
  } on Object {
    return null;
  }
}

/// The active branch's time zone: its business day, and the clock every time
/// on screen and on receipts is read in. Kabul's until a profile names one.
final branchZoneProvider =
    Provider<String>((ref) => _activeBranchOf(ref)?['timezone'] as String? ?? defaultBranchZone);

/// The active branch's currency: new prices and typed amounts are in it.
final shopCurrencyProvider = Provider<String>((ref) => _activeBranchOf(ref)?['currency'] as String? ?? 'AFN');
