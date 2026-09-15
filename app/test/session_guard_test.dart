import 'package:dukanpro/features/auth/session_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('taps on a pushed screen keep the app open; idling locks it', (tester) async {
    var locks = 0;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      home: SessionGuard(onLock: () => locks++, child: const Scaffold(body: Text('shell'))),
    ));
    // A screen pushed on the root navigator is not inside the guard.
    navigator.currentState!.push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Center(child: Text('receipt'))),
    ));
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(minutes: 9));
      await tester.tap(find.text('receipt'));
    }
    expect(locks, 0);

    await tester.pump(const Duration(minutes: 10));
    expect(locks, 1);
  });

  testWidgets('keys (a barcode scanner) are activity too', (tester) async {
    var locks = 0;
    await tester.pumpWidget(MaterialApp(
      home: SessionGuard(onLock: () => locks++, child: const Scaffold(body: Text('shell'))),
    ));
    await tester.pump(const Duration(minutes: 9));
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.pump(const Duration(minutes: 9));
    expect(locks, 0);
    await tester.pump(const Duration(minutes: 2));
    expect(locks, 1);
  });
}
