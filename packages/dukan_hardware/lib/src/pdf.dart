import 'dart:convert';
import 'dart:io' show ZLibEncoder;
import 'dart:typed_data';

/// A one-page PDF holding a single picture that fills a page [pageWidth] by
/// [pageHeight] points (1/72 inch). A receipt is sent this way: drawn as a
/// picture, as the printer's copy is, it keeps Dari and Pashto exactly as the
/// screen shapes them, with no font to embed.
///
/// [rgb] holds `width * height * 3` bytes, row by row from the top.
Uint8List imagePdf({
  required Uint8List rgb,
  required int width,
  required int height,
  required double pageWidth,
  required double pageHeight,
}) {
  if (width <= 0 || height <= 0 || rgb.length != width * height * 3) {
    throw ArgumentError('rgb must hold width * height * 3 bytes');
  }
  final picture = ZLibEncoder(level: 9).convert(rgb);
  final w = pageWidth.toStringAsFixed(2);
  final h = pageHeight.toStringAsFixed(2);
  final drawing = latin1.encode('q $w 0 0 $h 0 0 cm /Im0 Do Q');

  final out = BytesBuilder(copy: false);
  final offsets = <int>[];
  void text(String s) => out.add(latin1.encode(s));
  void object(String dictionary, [List<int>? stream]) {
    offsets.add(out.length);
    text('${offsets.length} 0 obj\n$dictionary');
    if (stream != null) {
      text('\nstream\n');
      out.add(stream);
      text('\nendstream');
    }
    text('\nendobj\n');
  }

  text('%PDF-1.4\n');
  out.add(const [0x25, 0xE2, 0xE3, 0xCF, 0xD3, 0x0A]); // marks the file as binary
  object('<< /Type /Catalog /Pages 2 0 R >>');
  object('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
  object('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 $w $h] '
      '/Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>');
  object(
    '<< /Type /XObject /Subtype /Image /Width $width /Height $height /ColorSpace /DeviceRGB '
    '/BitsPerComponent 8 /Filter /FlateDecode /Length ${picture.length} >>',
    picture,
  );
  object('<< /Length ${drawing.length} >>', drawing);

  final xref = out.length;
  text('xref\n0 ${offsets.length + 1}\n0000000000 65535 f \n');
  for (final offset in offsets) {
    text('${offset.toString().padLeft(10, '0')} 00000 n \n');
  }
  text('trailer\n<< /Size ${offsets.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n');
  return out.takeBytes();
}
