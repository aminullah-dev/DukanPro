import 'package:dukan_data/dukan_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/locale_toggle.dart';
import '../auth/providers.dart';
import '../auth/session.dart';

final localReportsProvider = Provider<LocalReports>(
  (ref) => LocalReports(ref.watch(databaseProvider)),
);

final dashboardProvider = FutureProvider<DashboardData>((ref) {
  final branch = ref.watch(sessionActorProvider)?.branchId ?? '';
  return ref.watch(localReportsProvider).dashboard(branch);
});

String _afn(int minor) => (minor / 100).toStringAsFixed(2);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboard),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(dashboardProvider)),
          const LocaleToggle(),
          const SizedBox(width: 8),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9,
              children: [
                _Tile(label: l.salesToday, value: '${_afn(d.salesTodayMinor)} AFN', icon: Icons.today, color: const Color(0xFF0F6B5C)),
                _Tile(
                  label: l.profit, value: '${_afn(d.profitTodayMinor)} AFN', icon: Icons.trending_up,
                  color: const Color(0xFF1B7F4B),
                  // Lines sold without a cost count as free: say how many.
                  note: d.unknownCostLines > 0 ? l.profitMissingCost(d.unknownCostLines) : null,
                ),
                _Tile(label: l.outstandingDebt, value: '${_afn(d.outstandingDebtMinor)} AFN', icon: Icons.account_balance_wallet, color: const Color(0xFFC2571F)),
                _Tile(label: l.lowStock, value: '${d.lowStockCount}', icon: Icons.warning_amber, color: const Color(0xFFB5820B)),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.topSellers, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (d.topSellers.isEmpty)
              Text('—', style: Theme.of(context).textTheme.bodyMedium)
            else
              for (final s in d.topSellers)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.star_outline),
                  title: Text(s.name),
                  trailing: Text(s.qtyLabel),
                ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, required this.icon, required this.color, this.note});
  final String label;
  final String? note;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (note != null)
              Text(note!, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
