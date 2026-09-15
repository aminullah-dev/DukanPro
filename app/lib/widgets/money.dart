import 'package:dukan_core/dukan_core.dart' show formatQuantity;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/session.dart' show shopCurrencyProvider;
import '../l10n/app_localizations.dart';
import 'bidi.dart';

/// An amount as a figure: from integer minor units, grouped by thousands, in
/// Latin digits (figures stay Latin, docs/localization.md), the minus sign in
/// front even in a right-to-left line.
String amountText(int minor, {int decimalPlaces = 2}) {
  final plain = formatQuantity(minor, decimalPlaces);
  final negative = plain.startsWith('-');
  final digits = negative ? plain.substring(1) : plain;
  final dot = digits.indexOf('.');
  final whole = dot < 0 ? digits : digits.substring(0, dot);
  final grouped = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) grouped.write(',');
    grouped.write(whole[i]);
  }
  return ltr('${negative ? '-' : ''}$grouped${dot < 0 ? '' : digits.substring(dot)}');
}

/// A currency as people write it after an amount: "AFN" in English, "افغانی" in Dari.
String currencySymbol(AppLocalizations l, String code) => switch (code) {
      'AFN' => l.symbolAfn,
      'USD' => l.symbolUsd,
      'PKR' => l.symbolPkr,
      'EUR' => l.symbolEur,
      _ => code,
    };

/// An amount with its currency, placed as the locale writes it.
String formatMoney(AppLocalizations l, int minor, String currency) =>
    l.moneyAmount(amountText(minor), currencySymbol(l, currency));

/// The branch's currency, for amounts that no sale or product names one for
/// (cart totals, balances, typed amounts).
String shopCurrencyOf(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false).read(shopCurrencyProvider);
