import 'package:dukan_core/dukan_core.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart adds, increments, and computes the total (piece unit)', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cart = c.read(posCartProvider.notifier);
    final p = Product(id: 'p1', sku: 'P1', name: 'Soap', unitId: 'piece', sellPrice: Money(52000, 'AFN'));

    cart.add(p, 0);
    cart.add(p, 0);
    expect(c.read(posCartProvider).length, 1);
    expect(c.read(posCartProvider).first.qtyMinor, 2);
    expect(cart.totalMinor, 104000);

    cart.dec(0);
    expect(c.read(posCartProvider).first.qtyMinor, 1);
    cart.dec(0);
    expect(c.read(posCartProvider).isEmpty, isTrue);
  });

  test('kg product adds one whole unit as minor units', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cart = c.read(posCartProvider.notifier);
    final p = Product(id: 'p2', sku: 'P2', name: 'Rice', unitId: 'kg', sellPrice: Money(52000, 'AFN'));

    cart.add(p, 3); // 1 kg = 1000 minor
    expect(c.read(posCartProvider).first.qtyMinor, 1000);
    expect(cart.totalMinor, 52000);
  });
}
