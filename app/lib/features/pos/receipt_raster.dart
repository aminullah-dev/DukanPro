import 'dart:ui' as ui;

import 'package:dukan_core/dukan_core.dart' show branchWallClock;
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/painting.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/bidi.dart';
import '../../widgets/dates.dart';
import '../../widgets/money.dart';

/// A receipt as the printer draws it: in the reader's language and script,
/// right to left in Dari and Pashto, the Solar Hijri date with the Gregorian
/// one under it, amounts written as on screen. Thermal printers have no
/// Persian glyphs in text mode, so the whole receipt goes as one picture
/// ([RasterImage], printed with [EscPosEncoder.encodeRaster]).
Future<RasterImage> rasterReceipt({
  required AppLocalizations l,
  required ReceiptData data,
  required DateTime occurredAt,
  required String zone,
  required int paperMm,
  bool voided = false,
}) async {
  final width = paperDots(paperMm);
  final solar = l.localeName.startsWith('fa') || l.localeName.startsWith('ps');
  final direction = solar ? TextDirection.rtl : TextDirection.ltr;
  const margin = 8.0;
  final inner = width - 2 * margin;
  final size = paperMm >= 80 ? 24.0 : 20.0;
  final base = TextStyle(color: const Color(0xFF000000), fontSize: size, height: 1.3);
  final strong = base.copyWith(fontWeight: FontWeight.w700);

  String money(int minor) => formatMoney(l, minor, data.currency);
  final local = branchWallClock(zone, occurredAt);
  String two(int n) => n.toString().padLeft(2, '0');

  final rows = <_Row>[
    _Centered(data.shopName, strong.copyWith(fontSize: size * 1.3), direction, inner),
    _Centered(ltr(data.number), base, direction, inner),
    if (voided) _Centered(l.voided, strong, direction, inner),
    _Centered(formatDateTime(l, occurredAt, zone), base, direction, inner),
    // A paper that leaves the shop carries both calendars.
    if (solar) _Centered(ltr('${local.year}-${two(local.month)}-${two(local.day)}'), base, direction, inner),
    const _Rule(),
    for (final line in data.lines)
      _Pair('${line.name} ${ltr(line.qtyLabel)}', amountText(line.lineTotalMinor), base, direction, inner),
    const _Rule(),
    if (data.subtotalMinor != data.totalMinor) _Pair(l.subtotal, money(data.subtotalMinor), base, direction, inner),
    _Pair(l.total, money(data.totalMinor), strong, direction, inner),
    _Pair(l.paid, money(data.paidMinor + data.changeMinor), base, direction, inner),
    _Pair(l.change, money(data.changeMinor), base, direction, inner),
    if (data.footer case final footer? when footer.isNotEmpty) _Centered(footer, base, direction, inner),
  ];

  const gap = 4.0;
  final height = (margin * 2 + rows.fold<double>(0, (sum, r) => sum + r.height + gap)).ceil();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), Paint()..color = const Color(0xFFFFFFFF));
  var y = margin;
  for (final row in rows) {
    row.paint(canvas, Offset(margin, y), inner, direction);
    y += row.height + gap;
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  picture.dispose();
  return RasterImage.fromRgba(pixels!.buffer.asUint8List(), width: width, height: height);
}

sealed class _Row {
  const _Row();
  double get height;
  void paint(Canvas canvas, Offset topLeft, double width, TextDirection direction);
}

/// One line (or a wrapped paragraph) centred across the paper.
final class _Centered extends _Row {
  _Centered(String text, TextStyle style, TextDirection direction, double width)
      : _p = TextPainter(text: TextSpan(text: text, style: style), textDirection: direction, textAlign: TextAlign.center)
          ..layout(minWidth: width, maxWidth: width);
  final TextPainter _p;

  @override
  double get height => _p.height;

  @override
  void paint(Canvas canvas, Offset topLeft, double width, TextDirection direction) => _p.paint(canvas, topLeft);
}

/// A label at the line's start and a figure at its end: the start is the right
/// edge in Dari and Pashto. A long label wraps; the figure never does.
final class _Pair extends _Row {
  _Pair(String label, String value, TextStyle style, TextDirection direction, double width)
      : _value = TextPainter(text: TextSpan(text: value, style: style), textDirection: direction)..layout(),
        _label = TextPainter(text: TextSpan(text: label, style: style), textDirection: direction) {
    _label.layout(maxWidth: (width - _value.width - 12).clamp(width / 3, width));
  }
  final TextPainter _label;
  final TextPainter _value;

  @override
  double get height => _label.height > _value.height ? _label.height : _value.height;

  @override
  void paint(Canvas canvas, Offset topLeft, double width, TextDirection direction) {
    final rtl = direction == TextDirection.rtl;
    _label.paint(canvas, topLeft + Offset(rtl ? width - _label.width : 0, 0));
    _value.paint(canvas, topLeft + Offset(rtl ? 0 : width - _value.width, 0));
  }
}

/// A thin rule between the header, the lines and the totals.
final class _Rule extends _Row {
  const _Rule();

  @override
  double get height => 10;

  @override
  void paint(Canvas canvas, Offset topLeft, double width, TextDirection direction) => canvas.drawRect(
        Rect.fromLTWH(topLeft.dx, topLeft.dy + 4, width, 2),
        Paint()..color = const Color(0xFF000000),
      );
}
