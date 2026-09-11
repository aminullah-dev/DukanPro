import 'package:dukanpro/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('boots in Dari (default) and renders the title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DukanProApp()));
    await tester.pumpAndSettle();
    expect(find.text('دکان‌پرو'), findsWidgets);
  });

  testWidgets('switching to English shows English strings', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DukanProApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('DukanPro'), findsWidgets);
    expect(find.text('Offline-first retail POS'), findsOneWidget);
  });
}
