import 'package:dukan_core/dukan_core.dart';
import 'package:test/test.dart';

/// Mirrors server/tests/unit/test_branches.py and docs/domain/branches.md.
void main() {
  group('assertNotLastActiveBranch', () {
    test('deactivating one of several is allowed', () {
      expect(() => assertNotLastActiveBranch(activeBranchCount: 2), returnsNormally);
    });

    test('deactivating the last active branch is blocked', () {
      expect(
        () => assertNotLastActiveBranch(activeBranchCount: 1),
        throwsA(isA<ConflictError>().having((e) => e.code, 'code', 'BRANCH_LAST_ACTIVE')),
      );
    });
  });
}
