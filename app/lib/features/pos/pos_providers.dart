import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../auth/providers.dart';
import '../auth/session.dart';

final localSalesProvider = Provider<LocalSales>((ref) => LocalSales(ref.watch(databaseProvider)));

/// Hardware barcode scans (keyboard-wedge). POS listens and adds the matching
/// product to the cart hands-free.
final posScanProvider = StreamProvider<ScanEvent>((ref) => ref.watch(scannerProvider).scans());

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

class CartLine {
  const CartLine({
    required this.product,
    required this.qtyMinor,
    required this.decimalPlaces,
    this.unitName = '',
  });
  final Product product;
  final int qtyMinor;
  final int decimalPlaces;
  final String unitName;

  int get lineTotal => lineTotalMinor(product.sellPrice.amountMinor, qtyMinor, decimalPlaces);

  /// "1.500 kg"; just the number when the unit has no name.
  String get qtyLabel {
    final qty = formatQuantity(qtyMinor, decimalPlaces);
    return unitName.isEmpty ? qty : '$qty $unitName';
  }

  CartLine copyWith({int? qtyMinor}) => CartLine(
        product: product, qtyMinor: qtyMinor ?? this.qtyMinor, decimalPlaces: decimalPlaces,
        unitName: unitName,
      );
}

class PosCart extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() {
    ref.watch(sessionUserIdProvider); // a new user starts with an empty cart
    return const [];
  }

  /// One more whole unit of [product] (1 piece, 1 kg), in its unit.
  void add(Product product, int decimalPlaces, {String unitName = ''}) {
    final step = _pow10(decimalPlaces);
    final idx = state.indexWhere((l) => l.product.id == product.id);
    if (idx >= 0) {
      final next = [...state];
      next[idx] = next[idx].copyWith(qtyMinor: next[idx].qtyMinor + step);
      state = next;
    } else {
      state = [
        ...state,
        CartLine(product: product, qtyMinor: step, decimalPlaces: decimalPlaces, unitName: unitName),
      ];
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

  /// A quantity typed for line [i], e.g. 0.750 kg of sugar. Zero removes it.
  void setQty(int i, int qtyMinor) {
    final next = [...state];
    if (qtyMinor <= 0) {
      next.removeAt(i);
    } else {
      next[i] = next[i].copyWith(qtyMinor: qtyMinor);
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
