import '../shared/errors.dart';
import '../shared/money.dart';
import 'numbers.dart';

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

/// The codes a scanned barcode may be stored under, in the order to try them.
///
/// A UPC-A is the same product as the EAN-13 written with a zero in front, and
/// readers disagree about which they report: Android's ML Kit gives the 12
/// digits, Apple's Vision the 13, and a keyboard-wedge scanner whichever it was
/// set up to send. The code as read comes first, then its twin.
List<String> barcodeLookupCodes(String code) {
  if (!RegExp(r'^[0-9]+$').hasMatch(code)) return [code];
  if (code.length == 12) return [code, '0$code'];
  if (code.length == 13 && code.startsWith('0')) return [code, code.substring(1)];
  return [code];
}

int _pow10(int n) {
  var r = 1;
  for (var i = 0; i < n; i++) {
    r *= 10;
  }
  return r;
}

/// Parse a user-entered quantity (Persian or Latin digits) into integer minor
/// units for a unit with [decimalPlaces]. Raises [ValidationError]
/// `CATALOG_UNIT_PRECISION` when the input has more decimals than the unit
/// allows (e.g. 1.5 of a piece), or `CATALOG_QTY_INVALID` when it is not a
/// number (or too large).
int quantityToMinor(String input, int decimalPlaces) {
  final parsed = parseScaled(input, decimalPlaces);
  if (parsed.problem == NumberProblem.tooPrecise) {
    throw ValidationError('CATALOG_UNIT_PRECISION', {'allowed': decimalPlaces});
  }
  return parsed.value ?? (throw ValidationError('CATALOG_QTY_INVALID', {'input': input}));
}

/// A selling price is zero or more: a free item is fine, a negative price would
/// pay the customer. Raises [ValidationError] `CATALOG_PRICE_INVALID`.
void assertPriceValid({required int sellPriceMinor}) {
  if (sellPriceMinor < 0 || sellPriceMinor > moneyMax) {
    throw ValidationError('CATALOG_PRICE_INVALID', {'price': sellPriceMinor});
  }
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

/// The units every shop starts with. Their ids are the same on every device and
/// on the server (server/dukan/domain/catalog.py BUILTIN_UNITS), so seeding them
/// again never makes a second "kg".
const builtInUnits = <Unit>[
  Unit(id: '00000000-0000-7000-8000-000000000001', name: 'piece', decimalPlaces: 0),
  Unit(id: '00000000-0000-7000-8000-000000000002', name: 'kg', decimalPlaces: 3),
  Unit(id: '00000000-0000-7000-8000-000000000003', name: 'litre', decimalPlaces: 3),
  Unit(id: '00000000-0000-7000-8000-000000000004', name: 'dozen', decimalPlaces: 0),
  Unit(id: '00000000-0000-7000-8000-000000000005', name: 'meter', decimalPlaces: 2),
];
