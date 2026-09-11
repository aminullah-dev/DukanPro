import '../shared/errors.dart';
import '../shared/money.dart';

/// Catalog domain — simple products with multiple barcodes (no variants in
/// Phase 2). Mirrors docs/domain/catalog.md and server/dukan/domain/catalog.py.
/// Quantities are integers in the unit's minor granularity (10^decimalPlaces).

final class Unit {
  const Unit({required this.id, required this.name, required this.decimalPlaces});
  final String id;
  final String name;
  final int decimalPlaces; // 0 = whole units (piece), 3 = grams within a kg
}

final class Category {
  const Category({required this.id, required this.name, this.parentId});
  final String id;
  final String name;
  final String? parentId;
}

final class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.unitId,
    required this.sellPrice,
    this.categoryId,
    this.cost,
    this.trackStock = true,
    this.isActive = true,
    this.version = 0,
  });

  final String id;
  final String sku;
  final String name;
  final String unitId;
  final Money sellPrice;
  final String? categoryId;
  final Money? cost;
  final bool trackStock;
  final bool isActive;
  final int version;
}

final class Barcode {
  const Barcode({
    required this.id,
    required this.productId,
    required this.code,
    this.symbology = 'ean13',
  });
  final String id;
  final String productId;
  final String code;
  final String symbology;
}

/// Raises [ConflictError] `PRODUCT_DUPLICATE_SKU` when the sku is already used.
void assertUniqueSku({required String sku, required bool taken}) {
  if (taken) throw ConflictError('PRODUCT_DUPLICATE_SKU', {'sku': sku});
}

/// Raises [ConflictError] `BARCODE_DUPLICATE` when the barcode already resolves.
void assertUniqueBarcode({required String code, required bool taken}) {
  if (taken) throw ConflictError('BARCODE_DUPLICATE', {'barcode': code});
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

/// Parse a user-entered quantity into integer minor units for a unit with
/// [decimalPlaces]. Raises [ValidationError] `CATALOG_UNIT_PRECISION` when the
/// input has more decimals than the unit allows (e.g. 1.5 of a piece), or
/// `CATALOG_QTY_INVALID` when it is not a number.
int quantityToMinor(String input, int decimalPlaces) {
  final trimmed = input.trim();
  final negative = trimmed.startsWith('-');
  final body = negative ? trimmed.substring(1) : trimmed;
  final parts = body.split('.');
  if (parts.length > 2 || body.isEmpty) {
    throw ValidationError('CATALOG_QTY_INVALID', {'input': input});
  }
  final frac = parts.length == 2 ? parts[1] : '';
  if (frac.length > decimalPlaces) {
    throw ValidationError('CATALOG_UNIT_PRECISION', {'decimals': frac.length, 'allowed': decimalPlaces});
  }
  final whole = parts[0].isEmpty ? 0 : int.parse(parts[0]);
  final fracValue = frac.isEmpty ? 0 : int.parse(frac.padRight(decimalPlaces, '0'));
  final magnitude = whole * _pow10(decimalPlaces) + fracValue;
  return negative ? -magnitude : magnitude;
}

/// Render integer minor units as a decimal string for a unit's [decimalPlaces].
String formatQuantity(int minor, int decimalPlaces) {
  if (decimalPlaces == 0) return minor.toString();
  final negative = minor < 0;
  final magnitude = minor.abs();
  final unit = _pow10(decimalPlaces);
  final whole = magnitude ~/ unit;
  final frac = (magnitude % unit).toString().padLeft(decimalPlaces, '0');
  return '${negative ? '-' : ''}$whole.$frac';
}
