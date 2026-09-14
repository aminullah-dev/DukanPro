import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// Branch, discount and credit-limit guards (review theme 2). The same rows run
/// in server/tests/unit/test_access_rules.py.
void main() {
  test('writes need an active branch', () {
    expect(
      () => assertBranchActive(branchId: 'B1', isActive: false),
      throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'BRANCH_INACTIVE')),
    );
    assertBranchActive(branchId: 'B1', isActive: true); // no throw
  });

  test('a discount lies between 0 and the subtotal', () {
    for (final bad in [-1, 101]) {
      expect(
        () => assertDiscountValid(discountMinor: bad, subtotalMinor: 100),
        throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'SALE_DISCOUNT_INVALID')),
      );
    }
    assertDiscountValid(discountMinor: 0, subtotalMinor: 100); // no throw
    assertDiscountValid(discountMinor: 100, subtotalMinor: 100); // no throw
  });

  test('a credit limit is never negative', () {
    expect(
      () => assertCreditLimitValid(creditLimitMinor: -1),
      throwsA(isA<ValidationError>().having((e) => e.code, 'code', 'CUSTOMER_CREDIT_LIMIT_INVALID')),
    );
    assertCreditLimitValid(creditLimitMinor: null); // unlimited
    assertCreditLimitValid(creditLimitMinor: 0); // no credit
  });
}
