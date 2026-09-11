import 'errors.dart';

/// Money: integer minor units plus an ISO-4217 currency code.
///
/// Floats are **never** permitted in a money path — [amountMinor] is an `int`
/// by type. Arithmetic between different currencies raises; there is no
/// implicit conversion. AFN has 2 minor digits.
final class Money implements Comparable<Money> {
  const Money(this.amountMinor, this.currency);

  final int amountMinor;
  final String currency;

  static Money zero(String currency) => Money(0, currency);

  /// Validates the ISO-4217 shape. Call at construction boundaries / parsing.
  Money validated() {
    if (currency.length != 3 || currency.toUpperCase() != currency) {
      throw ValidationError('MONEY_CURRENCY_INVALID', {'currency': currency});
    }
    return this;
  }

  void _same(Money other) {
    if (currency != other.currency) {
      throw ValidationError(
          'MONEY_CURRENCY_MISMATCH', {'a': currency, 'b': other.currency});
    }
  }

  Money operator +(Money other) {
    _same(other);
    return Money(amountMinor + other.amountMinor, currency);
  }

  Money operator -(Money other) {
    _same(other);
    return Money(amountMinor - other.amountMinor, currency);
  }

  /// Scale by a whole quantity (e.g. unit price × qty). Keeps integer exactness.
  Money operator *(int qty) => Money(amountMinor * qty, currency);

  bool get isNegative => amountMinor < 0;
  bool get isZero => amountMinor == 0;

  @override
  int compareTo(Money other) {
    _same(other);
    return amountMinor.compareTo(other.amountMinor);
  }

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.amountMinor == amountMinor &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(amountMinor, currency);

  @override
  String toString() => '$amountMinor $currency';
}
