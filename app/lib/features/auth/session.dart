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

/// The signed-in user's id, kept while the app is locked. Session state (the
/// POS cart, admin lists, the notification feed) watches it, so it resets when
/// another user signs in on this device but survives a lock.
final sessionUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider.select((s) => switch (s) {
        AuthLoggedIn(:final profile) || AuthLocked(:final profile) => profile.userId,
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
