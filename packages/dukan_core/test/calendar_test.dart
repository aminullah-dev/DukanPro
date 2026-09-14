import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

void main() {
  group('Solar Hijri', () {
    // (Gregorian, Solar Hijri) pairs, leap days included.
    const known = [
      ((2026, 3, 21), (1405, 1, 1)),
      ((2026, 3, 20), (1404, 12, 29)),
      ((2025, 3, 20), (1403, 12, 30)), // 1403 is a leap year
      ((2025, 3, 21), (1404, 1, 1)),
      ((2024, 3, 20), (1403, 1, 1)),
      ((2021, 3, 20), (1399, 12, 30)), // 1399 is a leap year
      ((2021, 3, 21), (1400, 1, 1)),
      ((2017, 3, 20), (1395, 12, 30)), // 1395 is a leap year
      ((2025, 9, 23), (1404, 7, 1)), // the first 30-day month
      ((2026, 9, 11), (1405, 6, 20)),
      ((2000, 1, 1), (1378, 10, 11)),
      ((1979, 2, 11), (1357, 11, 22)),
    ];

    test('converts known dates both ways', () {
      for (final (g, h) in known) {
        final gregorian = DateTime.utc(g.$1, g.$2, g.$3);
        final hijri = SolarHijriDate(h.$1, h.$2, h.$3);
        expect(SolarHijriDate.fromGregorian(gregorian), hijri, reason: '$gregorian');
        expect(hijri.toGregorian(), gregorian, reason: '$hijri');
      }
    });

    test('knows the leap years and the length of Hut', () {
      for (final y in [1395, 1399, 1403, 1408]) {
        expect(SolarHijriDate.isLeapYear(y), isTrue, reason: '$y');
      }
      for (final y in [1400, 1402, 1404, 1405]) {
        expect(SolarHijriDate.isLeapYear(y), isFalse, reason: '$y');
      }
      expect(SolarHijriDate.monthLength(1403, 12), 30);
      expect(SolarHijriDate.monthLength(1404, 12), 29);
      expect(SolarHijriDate.monthLength(1404, 6), 31);
      expect(SolarHijriDate.monthLength(1404, 7), 30);
    });

    test('every day from 1390 to 1420 follows the one before and converts back', () {
      var day = DateTime.utc(2011, 3, 21);
      var previous = SolarHijriDate.fromGregorian(day);
      expect(previous, const SolarHijriDate(1390, 1, 1));
      while (day.isBefore(DateTime.utc(2042, 3, 21))) {
        day = day.add(const Duration(days: 1));
        final next = SolarHijriDate.fromGregorian(day);
        final expected = previous.day < SolarHijriDate.monthLength(previous.year, previous.month)
            ? SolarHijriDate(previous.year, previous.month, previous.day + 1)
            : previous.month < 12
                ? SolarHijriDate(previous.year, previous.month + 1, 1)
                : SolarHijriDate(previous.year + 1, 1, 1);
        expect(next, expected, reason: '$day');
        expect(next.toGregorian(), day);
        previous = next;
      }
    });
  });

  group('business day', () {
    test('a Kabul day runs from 19:30 UTC to 19:30 UTC the next day', () {
      // 01:00 on 12 September in Kabul is still 11 September in UTC.
      final day = businessDay('Asia/Kabul', DateTime.utc(2026, 9, 11, 20, 30));
      expect(day.start, DateTime.utc(2026, 9, 11, 19, 30));
      expect(day.end, DateTime.utc(2026, 9, 12, 19, 30));
      expect(businessDay('Asia/Kabul', DateTime.utc(2026, 9, 11, 19, 29)).end, day.start);
      expect(businessDay('Asia/Kabul', DateTime.utc(2026, 9, 12, 19, 30)).start, day.end);
    });

    test('reads the branch wall clock; an unknown zone reads as Kabul', () {
      expect(branchWallClock('Asia/Kabul', DateTime.utc(2026, 9, 11, 10)), DateTime.utc(2026, 9, 11, 14, 30));
      expect(branchWallClock('UTC', DateTime.utc(2026, 9, 11, 10)), DateTime.utc(2026, 9, 11, 10));
      expect(branchWallClock('Europe/Nowhere', DateTime.utc(2026, 9, 11, 10)), DateTime.utc(2026, 9, 11, 14, 30));
      final local = DateTime(2026, 9, 11, 10); // a device clock in any zone
      expect(branchWallClock('Asia/Kabul', local), local.toUtc().add(const Duration(hours: 4, minutes: 30)));
    });

    test('a branch zone and currency are ones the shop supports', () {
      assertBranchSettingsValid(timezone: 'Asia/Kabul', currencyDefault: 'AFN');
      expect(() => assertBranchSettingsValid(timezone: 'Mars/Olympus', currencyDefault: 'AFN'),
          throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'BRANCH_TIMEZONE_INVALID')));
      expect(() => assertBranchSettingsValid(timezone: 'Asia/Kabul', currencyDefault: 'zz'),
          throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'BRANCH_CURRENCY_INVALID')));
    });
  });
}
