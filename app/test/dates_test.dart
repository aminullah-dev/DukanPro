// Theme 9b: times are read on the branch's clock, in Solar Hijri with Persian
// digits in Dari and Pashto, and receipts carry both calendars.
import 'package:dukan_core/dukan_core.dart';
import 'package:dukanpro/features/pos/receipt_builder.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:dukanpro/widgets/dates.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fa = lookupAppLocalizations(const Locale('fa', 'AF'));
  final ps = lookupAppLocalizations(const Locale('ps'));
  final at = DateTime.utc(2026, 9, 11, 10); // 14:30 on 20 Sunbula 1405 in Kabul

  test('Dari and Pashto read the Solar Hijri date in Persian digits; English the Gregorian', () {
    expect(formatDateTime(fa, at, 'Asia/Kabul'), '۲۰ سنبله ۱۴۰۵، ۱۴:۳۰');
    expect(formatDateTime(ps, at, 'Asia/Kabul'), '۲۰ وږی ۱۴۰۵، ۱۴:۳۰');
    expect(formatDateTime(en, at, 'Asia/Kabul'), '11 Sep 2026, 14:30');
  });

  test("times are the branch's, whatever the device's zone", () {
    final lateAtNight = DateTime.utc(2026, 9, 11, 20, 30); // 01:00 on the 12th in Kabul
    expect(formatTime(en, lateAtNight, 'Asia/Kabul'), '01:00');
    expect(formatDate(en, lateAtNight, 'Asia/Kabul'), '12 Sep 2026');
    expect(formatDate(en, lateAtNight.toLocal(), 'Asia/Kabul'), '12 Sep 2026');
    expect(formatDate(fa, DateTime.utc(2026, 3, 20, 20, 0), 'Asia/Kabul'), '۱ حمل ۱۴۰۵'); // Nowruz in Kabul
  });

  test('a receipt carries both calendars on the branch clock, in ASCII', () {
    expect(receiptStamp('Asia/Kabul', at), '1405-06-20 14:30 (2026-09-11)');
    expect(receiptStamp(defaultBranchZone, DateTime.utc(2026, 9, 11, 20, 30)), '1405-06-21 01:00 (2026-09-12)');
  });
}
