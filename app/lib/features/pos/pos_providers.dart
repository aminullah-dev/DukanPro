import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../../infrastructure/auth_api.dart' show NetworkException;
import '../../infrastructure/sales_api.dart';
import '../auth/providers.dart';
import '../auth/session.dart';
import '../sync/sync_providers.dart';

final localSalesProvider = Provider<LocalSales>((ref) => LocalSales(ref.watch(databaseProvider)));

/// The server's sales endpoints (a void). Overridden in main; tests fake it.
final salesApiProvider =
    Provider<SalesApi>((ref) => throw UnimplementedError('override salesApiProvider in main'));

/// Voids a sale from the till. The server owns money and stock, so this runs
/// online: the sale is pushed first (the server must know it), the void is
/// asked for, and the reversal is pulled back to this device.
class TillVoid {
  TillVoid({required this.api, required this.sync, required this.synced});
  final SalesApi api;
  final Future<void> Function() sync;

  /// Whether the last [sync] reached the server.
  final bool Function() synced;

  Future<void> call(String saleId, {required String reason}) async {
    await sync();
    if (!synced()) throw const NetworkException();
    await api.voidSale(saleId, reason: reason);
    await sync();
  }
}

final tillVoidProvider = Provider<TillVoid>((ref) => TillVoid(
      api: ref.watch(salesApiProvider),
      sync: () => ref.read(syncControllerProvider.notifier).syncNow(),
      synced: () => !ref.read(syncControllerProvider).failed,
    ));

/// Takes goods back from a sale at the till: online, like a void. The sale is
/// pushed first, the return asked for, and the new negative sale pulled back.
class TillRefund {
  TillRefund({required this.api, required this.sync, required this.synced});
  final SalesApi api;
  final Future<void> Function() sync;

  /// Whether the last [sync] reached the server.
  final bool Function() synced;

  Future<RefundDone> call(
    String saleId, {
    required Map<String, int> lines,
    required String reason,
    required String method,
    String? shiftId,
  }) async {
    await sync();
    if (!synced()) throw const NetworkException();
    final done = await api.refundSale(saleId, lines: lines, reason: reason, method: method, shiftId: shiftId);
    await sync();
    return done;
  }
}

final tillRefundProvider = Provider<TillRefund>((ref) => TillRefund(
      api: ref.watch(salesApiProvider),
      sync: () => ref.read(syncControllerProvider.notifier).syncNow(),
      synced: () => !ref.read(syncControllerProvider).failed,
    ));

final localShiftsProvider = Provider<LocalShifts>((ref) => LocalShifts(ref.watch(databaseProvider)));

/// The signed-in seller's open shift in their branch, or null: the POS sells
/// only into an open shift, so every sale's cash is in some drawer's count.
final currentShiftProvider = FutureProvider<ShiftRow?>((ref) async {
  final actor = ref.watch(sessionActorProvider);
  if (actor == null) return null;
  // This till's own drawer: the seller may have another shift open on another till.
  return ref
      .watch(localShiftsProvider)
      .current(branchId: actor.branchId, userId: actor.user.id, deviceId: ref.watch(deviceIdProvider));
});

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
            trackStock: l.product.trackStock,
          ))
      .toList();

  int get totalMinor => computeTotals(toSaleLines()).totalMinor;
}

final posCartProvider = NotifierProvider<PosCart, List<CartLine>>(PosCart.new);
