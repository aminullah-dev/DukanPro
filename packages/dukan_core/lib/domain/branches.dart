import '../shared/errors.dart';

/// Branches domain. Mirrors docs/domain/branches.md and
/// server/dukan/domain/branches.py (the SAME rules run in both languages).
/// Pure: imports only the shared error contract. A branch scopes stock, sales,
/// shifts, and staff to a physical location.

final class Branch {
  const Branch({
    required this.id,
    required this.name,
    this.timezone = 'Asia/Kabul',
    this.currencyDefault = 'AFN',
    this.isActive = true,
    this.version = 0,
  });

  final String id;
  final String name;
  final String timezone;
  final String currencyDefault;
  final bool isActive;
  final int version;
}

/// Domain invariant: a shop must always retain at least one active branch.
/// Raises [ConflictError] `BRANCH_LAST_ACTIVE`. [activeBranchCount] is the count
/// of active branches *including* the one being deactivated, before the change.
void assertNotLastActiveBranch({required int activeBranchCount}) {
  if (activeBranchCount <= 1) {
    throw ConflictError('BRANCH_LAST_ACTIVE', const {});
  }
}
