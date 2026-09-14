import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../auth/providers.dart';
import '../catalog/catalog_providers.dart';
import '../auth/session.dart';

final localSalesProvider = Provider<LocalSales>((ref) => LocalSales(ref.watch(databaseProvider)));

/// Hardware barcode scans (keyboard-wedge). POS listens and adds the matching
/// product to the cart hands-free.
final posScanProvider = StreamProvider<ScanEvent>((ref) => ref.watch(scannerProvider).scans());

/// unitId → decimalPlaces, for converting cart counts to minor units.
final unitDecimalsProvider = FutureProvider<Map<String, int>>((ref) async {
  final units = await ref.watch(unitsProvider.future);
  return {for (final u in units) u.id: u.decimalPlaces};
});

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

class CartLine {
  const CartLine({required this.product, required this.qtyMinor, required this.decimalPlaces});
  final Product product;
  final int qtyMinor;
  final int decimalPlaces;

  int get lineTotal => lineTotalMinor(product.sellPrice.amountMinor, qtyMinor, decimalPlaces);
  String get qtyLabel => formatQuantity(qtyMinor, decimalPlaces);

  CartLine copyWith({int? qtyMinor}) =>
      CartLine(product: product, qtyMinor: qtyMinor ?? this.qtyMinor, decimalPlaces: decimalPlaces);
}

class PosCart extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() {
    ref.watch(sessionUserIdProvider); // a new user starts with an empty cart
    return const [];
  }

  void add(Product product, int decimalPlaces) {
    final step = _pow10(decimalPlaces);
    final idx = state.indexWhere((l) => l.product.id == product.id);
    if (idx >= 0) {
      final next = [...state];
      next[idx] = next[idx].copyWith(qtyMinor: next[idx].qtyMinor + step);
      state = next;
    } else {
      state = [...state, CartLine(product: product, qtyMinor: step, decimalPlaces: decimalPlaces)];
    }
  }

  void inc(int i) {
    final l = state[i];
    final next = [...state];
    next[i] = l.copyWith(qtyMinor: l.qtyMinor + _pow10(l.decimalPlaces));
    state = next;
  }

  void dec(int i) {
    final l = state[i];
    final q = l.qtyMinor - _pow10(l.decimalPlaces);
    final next = [...state];
    if (q <= 0) {
      next.removeAt(i);
    } else {
      next[i] = l.copyWith(qtyMinor: q);
    }
    state = next;
  }

  void removeAt(int i) => state = ([...state]..removeAt(i));

  void clear() => state = const [];

  List<SaleLine> toSaleLines() => state
      .map((l) => SaleLine(
            productId: l.product.id, name: l.product.name, qtyMinor: l.qtyMinor,
            decimalPlaces: l.decimalPlaces, unitPriceMinor: l.product.sellPrice.amountMinor,
            unitCostMinor: l.product.cost?.amountMinor ?? 0, currency: l.product.sellPrice.currency,
          ))
      .toList();

  int get totalMinor => computeTotals(toSaleLines()).totalMinor;
}

final posCartProvider = NotifierProvider<PosCart, List<CartLine>>(PosCart.new);
