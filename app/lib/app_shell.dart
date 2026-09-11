import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/auth_controller.dart';
import 'features/auth/auth_state.dart';
import 'features/catalog/product_list_screen.dart';
import 'features/customers/customers_screen.dart';
import 'features/pos/pos_screen.dart';
import 'features/purchasing/receive_stock_screen.dart';
import 'l10n/app_localizations.dart';
import 'widgets/locale_toggle.dart';

/// The authenticated shell. Phase 1 shows the signed-in user + branch and a
/// sign-out; POS / inventory / dashboard navigation arrives in later phases.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    if (state is! AuthLoggedIn) return const SizedBox.shrink();
    final profile = state.profile;
    final branch = profile.branches;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          const LocaleToggle(),
          IconButton(
            tooltip: l.logout,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, size: 48),
            const SizedBox(height: 12),
            Text(l.signedInAs(profile.displayName),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(_branchLabel(branch), style: Theme.of(context).textTheme.bodyMedium),
            if (state.offline) ...[
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.cloud_off, size: 18),
                label: Text(l.offlineMode),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PosScreen()),
              ),
              icon: const Icon(Icons.point_of_sale),
              label: Text(l.pos),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ProductListScreen()),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: Text(l.products),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CustomersScreen()),
                  ),
                  icon: const Icon(Icons.people_outline),
                  label: Text(l.customers),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ReceiveStockScreen()),
                  ),
                  icon: const Icon(Icons.add_box_outlined),
                  label: Text(l.receiveStock),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _branchLabel(String branchesJson) {
    try {
      final list = (jsonDecode(branchesJson) as List).cast<Map<String, dynamic>>();
      return list
          .map((b) => '${b['branch_name']} · ${b['role_name']}')
          .join('   ');
    } on Object {
      return '';
    }
  }
}
