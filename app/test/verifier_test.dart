import 'package:dukanpro/infrastructure/verifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Small cost parameters keep the test fast while exercising real argon2id.
  final verifier = Argon2Verifier(memory: 256, iterations: 1, parallelism: 1);

  test('derive then verify accepts the correct secret', () async {
    final stored = await verifier.derive('pw12345678');
    expect(await verifier.verify('pw12345678', stored), isTrue);
  });

  test('verify rejects the wrong secret', () async {
    final stored = await verifier.derive('pw12345678');
    expect(await verifier.verify('wrong', stored), isFalse);
  });

  test('two derivations of the same secret differ (random salt)', () async {
    final a = await verifier.derive('same');
    final b = await verifier.derive('same');
    expect(a == b, isFalse);
    expect(await verifier.verify('same', a), isTrue);
    expect(await verifier.verify('same', b), isTrue);
  });
}
