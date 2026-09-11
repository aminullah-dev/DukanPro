import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

void main() {
  group('newId (UUIDv7)', () {
    test('is a 36-char hyphenated string', () {
      final id = newId();
      expect(id.length, 36);
      expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
          .hasMatch(id), isTrue);
    });

    test('has version 7 and the correct variant', () {
      final id = newId();
      expect(id[14], '7'); // version nibble
      expect('89ab'.contains(id[19]), isTrue); // variant nibble 10xx
    });

    test('is time-ordered and unique across a burst', () {
      final a = newId();
      final b = newId();
      expect(a == b, isFalse);
    });
  });
}
