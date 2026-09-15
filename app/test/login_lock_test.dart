// A closed sign-in says how long to wait, in the reader's digits.
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:dukanpro/widgets/error_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('too many wrong passwords: wait 15 minutes, in English and in Dari digits', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final fa = await AppLocalizations.delegate.load(const Locale('fa'));
    expect(errorCodeText(en, 'LOGIN_LOCKED'), contains('15 minutes'));
    expect(errorCodeText(fa, 'LOGIN_LOCKED'), contains('۱۵'));
  });
}
