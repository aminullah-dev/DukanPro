import 'dart:typed_data';

/// A receipt drawn as a picture: one bit per printer dot, each row packed eight
/// dots to a byte with the leftmost dot in the high bit, 1 for black.
///
/// This is how Dari and Pashto reach a thermal printer. ESC/POS text mode has
/// no Persian glyphs, but every ESC/POS printer prints a raster image (GS v 0).
final class RasterImage {
  RasterImage({required this.width, required this.height, required this.bits}) {
    if (width <= 0 || width % 8 != 0) throw ArgumentError.value(width, 'width', 'must be a positive multiple of 8');
    if (height <= 0) throw ArgumentError.value(height, 'height', 'must be positive');
    if (bits.length != width ~/ 8 * height) throw ArgumentError('bits must hold width / 8 × height bytes');
  }

  /// Thresholds an RGBA picture (four bytes a pixel, row by row) to black and
  /// white. A transparent pixel is paper.
  factory RasterImage.fromRgba(Uint8List rgba, {required int width, required int height, int threshold = 160}) {
    if (width <= 0 || width % 8 != 0) throw ArgumentError.value(width, 'width', 'must be a positive multiple of 8');
    if (height <= 0 || rgba.length != width * height * 4) {
      throw ArgumentError('rgba must hold width × height pixels');
    }
    final perRow = width ~/ 8;
    final bits = Uint8List(perRow * height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final i = (y * width + x) * 4;
        final luma = (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
        // Composite over white paper: the less opaque, the lighter.
        final onPaper = 255 - (255 - luma) * rgba[i + 3] ~/ 255;
        if (onPaper < threshold) bits[y * perRow + (x >> 3)] |= 0x80 >> (x & 7);
      }
    }
    return RasterImage(width: width, height: height, bits: bits);
  }

  /// Dots across: [paperDots] of the paper it is drawn for.
  final int width;
  final int height;
  final Uint8List bits;

  int get bytesPerRow => width ~/ 8;

  bool isBlack(int x, int y) => bits[y * bytesPerRow + (x >> 3)] & (0x80 >> (x & 7)) != 0;
}

/// Printable dots across a thermal roll at 203 dpi: 384 on 58 mm paper, 576 on
/// 80 mm.
int paperDots(int paperMm) => switch (paperMm) {
      58 => 384,
      80 => 576,
      _ => throw ArgumentError.value(paperMm, 'paperMm', 'is 58 or 80'),
    };
