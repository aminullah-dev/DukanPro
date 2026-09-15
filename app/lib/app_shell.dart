import 'dart:convert';

import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/auth_state.dart';
import 'features/audit/audit_log_screen.dart';
import 'features/iam/iam_providers.dart';
import 'features/audit/audit_providers.dart';
import 'features/auth/session.dart';
import 'features/auth/session_guard.dart';
import 'features/catalog/product_list_screen.dart';
import 'features/customers/customers_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/iam/branches_screen.dart';
import 'features/iam/employees_screen.dart';
import 'features/iam/iam_ui.dart' show roleLabel;
import 'features/insights/notifications_bell.dart';
import 'features/pos/pos_screen.dart';
import 'features/purchasing/receive_stock_screen.dart';
import 'features/purchasing/suppliers_screen.dart';
import 'features/settings/printer_settings_screen.dart';
import 'features/settings/settings_providers.dart';
import 'features/sync/sync_button.dart';
import 'features/sync/sync_providers.dart';
import 'features/read_models.dart';
import 'l10n/app_localizations.dart';
import 'widgets/locale_toggle.dart';
import 'widgets/shell_scope.dart';

/// Tablet/desktop breakpoint — at or above this the shell shows a persistent
/// navigation rail instead of the phone landing page.
const double kWideBreakpoint = 840;

bool isWideLayout(double width) => width >= kWideBreakpoint;

/// One navigable area of the app.
class _Destination {
  const _Destination(this.id, this.icon, this.label, this.screen);
  final String id; // stable across languages: keys the pane
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
      if (can(Permission.saleCreate)) _Destination('pos', Icons.point_of_sale, l.pos, const PosScreen()),
      _Destination('products', Icons.inventory_2_outlined, l.products, const ProductListScreen()),
      _Destination('customers', Icons.people_outline, l.customers, const CustomersScreen()),
      if (can(Permission.stockAdjust))
        _Destination('receive', Icons.add_box_outlined, l.receiveStock, const ReceiveStockScreen()),
      if (can(Permission.purchaseCost) || can(Permission.productManage))
        _Destination('suppliers', Icons.local_shipping_outlined, l.suppliers, const SuppliersScreen()),
      if (can(Permission.reportView))
        _Destination('dashboard', Icons.dashboard_outlined, l.dashboard, const DashboardScreen()),
      if (can(Permission.userManage))
        _Destination('employees', Icons.badge_outlined, l.employees, const EmployeesScreen()),
      if (can(Permission.branchManage))
        _Destination('branches', Icons.store_mall_directory_outlined, l.branches, const BranchesScreen()),
      if (can(Permission.auditView))
        _Destination('audit', Icons.history, l.auditLog, const AuditLogScreen()),
      _Destination('settings', Icons.settings_outlined, l.settings, const PrinterSettingsScreen()),
    ];

    final showBell = can(Permission.reportView);
    // Chosen per device by an owner or manager; 10 minutes until they do.
    final idleMinutes = ref.watch(idleLockProvider).asData?.value ?? kDefaultIdleLockMinutes;
    return SessionGuard(
      onLock: () => ref.read(authControllerProvider.notifier).lock(),
      idleLock: Duration(minutes: idleMinutes),
      child: _Shell(features: features, showBell: showBell),
    );
  }
}

/// Signing out wipes this device's saved sign-in, so an offline shop could not
/// sell until someone signs in online again: always confirm, and say so.
Future<void> confirmLogout(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final pending = ref.read(syncControllerProvider).pending;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.logoutConfirmTitle),
      content: Text([l.logoutConfirmBody, if (pending > 0) l.logoutPendingWarning(pending)].join('\n\n')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.logout)),
      ],
    ),
  );
  if (ok ?? false) await ref.read(authControllerProvider.notifier).logout();
}

/// The authenticated shell: one tree for every width. A pane is built on its
/// first visit and kept, with its state, as the layout switches between a
/// phone's drawer and the wide layout's rail: crossing the breakpoint (a
/// rotation, a resized window) loses nothing, and no pane ever exists twice.
class _Shell extends ConsumerStatefulWidget {
  const _Shell({required this.features, required this.showBell});
  final List<_Destination> features;
  final bool showBell;
  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  static const _home = 'home';
  final _scaffold = GlobalKey<ScaffoldState>();
  final _keys = <String, GlobalKey>{};
  final _visited = <String>{_home};
  String _selected = _home;

  void _select(String id) {
    if (id == _selected) return;
    setState(() {
      _selected = id;
      _visited.add(id);
    });
    // A pane coming back into view shows current figures, not those it last loaded.
    refreshReadModels(ref.invalidate);
    // Panes read from the server refresh as they come into view too.
    switch (id) {
      case 'audit':
        ref.invalidate(auditLogProvider);
      case 'employees':
        ref.invalidate(employeesControllerProvider);
      case 'branches':
        ref.invalidate(branchesControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wide = isWideLayout(MediaQuery.sizeOf(context).width);
    final all = [
      _Destination(
        _home, Icons.home_outlined, l.appTitle,
        _HomePane(
          features: widget.features, showTiles: !wide, showShellActions: !wide,
          showBell: widget.showBell && !wide, onOpen: _select,
        ),
      ),
      ...widget.features,
    ];
    var index = all.indexWhere((d) => d.id == _selected);
    if (index < 0) index = 0; // a destination the user's role no longer has
    final selected = all[index].id;
    final panes = IndexedStack(
      index: index,
      children: [
        for (final d in all)
          if (_visited.contains(d.id))
            KeyedSubtree(
              key: _keys.putIfAbsent(d.id, GlobalKey.new),
              // A hidden pane's tickers stop, and the POS takes no scans there.
              child: TickerMode(enabled: d.id == selected, child: d.screen),
            )
          else
            const SizedBox.shrink(),
      ],
    );
    return ShellScope(
      wide: wide,
      openMenu: () => _scaffold.currentState?.openDrawer(),
      child: PopScope(
        // On a phone, back goes to the home pane before it leaves the app.
        canPop: wide || selected == _home,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final scaffold = _scaffold.currentState;
          if (scaffold != null && scaffold.isDrawerOpen) {
            scaffold.closeDrawer(); // back closes the menu first
          } else {
            _select(_home);
          }
        },
        child: Scaffold(
          key: _scaffold,
          drawer: wide ? null : _MenuDrawer(destinations: all, selected: selected, onSelect: _select),
          body: wide
              ? Row(children: [
                  _rail(l, all, index),
                  const VerticalDivider(width: 1),
                  Expanded(child: panes),
                ])
              : panes,
        ),
      ),
    );
  }

  Widget _rail(AppLocalizations l, List<_Destination> all, int index) => SingleChildScrollView(
        child: IntrinsicHeight(
          child: NavigationRail(
            extended: MediaQuery.sizeOf(context).width >= 1200,
            selectedIndex: index,
            onDestinationSelected: (i) => _select(all[i].id),
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
                        tooltip: l.lock,
                        icon: const Icon(Icons.lock_outline),
                        onPressed: () => ref.read(authControllerProvider.notifier).lock(),
                      ),
                      IconButton(
                        tooltip: l.logout,
                        icon: const Icon(Icons.logout),
                        onPressed: () => confirmLogout(context, ref),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: [
              for (final d in all) NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)),
            ],
          ),
        ),
      );
}

/// A phone's navigation: the shell's destinations in a drawer.
class _MenuDrawer extends StatelessWidget {
  const _MenuDrawer({required this.destinations, required this.selected, required this.onSelect});
  final List<_Destination> destinations;
  final String selected;
  final void Function(String id) onSelect;

  @override
  Widget build(BuildContext context) => Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              for (final d in destinations)
                ListTile(
                  leading: Icon(d.icon),
                  title: Text(d.label),
                  selected: d.id == selected,
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    onSelect(d.id);
                  },
                ),
            ],
          ),
        ),
      );
}

enum _HomeAction { lock, logout }

/// The home / landing pane. On a phone it shows navigation tiles and the shell
/// actions; inside the wide rail it shows only the summary.
class _HomePane extends ConsumerWidget {
  const _HomePane({
    required this.features,
    required this.showTiles,
    required this.showShellActions,
    required this.showBell,
    this.onOpen,
  });
  final List<_Destination> features;
  final bool showTiles;
  final bool showShellActions;
  final bool showBell;

  /// Opens a destination (its id) in the shell.
  final void Function(String id)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    if (state is! AuthLoggedIn) return const SizedBox.shrink();
    final profile = state.profile;

    return Scaffold(
      appBar: AppBar(
        leading: ShellScope.menuButton(context),
        // On the narrowest phones the name scales down rather than being cut off.
        title: FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: Text(l.appTitle)),
        // A phone's bar keeps its title: lock and sign-out wait in a menu.
        actions: showShellActions
            ? [
                if (showBell) const NotificationsBell(),
                const SyncAction(),
                const LocaleToggle(),
                PopupMenuButton<_HomeAction>(
                  onSelected: (a) => switch (a) {
                    _HomeAction.lock => ref.read(authControllerProvider.notifier).lock(),
                    _HomeAction.logout => confirmLogout(context, ref),
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _HomeAction.lock,
                      child: ListTile(leading: const Icon(Icons.lock_outline), title: Text(l.lock)),
                    ),
                    PopupMenuItem(
                      value: _HomeAction.logout,
                      child: ListTile(leading: const Icon(Icons.logout), title: Text(l.logout)),
                    ),
                  ],
                ),
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
              Text(_branchLabel(l, profile.branches), style: Theme.of(context).textTheme.bodyMedium),
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
                        onPressed: () => onOpen?.call(d.id),
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

  String _branchLabel(AppLocalizations l, String branchesJson) {
    try {
      final list = (jsonDecode(branchesJson) as List).cast<Map<String, dynamic>>();
      return list.map((b) => l.branchRole('${b['branch_name']}', roleLabel(l, '${b['role_name']}'))).join('   ');
    } on Object {
      return '';
    }
  }
}
