import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import 'catalog/catalog_providers.dart';
import 'customers/customers_providers.dart';
import 'dashboard/dashboard_screen.dart';
import 'pos/pos_providers.dart';

/// Every figure a screen shows from the local ledgers: products and on-hand,
/// customers and their balances, suppliers and theirs, the dashboard and the
/// open shift. Called after anything that changes them (a sale, a receipt, a
/// sync) and when a pane comes back into view, so no screen shows old numbers.
void refreshReadModels(void Function(ProviderOrFamily provider) invalidate) {
  for (final provider in <ProviderOrFamily>[
    productsProvider,
    unitsProvider,
    onHandProvider,
    customersProvider,
    customerBalanceProvider,
    suppliersProvider,
    supplierBalanceProvider,
    dashboardProvider,
    currentShiftProvider,
  ]) {
    invalidate(provider);
  }
}
