import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../auth/providers.dart';
import '../auth/session.dart';

final localSalesProvider = Provider<LocalSales>((ref) => LocalSales(ref.watch(databaseProvider)));

/// A return the till recorded: the sale that names the one it takes goods back
/// from. Amounts are positive here: what the goods were worth, and what the shop
/// handed back (the rest came off the customer's account).
final class RefundDone {
  const RefundDone({
    required this.id,
    required this.number,
    required this.totalMinor,
    required this.moneyBackMinor,
  });
  final String id;
  final String number;
  final int totalMinor;
  final int moneyBackMinor;
}

/// Voids a sale from the till, with or without a connection: the till writes the
/// void, the stock coming back and the debt coming off in one transaction, and
/// sync carries them to the server together (docs/domain/sales.md).
class TillVoid {
  TillVoid({required this.sales, required this.actorId, required this.deviceId});
  final LocalSales sales;
  final String? actorId;
  final String deviceId;

  Future<void> call(String saleId, {required String reason}) {
    final actor = actorId;
    if (actor == null) {
      throw PermissionDeniedError('ACCESS_DENIED', {'permission': Permission.saleVoid.code});
    }
    return sales.voidSale(saleId: saleId, reason: reason, actorId: actor, deviceId: deviceId);
  }
}

final tillVoidProvider = Provider<TillVoid>((ref) => TillVoid(
      sales: ref.watch(localSalesProvider),
      actorId: ref.watch(sessionActorProvider)?.user.id,
      deviceId: ref.watch(deviceIdProvider),
    ));

/// Takes goods back from a sale at the till, with or without a connection. Cash
/// handed back comes out of this till's open drawer.
class TillRefund {
  TillRefund({
    required this.sales,
    required this.actorId,
    required this.deviceId,
    required this.openShift,
  });
  final LocalSales sales;
  final String? actorId;
  final String deviceId;
  final Future<String?> Function() openShift;

  Future<RefundDone> call(
    String saleId, {
    required Map<String, int> lines,
    required String reason,
    required String method,
  }) async {
    final actor = actorId;
    if (actor == null) {
      throw PermissionDeniedError('ACCESS_DENIED', {'permission': Permission.saleVoid.code});
    }
    final refund = await sales.refund(
      saleId: saleId, lines: lines, reason: reason, method: method, shiftId: await openShift(),
      actorId: actor, deviceId: deviceId,
    );
    return RefundDone(
      id: refund.id, number: refund.number, totalMinor: -refund.totalMinor,
      moneyBackMinor: -refund.paidMinor,
    );
  }
}

final tillRefundProvider = Provider<TillRefund>((ref) => TillRefund(
      sales: ref.watch(localSalesProvider),
      actorId: ref.watch(sessionActorProvider)?.user.id,
      deviceId: ref.watch(deviceIdProvider),
      openShift: () async => (await ref.read(currentShiftProvider.future))?.id,
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
