import 'dart:math';
import 'dart:typed_data';

/// Identifier generation. UUIDv7: time-ordered, safe across offline installs.
///
/// Generated in the application/shared layer — **never by the database** — so an
/// offline device can create a record with no server present and sync it later
/// without renumbering. Time-ordered so a B-tree index does not fragment.
final Random _rng = Random.secure();

/// A UUIDv7 as a 36-character lowercase string.
String newId() {
  final ms = DateTime.now().toUtc().millisecondsSinceEpoch; // 48-bit unix ms
  final b = Uint8List(16);
  b[0] = (ms >> 40) & 0xff;
  b[1] = (ms >> 32) & 0xff;
  b[2] = (ms >> 24) & 0xff;
  b[3] = (ms >> 16) & 0xff;
  b[4] = (ms >> 8) & 0xff;
  b[5] = ms & 0xff;
  for (var i = 6; i < 16; i++) {
    b[i] = _rng.nextInt(256);
  }
  b[6] = (b[6] & 0x0f) | 0x70; // version 7
  b[8] = (b[8] & 0x3f) | 0x80; // variant 10xx
  return _hex(b);
}

String _hex(Uint8List b) {
  final s = StringBuffer();
  for (var i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) s.write('-');
    s.write(b[i].toRadixString(16).padLeft(2, '0'));
  }
  return s.toString();
}
