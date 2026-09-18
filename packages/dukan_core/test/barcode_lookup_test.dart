import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

void main() {
  group('barcodeLookupCodes', () {
    test("a UPC-A's 12 digits also try the EAN-13 with a leading zero", () {
      expect(barcodeLookupCodes('036000291452'), ['036000291452', '0036000291452']);
    });

    test('an EAN-13 starting with zero also tries its UPC-A', () {
      expect(barcodeLookupCodes('0036000291452'), ['0036000291452', '036000291452']);
    });

    test('the code as read always comes first', () {
      expect(barcodeLookupCodes('036000291452').first, '036000291452');
      expect(barcodeLookupCodes('0036000291452').first, '0036000291452');
    });

    test('an EAN-13 not starting with zero has no twin', () {
      expect(barcodeLookupCodes('5901234123457'), ['5901234123457']);
    });

    test('other lengths and anything not all digits are looked up as they are', () {
      expect(barcodeLookupCodes('96385074'), ['96385074']); // EAN-8
      expect(barcodeLookupCodes('AB12'), ['AB12']); // Code 128
      expect(barcodeLookupCodes('03600029145X'), ['03600029145X']);
      expect(barcodeLookupCodes(''), ['']);
    });
  });
}
