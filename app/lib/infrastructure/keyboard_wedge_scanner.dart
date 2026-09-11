import 'dart:async';

import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/services.dart';

/// Decodes a keyboard-wedge (HID) barcode scanner's keystrokes. Such scanners
/// type the code very fast and end with Enter; a human types slowly. Pure and
/// clock-injectable so the burst-vs-human logic is unit-testable.
class WedgeDecoder {
  WedgeDecoder({this.maxGap = const Duration(milliseconds: 50)});

  /// Keys arriving more than [maxGap] apart are treated as human typing and
  /// reset the buffer (so manual typing never looks like a scan).
  final Duration maxGap;

  final StringBuffer _buf = StringBuffer();
  DateTime? _last;

  /// Feeds one character. Returns the decoded code on Enter, else null.
  String? feed(String ch, DateTime now) {
    if (_last != null && now.difference(_last!) > maxGap) _buf.clear();
    _last = now;
    if (ch == '\n' || ch == '\r') {
      final code = _buf.toString();
      _buf.clear();
      return code.isEmpty ? null : code;
    }
    _buf.write(ch);
    return null;
  }
}

/// Guesses a symbology from the code shape (enough for receipt/catalog lookup).
String guessSymbology(String code) {
  final digits = RegExp(r'^\d+$').hasMatch(code);
  if (digits && code.length == 13) return 'ean13';
  if (digits && code.length == 8) return 'ean8';
  if (digits && code.length == 12) return 'upca';
  return 'code128';
}

/// A [BarcodeScanner] over the hardware keyboard: wires a global key handler to
/// a [WedgeDecoder] and emits a [ScanEvent] per decoded burst. Non-consuming
/// (returns false) so it never steals keys from focused text fields.
class KeyboardWedgeScanner implements BarcodeScanner {
  KeyboardWedgeScanner({WedgeDecoder? decoder, DateTime Function()? now})
      : _decoder = decoder ?? WedgeDecoder(),
        _now = now ?? DateTime.now {
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  final WedgeDecoder _decoder;
  final DateTime Function() _now;
  final StreamController<ScanEvent> _controller = StreamController<ScanEvent>.broadcast();

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    final ch = isEnter ? '\n' : (event.character ?? '');
    if (ch.isEmpty) return false;
    final code = _decoder.feed(ch, _now());
    if (code != null) _controller.add(ScanEvent(code, guessSymbology(code)));
    return false; // don't consume — text fields still receive the keys
  }

  @override
  Stream<ScanEvent> scans() => _controller.stream;

  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _controller.close();
  }
}
