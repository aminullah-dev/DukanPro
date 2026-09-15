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

/// Writes happen only in an active branch; a deactivated branch keeps its
/// history readable. Raises [ConflictError] `BRANCH_INACTIVE`.
void assertBranchActive({required String branchId, required bool isActive}) {
  if (!isActive) {
    throw ConflictError('BRANCH_INACTIVE', {'branch_id': branchId});
  }
}

/// The time zones a branch can be in, with their offsets from UTC. None of them
/// keeps daylight saving time, so the device needs no time zone database and
/// the server and every device agree on each business day. Mirrors
/// server/dukan/domain/branches.py BRANCH_ZONE_OFFSETS.
const branchZoneOffsets = <String, Duration>{
  'Asia/Kabul': Duration(hours: 4, minutes: 30),
  'Asia/Karachi': Duration(hours: 5),
  'Asia/Tashkent': Duration(hours: 5),
  'Asia/Dushanbe': Duration(hours: 5),
  'Asia/Dubai': Duration(hours: 4),
  'Asia/Tehran': Duration(hours: 3, minutes: 30),
  'UTC': Duration.zero,
};

const defaultBranchZone = 'Asia/Kabul';

/// The currencies a branch can keep its prices in: AFN only for now (decided
/// 2026-09-14). Amounts already in USD, PKR or EUR still display.
const branchCurrencies = {'AFN'};

/// A branch's time zone and currency are ones the shop supports. Raises
/// [ValidationError] `BRANCH_TIMEZONE_INVALID` or `BRANCH_CURRENCY_INVALID`.
void assertBranchSettingsValid({required String timezone, required String currencyDefault}) {
  if (!branchZoneOffsets.containsKey(timezone)) {
    throw ValidationError('BRANCH_TIMEZONE_INVALID', {'timezone': timezone});
  }
  if (!branchCurrencies.contains(currencyDefault)) {
    throw ValidationError('BRANCH_CURRENCY_INVALID', {'currency': currencyDefault});
  }
}

Duration _offset(String zone) => branchZoneOffsets[zone] ?? branchZoneOffsets[defaultBranchZone]!;

/// [instant] on the wall clock of a branch in [zone]: a UTC [DateTime] whose
/// fields read as the branch's local time. A zone this table lacks (an old
/// cached profile) reads as Kabul's.
DateTime branchWallClock(String zone, DateTime instant) => instant.toUtc().add(_offset(zone));

/// The business day of a branch in [zone] that holds [instant]: from the
/// branch's local midnight to the next, as UTC instants ([start] inclusive,
/// [end] exclusive). "Today" in every report is this range, never UTC's day or
/// the device's.
({DateTime start, DateTime end}) businessDay(String zone, DateTime instant) {
  final local = branchWallClock(zone, instant);
  final start = DateTime.utc(local.year, local.month, local.day).subtract(_offset(zone));
  return (start: start, end: start.add(const Duration(days: 1)));
}
