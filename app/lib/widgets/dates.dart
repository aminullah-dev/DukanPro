import 'package:dukan_core/dukan_core.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

// Dates and times people read: on the branch's wall clock (its zone, never the
// device's), in the Solar Hijri calendar with the locale's digits in Dari and
// Pashto, Gregorian in English (docs/localization.md). Receipts print both
// calendars (features/pos/receipt_builder.dart).

bool _solar(AppLocalizations l) => l.localeName.startsWith('fa') || l.localeName.startsWith('ps');

String _two(int n) => n.toString().padLeft(2, '0');

/// [latin]'s digits in the locale's digit system (Persian digits in Dari and Pashto).
String localDigits(AppLocalizations l, String latin) => _solar(l)
    ? String.fromCharCodes(latin.codeUnits.map((c) => c >= 0x30 && c <= 0x39 ? 0x06F0 + c - 0x30 : c))
    : latin;

String solarMonthName(AppLocalizations l, int month) => switch (month) {
      1 => l.solarMonth1,
      2 => l.solarMonth2,
      3 => l.solarMonth3,
      4 => l.solarMonth4,
      5 => l.solarMonth5,
      6 => l.solarMonth6,
      7 => l.solarMonth7,
      8 => l.solarMonth8,
      9 => l.solarMonth9,
      10 => l.solarMonth10,
      11 => l.solarMonth11,
      _ => l.solarMonth12,
    };

/// The day [instant] falls on in a branch in [zone]: "۲۰ سنبله ۱۴۰۵", "11 Sep 2026".
String formatDate(AppLocalizations l, DateTime instant, String zone) {
  final local = branchWallClock(zone, instant);
  if (!_solar(l)) return DateFormat('d MMM y', 'en_US').format(local);
  final day = SolarHijriDate.fromGregorian(local);
  return l.solarDate(localDigits(l, '${day.day}'), solarMonthName(l, day.month), localDigits(l, '${day.year}'));
}

/// The time of [instant] on the branch's clock, 24-hour: "14:30".
String formatTime(AppLocalizations l, DateTime instant, String zone) {
  final local = branchWallClock(zone, instant);
  return localDigits(l, '${_two(local.hour)}:${_two(local.minute)}');
}

String formatDateTime(AppLocalizations l, DateTime instant, String zone) =>
    l.dateAndTime(formatDate(l, instant, zone), formatTime(l, instant, zone));
