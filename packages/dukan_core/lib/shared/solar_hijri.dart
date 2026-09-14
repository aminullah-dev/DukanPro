/// A date in the Solar Hijri (Hijri Shamsi) calendar: Afghanistan's civil
/// calendar (months Hamal to Hut) and Iran's. Pure arithmetic after the jalaali
/// algorithm (Borkowski's leap-year breaks), exact for the years -61 to 3177 SH.
/// Store Gregorian UTC; this is for display only (docs/localization.md).
final class SolarHijriDate {
  const SolarHijriDate(this.year, this.month, this.day);

  factory SolarHijriDate.fromGregorian(DateTime date) =>
      _fromDayNumber(_gregorianToDayNumber(date.year, date.month, date.day));

  final int year;
  final int month; // 1 = Hamal (Farvardin) … 12 = Hut (Esfand)
  final int day;

  /// The Gregorian date (UTC midnight) of this day.
  DateTime toGregorian() {
    final start = _yearStart(year);
    final dayNumber = _gregorianToDayNumber(start.gy, 3, start.march) +
        (month - 1) * 31 - _div(month, 7) * (month - 7) + day - 1;
    return _dayNumberToGregorian(dayNumber);
  }

  /// Hut has 30 days in a leap year, 29 otherwise.
  static bool isLeapYear(int year) => _yearStart(year).leap == 0;

  static int monthLength(int year, int month) =>
      month <= 6 ? 31 : (month <= 11 ? 30 : (isLeapYear(year) ? 30 : 29));

  @override
  bool operator ==(Object other) =>
      other is SolarHijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-${_two(month)}-${_two(day)}';
}

String _two(int n) => n.toString().padLeft(2, '0');

// The years where the 33-year leap cycle is interrupted.
const _breaks = [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394,
  2456, 3178];

// Truncating division and remainder, as the algorithm is written (Dart's % is
// Euclidean and differs for negative numbers).
int _div(int a, int b) => a ~/ b;
int _mod(int a, int b) => a.remainder(b);

/// For Solar Hijri [year]: the Gregorian year it starts in, the March day of
/// 1 Hamal, and the years since the last leap year (0 means a leap year).
({int gy, int march, int leap}) _yearStart(int year) {
  if (year < _breaks.first || year >= _breaks.last) {
    throw ArgumentError.value(year, 'year', 'outside the Solar Hijri years this calendar covers');
  }
  final gy = year + 621;
  var leapJ = -14;
  var jp = _breaks.first;
  var jump = 0;
  for (var i = 1; i < _breaks.length; i++) {
    final jm = _breaks[i];
    jump = jm - jp;
    if (year < jm) break;
    leapJ += _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
    jp = jm;
  }
  var n = year - jp;
  leapJ += _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
  if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
  final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
  final march = 20 + leapJ - leapG;
  if (jump - n < 6) n = n - jump + _div(jump + 4, 33) * 33;
  var leap = _mod(_mod(n + 1, 33) - 1, 4);
  if (leap == -1) leap = 4;
  return (gy: gy, march: march, leap: leap);
}

SolarHijriDate _fromDayNumber(int dayNumber) {
  final gy = _dayNumberToGregorian(dayNumber).year;
  var year = gy - 621;
  final start = _yearStart(year);
  var k = dayNumber - _gregorianToDayNumber(gy, 3, start.march);
  if (k >= 0) {
    if (k <= 185) return SolarHijriDate(year, 1 + _div(k, 31), _mod(k, 31) + 1);
    k -= 186;
  } else {
    year -= 1;
    k += 179;
    if (start.leap == 1) k += 1;
  }
  return SolarHijriDate(year, 7 + _div(k, 30), _mod(k, 30) + 1);
}

/// The Julian day number of a Gregorian date.
int _gregorianToDayNumber(int gy, int gm, int gd) {
  var d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) + _div(153 * _mod(gm + 9, 12) + 2, 5) + gd - 34840408;
  d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
  return d;
}

DateTime _dayNumberToGregorian(int dayNumber) {
  var j = 4 * dayNumber + 139361631;
  j = j + _div(_div(4 * dayNumber + 183187720, 146097) * 3, 4) * 4 - 3908;
  final i = _div(_mod(j, 1461), 4) * 5 + 308;
  final gd = _div(_mod(i, 153), 5) + 1;
  final gm = _mod(_div(i, 153), 12) + 1;
  final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
  return DateTime.utc(gy, gm, gd);
}
