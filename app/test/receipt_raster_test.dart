// Receipts print as a picture, so Dari and Pashto reach the paper; the picture
// fits the roll, reads right to left in Dari, and says when a sale was voided.
import 'dart:convert';
import 'dart:io' show ZLibDecoder;

import 'package:dukan_core/dukan_core.dart' show defaultBranchZone;
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:dukanpro/features/pos/receipt_raster.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _receipt = ReceiptData(
  shopName: 'دکان احمد',
  number: 'D1-INV-2026-00017',
  stamp: '',
  lines: [
    ReceiptLineData(name: 'صابون', qtyLabel: '×2', lineTotalMinor: 10000),
    ReceiptLineData(name: 'برنج باسمتی، نامی که آن‌قدر دراز است که به سطر دوم می‌رود', qtyLabel: '×1.5', lineTotalMinor: 225000),
  ],
  subtotalMinor: 235000,
  totalMinor: 230000,
  paidMinor: 230000,
  changeMinor: 20000,
);

// Three long names: the side a line starts on outweighs the totals' figures.
const _longNames = ReceiptData(
  shopName: 'DukanPro',
  number: 'D1-INV-2026-00018',
  stamp: '',
  lines: [
    ReceiptLineData(name: 'a product name long enough to wrap onto a second line', qtyLabel: '×1', lineTotalMinor: 100),
    ReceiptLineData(name: 'another product name long enough to wrap onto a second', qtyLabel: '×1', lineTotalMinor: 100),
    ReceiptLineData(name: 'a third product name long enough to wrap onto a second', qtyLabel: '×1', lineTotalMinor: 100),
  ],
  subtotalMinor: 300,
  totalMinor: 300,
  paidMinor: 300,
  changeMinor: 0,
);

Future<RasterImage> _draw(WidgetTester tester, String locale,
    {int paperMm = 80, bool voided = false, ReceiptData data = _receipt}) async {
  final l = await AppLocalizations.delegate.load(Locale(locale));
  return (await tester.runAsync(() => rasterReceipt(
        l: l, data: data, occurredAt: DateTime.utc(2026, 9, 11, 10), zone: defaultBranchZone,
        paperMm: paperMm, voided: voided,
      )))!;
}

/// Black dots in the left and right halves of the paper.
(int, int) _halves(RasterImage image) {
  var left = 0, right = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (!image.isBlack(x, y)) continue;
      if (x < image.width ~/ 2) {
        left++;
      } else {
        right++;
      }
    }
  }
  return (left, right);
}

void main() {
  testWidgets('the receipt is drawn across the whole roll: 576 dots on 80 mm, 384 on 58 mm', (tester) async {
    final wide = await _draw(tester, 'fa');
    final narrow = await _draw(tester, 'fa', paperMm: 58);
    expect(wide.width, 576);
    expect(narrow.width, 384);
    final (left, right) = _halves(wide);
    expect(left + right, greaterThan(2000));
  });

  testWidgets('in Dari the labels sit on the right, in English on the left', (tester) async {
    final (faLeft, faRight) = _halves(await _draw(tester, 'fa', data: _longNames));
    final (enLeft, enRight) = _halves(await _draw(tester, 'en', data: _longNames));
    expect(faRight, greaterThan(faLeft));
    expect(enLeft, greaterThan(enRight));
  });

  testWidgets('a voided sale says so on paper', (tester) async {
    final settled = await _draw(tester, 'ps');
    final voided = await _draw(tester, 'ps', voided: true);
    expect(voided.height, greaterThan(settled.height));
  });

  testWidgets('what goes to the printer is the picture in bands, then a cut', (tester) async {
    final image = await _draw(tester, 'fa', paperMm: 58);
    final bytes = const EscPosEncoder().encodeRaster(image);
    final bands = (image.height + 255) ~/ 256;
    expect(bytes.length, 2 + bands * 8 + image.bits.length + 3 + 3);
    expect(bytes.sublist(2, 6), [0x1D, 0x76, 0x30, 0x00]);
    expect(bytes.sublist(6, 8), [48, 0]); // 384 dots = 48 bytes a row
  });

  testWidgets('a receipt sent as a PDF is the printed picture, at the paper\'s size and three times as sharp', (tester) async {
    final l = await AppLocalizations.delegate.load(const Locale('fa'));
    final printed = await _draw(tester, 'fa');
    final pdf = (await tester.runAsync(() => receiptPdf(
          l: l, data: _receipt, occurredAt: DateTime.utc(2026, 9, 11, 10), zone: defaultBranchZone, paperMm: 80,
        )))!;
    final text = latin1.decode(pdf);
    expect(text, startsWith('%PDF-1.4'));
    // 576 dots at 203 dpi is 204.3 points across.
    expect(text, contains('/MediaBox [0 0 204.30 ${(printed.height * 72 / 203).toStringAsFixed(2)}]'));
    expect(text, contains('/Width ${576 * 3} /Height ${printed.height * 3} '));

    final header = RegExp(r'/Length (\d+) >>\nstream\n').firstMatch(text)!;
    final rgb = ZLibDecoder().convert(pdf.sublist(header.end, header.end + int.parse(header.group(1)!)));
    expect(rgb, hasLength(576 * 3 * printed.height * 3 * 3));
    var dark = 0;
    for (var i = 0; i < rgb.length; i += 3) {
      if (rgb[i] < 128) dark++;
    }
    expect(dark, greaterThan(2000 * 9), reason: 'the words are there, drawn nine times the dots');
  });
}
