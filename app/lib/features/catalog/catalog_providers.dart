import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';

/// Local, offline-first catalog store over the Drift database.
final localCatalogProvider = Provider<LocalCatalog>(
  (ref) => LocalCatalog(ref.watch(databaseProvider)),
);

/// The product list (re-fetched when invalidated after a write).
final productsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(localCatalogProvider).products.list(),
);

/// Available units (seeded on first read).
final unitsProvider = FutureProvider<List<UnitRow>>(
  (ref) => ref.watch(localCatalogProvider).listUnits(),
);

/// On-hand for a product in a branch: (productId, branchId).
final onHandProvider = FutureProvider.family<int, (String, String)>(
  (ref, key) => ref.watch(localCatalogProvider).onHand(key.$1, key.$2),
);
