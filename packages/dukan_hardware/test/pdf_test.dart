import 'dart:convert';
import 'dart:io' show ZLibDecoder;
import 'dart:typed_data';

import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:test/test.dart';

void main() {
  // Two pixels: red, then blue.
  final rgb = Uint8List.fromList([255, 0, 0, 0, 0, 255]);
  final pdf = imagePdf(rgb: rgb, width: 2, height: 1, pageWidth: 226.77, pageHeight: 113.39);
  final text = latin1.decode(pdf);

  test('it is a PDF from its first byte to its last line', () {
    expect(text, startsWith('%PDF-1.4\n'));
    expect(text, endsWith('%%EOF\n'));
  });

  test('the cross-reference table points at every object', () {
    final xref = int.parse(RegExp(r'startxref\n(\d+)\n').firstMatch(text)!.group(1)!);
    expect(text.substring(xref), startsWith('xref\n0 6\n'));
    final entries = RegExp(r'(\d{10}) 00000 n \n').allMatches(text.substring(xref)).toList();
    expect(entries, hasLength(5));
    for (final (i, entry) in entries.indexed) {
      expect(text.substring(int.parse(entry.group(1)!)), startsWith('${i + 1} 0 obj\n'), reason: 'object ${i + 1}');
    }
    // Every entry is exactly 20 bytes, as the format requires.
    expect('0000000000 65535 f \n'.length, 20);
  });

  test('the page has the size asked for, and the picture fills it', () {
    expect(text, contains('/MediaBox [0 0 226.77 113.39]'));
    expect(text, contains('q 226.77 0 0 113.39 0 0 cm /Im0 Do Q'));
    expect(text, contains('/Width 2 /Height 1 /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode'));
  });

  test("the picture's pixels come back out unchanged, and its length is the stream's", () {
    final header = RegExp(r'/Length (\d+) >>\nstream\n').firstMatch(text)!;
    final length = int.parse(header.group(1)!);
    final stream = pdf.sublist(header.end, header.end + length);
    expect(latin1.decode(pdf.sublist(header.end + length, header.end + length + 10)), '\nendstream');
    expect(ZLibDecoder().convert(stream), rgb);
  });

  test('pixels that do not match the size are refused', () {
    expect(
      () => imagePdf(rgb: Uint8List(5), width: 2, height: 1, pageWidth: 10, pageHeight: 5),
      throwsArgumentError,
    );
  });
}
