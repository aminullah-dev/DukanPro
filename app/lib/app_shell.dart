import 'dart:convert';

import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/auth_state.dart';
import 'features/audit/audit_log_screen.dart';
import 'features/auth/session.dart';
import 'features/catalog/product_list_screen.dart';
import 'features/customers/customers_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/iam/branches_screen.dart';
import 'features/iam/employees_screen.dart';
import 'features/insights/notifications_bell.dart';
import 'features/pos/pos_screen.dart';
import 'features/purchasing/receive_stock_screen.dart';
import 'features/settings/printer_settings_screen.dart';
import 'features/sync/sync_button.dart';
import 'l10n/app_localizations.dart';
import 'widgets/locale_toggle.dart';

/// Tablet/desktop breakpoint — at or above this the shell shows a persistent
/// navigation rail instead of the phone landing page.
const double kWideBreakpoint = 840;

bool isWideLayout(double width) => width >= kWideBreakpoint;

/// One navigable area of the app.
class _Destination {
  const _Destination(this.icon, this.label, this.screen);
  final IconData icon;
  final String label;
  final Widget screen;
}

/// The authenticated shell. Adapts between a phone landing page (narrow) and a
/// navigation-rail master/detail layout (tablet, iPad, macOS, desktop).
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    if (state is! AuthLoggedIn) return const SizedBox.shrink();
    final actor = ref.watch(sessionActorProvider);
    bool can(Permission p) => actor?.can(p) ?? false;

    final features = <_Destination>[
      if (can(Permission.saleCreate)) _Destination(Icons.point_of_sale, l.pos, const PosScreen()),
      _Destination(Icons.inventory_2_outlined, l.products, const ProductListScreen()),
      _Destination(Icons.people_outline, l.customers, const CustomersScreen()),
      if (can(Permission.stockAdjust))
        _Destination(Icons.add_box_outlined, l.receiveStock, const ReceiveStockScreen()),
      if (can(Permission.reportView))
        _Destination(Icons.dashboard_outlined, l.dashboard, const DashboardScreen()),
      if (can(Permission.userManage))
        _Destination(Icons.badge_outlined, l.employees, const EmployeesScreen()),
      if (can(Permission.branchManage))
        _Destination(Icons.store_mall_directory_outlined, l.branches, const BranchesScreen()),
      if (can(Permission.auditView))
        _Destination(Icons.history, l.auditLog, const AuditLogScreen()),
      _Destination(Icons.settings_outlined, l.settings, const PrinterSettingsScreen()),
    ];

    final showBell = can(Permission.reportView);
    if (isWideLayout(MediaQuery.sizeOf(context).width)) {
      return _WideShell(features: features, showBell: showBell);
    }
    return _HomePane(
      features: features, showTiles: true, showShellActions: true, showBell: showBell,
    );
  }
}

/// Wide layout: a navigation rail beside the selected destination. The rail's
/// trailing area carries the shell actions (sync / locale / sign-out).
class _WideShell extends ConsumerStatefulWidget {
  const _WideShell({required this.features, required this.showBell});
  final List<_Destination> features;
  final bool showBell;
  @override
  ConsumerState<_WideShell> createState() => _WideShellState();
}

class _WideShellState extends ConsumerState<_WideShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Index 0 is Home; the rest are the feature destinations.
    final home = _HomePane(
      features: widget.features, showTiles: false, showShellActions: false, showBell: false,
    );
    final panes = <Widget>[home, for (final d in widget.features) d.screen];
    final extended = MediaQuery.sizeOf(context).width >= 1200;

    return Scaffold(
      body: Row(
        children: [
          SingleChildScrollView(
            child: IntrinsicHeight(
              child: NavigationRail(
                extended: extended,
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                leading: const Padding(padding: EdgeInsets.only(top: 8), child: Icon(Icons.storefront)),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.showBell) const NotificationsBell(),
                          const SyncAction(),
                          const LocaleToggle(),
                          IconButton(
                            tooltip: l.logout,
                            icon: const Icon(Icons.logout),
                            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                destinations: [
                  NavigationRailDestination(icon: const Icon(Icons.home_outlined), label: Text(l.appTitle)),
                  for (final d in widget.features)
                    NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: IndexedStack(index: _index, children: panes)),
        ],
      ),
    );
  }
}

/// The home / landing pane. On a phone it shows navigation tiles and the shell
/// actions; inside the wide rail it shows only the summary.
class _HomePane extends ConsumerWidget {
  const _HomePane({
    required this.features,
    required this.showTiles,
    required this.showShellActions,
    required this.showBell,
  });
  final List<_Destination> features;
  final bool showTiles;
  final bool showShellActions;
  final bool showBell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    if (state is! AuthLoggedIn) return const SizedBox.shrink();
    final profile = state.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: showShellActions
            ? [
                if (showBell) const NotificationsBell(),
                const SyncAction(),
                const LocaleToggle(),
                IconButton(
                  tooltip: l.logout,
                  icon: const Icon(Icons.logout),
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront, size: 48),
              const SizedBox(height: 12),
              Text(l.signedInAs(profile.displayName), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(_branchLabel(profile.branches), style: Theme.of(context).textTheme.bodyMedium),
              if (state.offline) ...[
                const SizedBox(height: 12),
                Chip(avatar: const Icon(Icons.cloud_off, size: 18), label: Text(l.offlineMode)),
              ],
              const SizedBox(height: 16),
              const SyncStatusCard(),
              if (showTiles) ...[
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final d in features)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => d.screen),
                        ),
                        icon: Icon(d.icon),
                        label: Text(d.label),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _branchLabel(String branchesJson) {
    try {
      final list = (jsonDecode(branchesJson) as List).cast<Map<String, dynamic>>();
      return list.map((b) => '${b['branch_name']} · ${b['role_name']}').join('   ');
    } on Object {
      return '';
    }
  }
}
