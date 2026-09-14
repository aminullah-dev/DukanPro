import 'package:dukan_core/dukan_core.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a cart line takes a typed fraction of a kg and shows its unit', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final rice = Product(id: 'r', sku: 'R', name: 'Rice', unitId: 'kg', sellPrice: Money(8000, 'AFN'));
    final cart = c.read(posCartProvider.notifier)..add(rice, 3, unitName: 'kg');
    expect(c.read(posCartProvider).single.qtyLabel, '1.000 kg');

    cart.setQty(0, 750); // 0.750 kg of rice
    expect(c.read(posCartProvider).single.qtyLabel, '0.750 kg');
    expect(c.read(posCartProvider).single.lineTotal, 6000);

    cart.setQty(0, 0);
    expect(c.read(posCartProvider), isEmpty);
  });
}
