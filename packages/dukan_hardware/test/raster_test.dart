// Receipts reach the printer as a picture (GS v 0), so Dari and Pashto print.
import 'dart:typed_data';

import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:test/test.dart';

Uint8List _rgba(int width, int height, bool Function(int x, int y) black, {int alpha = 255}) {
  final out = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      final v = black(x, y) ? 0 : 255;
      out[i] = v;
      out[i + 1] = v;
      out[i + 2] = v;
      out[i + 3] = alpha;
    }
  }
  return out;
}

void main() {
  test('dots pack eight to a byte, leftmost in the high bit', () {
    final image = RasterImage.fromRgba(_rgba(16, 2, (x, y) => x == 0 || (y == 1 && x == 9)), width: 16, height: 2);
    expect(image.bits, [0x80, 0x00, 0x80, 0x40]);
    expect(image.isBlack(0, 0), isTrue);
    expect(image.isBlack(9, 1), isTrue);
    expect(image.isBlack(1, 0), isFalse);
  });

  test('a transparent pixel is paper, whatever its colour', () {
    final image = RasterImage.fromRgba(_rgba(8, 1, (x, y) => true, alpha: 0), width: 8, height: 1);
    expect(image.bits, [0x00]);
  });

  test('a width that is not whole bytes, or pixels that do not fit it, are refused', () {
    expect(() => RasterImage.fromRgba(_rgba(10, 1, (x, y) => false), width: 10, height: 1), throwsArgumentError);
    expect(() => RasterImage.fromRgba(Uint8List(8 * 4), width: 8, height: 2), throwsArgumentError);
  });

  test('paper widths are 384 dots on 58 mm and 576 on 80 mm', () {
    expect(paperDots(58), 384);
    expect(paperDots(80), 576);
    expect(() => paperDots(76), throwsArgumentError);
  });

  test('a tall receipt goes in bands of at most 256 rows, then feeds and cuts', () {
    final image = RasterImage(width: 16, height: 300, bits: Uint8List(2 * 300));
    final bytes = const EscPosEncoder().encodeRaster(image);
    expect(bytes.sublist(0, 2), [0x1B, 0x40]); // ESC @
    expect(bytes.sublist(2, 10), [0x1D, 0x76, 0x30, 0x00, 2, 0, 0, 1]); // 2 bytes a row, 256 rows
    final second = 10 + 2 * 256;
    expect(bytes.sublist(second, second + 8), [0x1D, 0x76, 0x30, 0x00, 2, 0, 44, 0]); // the last 44 rows
    expect(bytes.length, 2 + 8 + 512 + 8 + 88 + 3 + 3);
    expect(bytes.sublist(bytes.length - 3), [0x1D, 0x56, 0x00]); // full cut
  });
}
