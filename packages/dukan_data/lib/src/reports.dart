import 'package:drift/drift.dart';
import 'package:dukan_core/dukan_core.dart';

import '../database.dart';

class TopSeller {
  const TopSeller(this.name, this.qtyMinor);
  final String name;
  final int qtyMinor;
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
  });
  final int salesTodayMinor;
  final int profitTodayMinor;
  final int outstandingDebtMinor;
  final int lowStockCount;
  final List<TopSeller> topSellers;
}

/// Reporting queries over the local database. Reports are projections, not
/// aggregates — always reconstructable from the ledgers.
final class LocalReports {
  LocalReports(this._db);
  final AppDatabase _db;

  Future<DashboardData> dashboard(String branchId, {int lowStockThreshold = 5}) async {
    final now = DateTime.now();
    bool isToday(DateTime d) {
      final local = d.toLocal();
      return local.year == now.year && local.month == now.month && local.day == now.day;
    }

    final settled = await (_db.select(_db.sales)
          ..where((t) => t.branchId.equals(branchId) & t.status.equals('settled')))
        .get();
    final todaySales = settled.where((s) => isToday(s.occurredAt)).toList();
    final salesToday = todaySales.fold<int>(0, (sum, s) => sum + s.totalMinor);
    final todayIds = todaySales.map((s) => s.id).toSet();

    final lines = await _db.select(_db.saleLines).get();
    var profit = 0;
    final sellers = <String, (String, int)>{};
    for (final ln in lines) {
      if (!todayIds.contains(ln.saleId)) continue;
      final costTotal = lineTotalMinor(ln.unitCostMinor, ln.qtyMinor, ln.decimalPlaces);
      profit += ln.lineTotalMinor - costTotal;
      final prev = sellers[ln.productId];
      sellers[ln.productId] = (ln.name, (prev?.$2 ?? 0) + ln.qtyMinor);
    }

    final ledger = await (_db.select(_db.customerLedger)..where((t) => t.deletedAt.isNull())).get();
    final debt = ledger.fold<int>(
        0, (sum, e) => sum + (e.type == 'payment' ? -e.amountMinor : e.amountMinor));

    final products = await (_db.select(_db.products)..where((t) => t.deletedAt.isNull())).get();
    final moves = await (_db.select(_db.stockMovements)
          ..where((t) => t.branchId.equals(branchId) & t.deletedAt.isNull()))
        .get();
    final onHand = <String, int>{};
    for (final m in moves) {
      onHand[m.productId] = (onHand[m.productId] ?? 0) + m.qtyDelta;
    }
    var lowCount = 0;
    for (final p in products) {
      if (p.trackStock && (onHand[p.id] ?? 0) <= lowStockThreshold) lowCount++;
    }

    final top = sellers.entries.map((e) => TopSeller(e.value.$1, e.value.$2)).toList()
      ..sort((a, b) => b.qtyMinor.compareTo(a.qtyMinor));

    return DashboardData(
      salesTodayMinor: salesToday,
      profitTodayMinor: profit,
      outstandingDebtMinor: debt,
      lowStockCount: lowCount,
      topSellers: top.take(5).toList(),
    );
  }
}
