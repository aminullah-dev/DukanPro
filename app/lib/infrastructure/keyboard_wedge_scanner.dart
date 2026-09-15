import 'dart:async';

import 'package:dukan_core/dukan_core.dart' show normalizeDigits;
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
      final code = normalizeDigits(_buf.toString()); // Persian digits from a Dari layout
      _buf.clear();
      return code.isEmpty ? null : code;
    }
    _buf.write(ch);
    return null;
  }
}

/// The character a scanner meant by a key press. HID scanners send key
/// positions and the active keyboard layout turns them into characters: under a
/// Dari or Pashto layout the digit row types Persian digits and the letter keys
/// Arabic letters. So digits and letters are read from the physical key, and
/// any other key as typed.
String scanCharFor(PhysicalKeyboardKey key, String? typed, {required bool shift}) {
  if (typed != null && typed.isNotEmpty && typed.codeUnitAt(0) < 0x80) return typed; // a Latin layout
  final digit = _digitKeys.indexOf(key);
  if (digit >= 0) return shift ? _shiftedDigits[digit] : '$digit';
  final numpad = _numpadKeys.indexOf(key);
  if (numpad >= 0) return '$numpad';
  final letter = _letterKeys.indexOf(key);
  if (letter >= 0) {
    final c = String.fromCharCode(0x61 + letter);
    return shift ? c.toUpperCase() : c;
  }
  final symbol = _usSymbols[key];
  if (symbol != null) return shift ? symbol.$2 : symbol.$1;
  return typed ?? '';
}

// What a scanner set up for a US keyboard means by the digit row with Shift and
// by the punctuation keys (without, with Shift).
const _shiftedDigits = [')', '!', '@', '#', r'$', '%', '^', '&', '*', '('];
final _usSymbols = <PhysicalKeyboardKey, (String, String)>{
  PhysicalKeyboardKey.minus: ('-', '_'),
  PhysicalKeyboardKey.equal: ('=', '+'),
  PhysicalKeyboardKey.bracketLeft: ('[', '{'),
  PhysicalKeyboardKey.bracketRight: (']', '}'),
  PhysicalKeyboardKey.backslash: (r'\', '|'),
  PhysicalKeyboardKey.semicolon: (';', ':'),
  PhysicalKeyboardKey.quote: ("'", '"'),
  PhysicalKeyboardKey.backquote: ('`', '~'),
  PhysicalKeyboardKey.comma: (',', '<'),
  PhysicalKeyboardKey.period: ('.', '>'),
  PhysicalKeyboardKey.slash: ('/', '?'),
  PhysicalKeyboardKey.space: (' ', ' '),
  PhysicalKeyboardKey.numpadDecimal: ('.', '.'),
  PhysicalKeyboardKey.numpadSubtract: ('-', '-'),
  PhysicalKeyboardKey.numpadAdd: ('+', '+'),
  PhysicalKeyboardKey.numpadMultiply: ('*', '*'),
  PhysicalKeyboardKey.numpadDivide: ('/', '/'),
};

const _digitKeys = [PhysicalKeyboardKey.digit0, PhysicalKeyboardKey.digit1, PhysicalKeyboardKey.digit2, PhysicalKeyboardKey.digit3, PhysicalKeyboardKey.digit4, PhysicalKeyboardKey.digit5, PhysicalKeyboardKey.digit6, PhysicalKeyboardKey.digit7, PhysicalKeyboardKey.digit8, PhysicalKeyboardKey.digit9];
const _numpadKeys = [PhysicalKeyboardKey.numpad0, PhysicalKeyboardKey.numpad1, PhysicalKeyboardKey.numpad2, PhysicalKeyboardKey.numpad3, PhysicalKeyboardKey.numpad4, PhysicalKeyboardKey.numpad5, PhysicalKeyboardKey.numpad6, PhysicalKeyboardKey.numpad7, PhysicalKeyboardKey.numpad8, PhysicalKeyboardKey.numpad9];
const _letterKeys = [PhysicalKeyboardKey.keyA, PhysicalKeyboardKey.keyB, PhysicalKeyboardKey.keyC, PhysicalKeyboardKey.keyD, PhysicalKeyboardKey.keyE, PhysicalKeyboardKey.keyF, PhysicalKeyboardKey.keyG, PhysicalKeyboardKey.keyH, PhysicalKeyboardKey.keyI, PhysicalKeyboardKey.keyJ, PhysicalKeyboardKey.keyK, PhysicalKeyboardKey.keyL, PhysicalKeyboardKey.keyM, PhysicalKeyboardKey.keyN, PhysicalKeyboardKey.keyO, PhysicalKeyboardKey.keyP, PhysicalKeyboardKey.keyQ, PhysicalKeyboardKey.keyR, PhysicalKeyboardKey.keyS, PhysicalKeyboardKey.keyT, PhysicalKeyboardKey.keyU, PhysicalKeyboardKey.keyV, PhysicalKeyboardKey.keyW, PhysicalKeyboardKey.keyX, PhysicalKeyboardKey.keyY, PhysicalKeyboardKey.keyZ];

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
    final ch = isEnter
        ? '\n'
        : scanCharFor(event.physicalKey, event.character, shift: HardwareKeyboard.instance.isShiftPressed);
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
