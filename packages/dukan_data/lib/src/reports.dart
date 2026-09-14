import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';

class TopSeller {
  const TopSeller(this.name, this.qtyMinor, {this.decimalPlaces = 0, this.unitName = '', this.revenueMinor = 0});
  final String name;
  final int qtyMinor;
  final int decimalPlaces;
  final String unitName;
  final int revenueMinor;

  /// The quantity for people: "1.500 kg", not 1500.
  String get qtyLabel {
    final qty = formatQuantity(qtyMinor, decimalPlaces);
    return unitName.isEmpty ? qty : '$qty $unitName';
  }
}

/// Read-model projection for the dashboard. Computed from the local ledgers
/// (offline-first). See docs/domain/read-models-sync-audit.md.
class DashboardData {
  const DashboardData({
    required this.salesTodayMinor,
    required this.profitTodayMinor,
    required this.outstandingDebtMinor,
    required this.lowStockCount,
    required this.topSellers,
    this.unknownCostLines = 0,
  });
  final int salesTodayMinor;
  final int profitTodayMinor;
  final int outstandingDebtMinor;
  final int lowStockCount;
  final List<TopSeller> topSellers;

  /// Today's lines sold without a cost: profit counts them as free.
  final int unknownCostLines;
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

/// Reporting queries over the local database. Reports are projections, not
/// aggregates — always reconstructable from the ledgers.
final class LocalReports {
  LocalReports(this._db);
  final AppDatabase _db;

  /// [lowStockThreshold] is in whole units of each product's unit: 5 kg is
  /// 5000 grams, 5 pieces is 5.
  /// "Today" is the business day of the branch's [zone] (docs/domain/branches.md),
  /// not the device's day: a till set to another zone counts the same sales.
  Future<DashboardData> dashboard(
    String branchId, {
    String zone = defaultBranchZone,
    DateTime? now,
    int lowStockThreshold = 5,
  }) async {
    final today = businessDay(zone, now ?? DateTime.now());
    bool isToday(DateTime d) => !d.isBefore(today.start) && d.isBefore(today.end);

    final units = {for (final u in await _db.select(_db.units).get()) u.id: u};
    final products = await (_db.select(_db.products)..where((t) => t.deletedAt.isNull())).get();
    final unitOf = {for (final p in products) p.id: units[p.unitId]};

    final settled = await (_db.select(_db.sales)
          ..where((t) => t.branchId.equals(branchId) & t.status.equals('settled')))
        .get();
    final todaySales = settled.where((s) => isToday(s.occurredAt)).toList();
    final salesToday = todaySales.fold<int>(0, (sum, s) => sum + s.totalMinor);
    final todayIds = todaySales.map((s) => s.id).toSet();

    final lines = await (_db.select(_db.saleLines)..where((t) => t.saleId.isIn(todayIds))).get();
    var costs = 0;
    var unknownCost = 0;
    final sellers = <String, TopSeller>{};
    for (final ln in lines) {
      costs += lineTotalMinor(ln.unitCostMinor, ln.qtyMinor, ln.decimalPlaces);
      if (ln.unitCostMinor == 0) unknownCost++; // sold before any cost was known
      final prev = sellers[ln.productId];
      sellers[ln.productId] = TopSeller(
        ln.name, (prev?.qtyMinor ?? 0) + ln.qtyMinor,
        decimalPlaces: ln.decimalPlaces,
        unitName: unitOf[ln.productId]?.name ?? '',
        revenueMinor: (prev?.revenueMinor ?? 0) + ln.lineTotalMinor,
      );
    }

    final ledger = await (_db.select(_db.customerLedger)..where((t) => t.deletedAt.isNull())).get();
    final debt = ledger.fold<int>(
        0, (sum, e) => sum + (e.type == 'payment' ? -e.amountMinor : e.amountMinor));

    final moves = await (_db.select(_db.stockMovements)
          ..where((t) => t.branchId.equals(branchId) & t.deletedAt.isNull()))
        .get();
    final onHand = <String, int>{};
    for (final m in moves) {
      onHand[m.productId] = (onHand[m.productId] ?? 0) + m.qtyDelta;
    }
    var lowCount = 0;
    for (final p in products) {
      if (!p.trackStock || !p.isActive) continue;
      final scale = _pow10(units[p.unitId]?.decimalPlaces ?? 0);
      if ((onHand[p.id] ?? 0) <= lowStockThreshold * scale) lowCount++;
    }

    // Ranked by revenue: 2 kg of rice and 500 soaps are not comparable counts.
    final top = sellers.values.toList()..sort((a, b) => b.revenueMinor.compareTo(a.revenueMinor));

    return DashboardData(
      salesTodayMinor: salesToday,
      // What the sales took (after discounts), less what the goods cost.
      profitTodayMinor: salesToday - costs,
      outstandingDebtMinor: debt,
      lowStockCount: lowCount,
      topSellers: top.take(5).toList(),
      unknownCostLines: unknownCost,
    );
  }
}
