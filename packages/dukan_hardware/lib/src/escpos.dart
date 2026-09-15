import 'package:dukan_core/dukan_core.dart' show formatQuantity;

import 'receipt.dart';

/// Encodes a [ReceiptData] into ESC/POS printer bytes (text mode). Pure and
/// deterministic so it is unit-testable without a printer.
///
/// Text mode covers ASCII/numerics (totals, invoice number, date) reliably.
/// Non-Latin-1 runes (e.g. Persian/Pashto product names) are replaced with `?`
/// — full Persian glyphs require raster/image mode, which is a later phase.
final class EscPosEncoder {
  const EscPosEncoder({this.width = 48});

  /// Characters per line: 32 for 58mm paper, 48 for 80mm.
  final int width;

  // ── ESC/POS command bytes ────────────────────────────────────────────────
  static const _esc = 0x1B;
  static const _gs = 0x1D;
  static const _lf = 0x0A;

  List<int> encode(ReceiptData r) {
    final out = <int>[];
    out.addAll(const [_esc, 0x40]); // ESC @ — initialise
    _align(out, 1); // centre
    _bold(out, true);
    _line(out, r.shopName);
    _bold(out, false);
    _line(out, r.number);
    _line(out, r.stamp);
    _align(out, 0); // left
    _rule(out);
    for (final l in r.lines) {
      _row(out, '${l.name} ${l.qtyLabel}', _money(l.lineTotalMinor));
    }
    _rule(out);
    _row(out, 'TOTAL', '${_money(r.totalMinor)} ${r.currency}', bold: true);
    _row(out, 'PAID', _money(r.paidMinor));
    _row(out, 'CHANGE', _money(r.changeMinor));
    if (r.footer != null && r.footer!.isNotEmpty) {
      _align(out, 1);
      _feed(out, 1);
      _line(out, r.footer!);
    }
    _feed(out, 3);
    out.addAll(const [_gs, 0x56, 0x00]); // GS V 0 — full cut
    return out;
  }

  /// The cash-drawer kick pulse (ESC p m t1 t2) — sent out-of-band on cash sales.
  static List<int> drawerKick() => const [_esc, 0x70, 0x00, 0x19, 0xFA];

  // ── helpers ───────────────────────────────────────────────────────────────
  void _align(List<int> out, int n) => out.addAll([_esc, 0x61, n]); // ESC a n
  void _bold(List<int> out, bool on) => out.addAll([_esc, 0x45, on ? 1 : 0]); // ESC E n
  void _feed(List<int> out, int n) => out.addAll([_esc, 0x64, n]); // ESC d n

  void _line(List<int> out, String text) {
    out.addAll(_encodeText(text));
    out.add(_lf);
  }

  void _rule(List<int> out) => _line(out, '-' * width);

  /// A left label and right-justified value on one [width]-wide line.
  void _row(List<int> out, String left, String right, {bool bold = false}) {
    final maxLeft = width - right.length - 1;
    var l = left;
    if (maxLeft < 1) {
      l = '';
    } else if (l.length > maxLeft) {
      l = l.substring(0, maxLeft);
    }
    final gap = width - l.length - right.length;
    final row = '$l${' ' * (gap < 1 ? 1 : gap)}$right';
    if (bold) _bold(out, true);
    _line(out, row);
    if (bold) _bold(out, false);
  }

  String _money(int minor) => formatQuantity(minor, 2); // integers, never a float


  /// Latin-1 text path: runes above 0xFF become `?` (see class doc).
  List<int> _encodeText(String text) =>
      text.runes.map((r) => r <= 0xFF ? r : 0x3F).toList();
}
