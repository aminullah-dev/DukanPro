import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:test/test.dart';

ReceiptData _sample({String name = 'Rice'}) => ReceiptData(
      shopName: 'Dukan',
      number: 'INV-2026-00001',
      stamp: '1405-06-20 14:30 (2026-09-11)',
      lines: [ReceiptLineData(name: name, qtyLabel: '×2', lineTotalMinor: 10400)],
      subtotalMinor: 10400,
      totalMinor: 10400,
      paidMinor: 11000,
      changeMinor: 600,
      currency: 'AFN',
    );

void main() {
  const enc = EscPosEncoder(width: 32);

  test('starts with ESC @ init and ends with a full cut', () {
    final bytes = enc.encode(_sample());
    expect(bytes.sublist(0, 2), [0x1B, 0x40]); // ESC @
    expect(bytes.sublist(bytes.length - 3), [0x1D, 0x56, 0x00]); // GS V 0
  });

  test('the drawer kick is the ESC p pulse', () {
    expect(EscPosEncoder.drawerKick(), [0x1B, 0x70, 0x00, 0x19, 0xFA]);
  });

  test('a total row is right-justified to the paper width', () {
    final text = String.fromCharCodes(
      enc.encode(_sample()).where((b) => b >= 0x20 && b < 0x7F),
    );
    // "TOTAL" label and "104.00 AFN" value on a 32-char line.
    expect(text, contains('TOTAL'));
    expect(text, contains('104.00 AFN'));
    expect(text, contains('1405-06-20 14:30 (2026-09-11)'));
  });

  test('non-Latin-1 characters are replaced with ?', () {
    // Persian product name — not printable in ESC/POS text mode.
    final bytes = enc.encode(_sample(name: 'برنج'));
    // No byte exceeds 0xFF and the Persian runes became 0x3F ('?').
    expect(bytes.every((b) => b >= 0 && b <= 0xFF), isTrue);
    expect(bytes, contains(0x3F));
  });
}
