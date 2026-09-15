import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';

final localCustomersProvider = Provider<LocalCustomers>(
  (ref) => LocalCustomers(ref.watch(databaseProvider)),
);

final localPurchasingProvider = Provider<LocalPurchasing>(
  (ref) => LocalPurchasing(ref.watch(databaseProvider)),
);

final customersProvider = FutureProvider<List<Customer>>(
  (ref) => ref.watch(localCustomersProvider).list(),
);

final customerBalanceProvider = FutureProvider.family<int, String>(
  (ref, id) => ref.watch(localCustomersProvider).balance(id),
);

final suppliersProvider = FutureProvider<List<Supplier>>(
  (ref) => ref.watch(localPurchasingProvider).listSuppliers(),
);

/// What the shop owes a supplier: bills less payments.
final supplierBalanceProvider = FutureProvider.family<int, String>(
  (ref, id) => ref.watch(localPurchasingProvider).supplierBalance(id),
);
