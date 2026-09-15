// A void is asked of the server from the till: the sale is pushed first and the
// reversal pulled back; offline, nothing is asked. Only sale.void sees it, and
// a reason is required.
import 'package:dukan_core/dukan_core.dart';
import 'package:dukanpro/features/auth/session.dart';
import 'package:dukanpro/features/pos/pos_providers.dart';
import 'package:dukanpro/features/pos/void_sale.dart';
import 'package:dukanpro/infrastructure/auth_api.dart';
import 'package:dukanpro/infrastructure/sales_api.dart';
import 'package:dukanpro/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api implements SalesApi {
  final calls = <String>[];
  Object? refusal;

  @override
  Future<void> voidSale(String saleId, {required String reason}) async {
    calls.add('$saleId: $reason');
    if (refusal != null) throw refusal!;
  }
}

SessionActor _actor(String role) => SessionActor(
      User(
        id: 'u-$role', username: role, displayName: role, status: UserStatus.active,
        assignments: [BranchAssignment(branchId: 'B1', roleName: role)], defaultBranchId: 'B1',
      ),
      'B1',
    );

Future<void> _button(WidgetTester tester, String role, _Api api, {required VoidCallback onVoided}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sessionActorProvider.overrideWithValue(_actor(role)),
      tillVoidProvider.overrideWithValue(TillVoid(api: api, sync: () async {}, synced: () => true)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: VoidSaleButton(saleId: 's1', settled: true, onVoided: onVoided)),
    ),
  ));
}

void main() {
  test('the sale is pushed, voided, and the reversal pulled back', () async {
    final api = _Api();
    var syncs = 0;
    await TillVoid(api: api, sync: () async => syncs++, synced: () => true)('s1', reason: 'wrong item');
    expect(api.calls, ['s1: wrong item']);
    expect(syncs, 2);
  });

  test('offline, nothing is asked of the server', () async {
    final api = _Api();
    var syncs = 0;
    await expectLater(
      TillVoid(api: api, sync: () async => syncs++, synced: () => false)('s1', reason: 'wrong item'),
      throwsA(isA<NetworkException>()),
    );
    expect(api.calls, isEmpty);
    expect(syncs, 1);
  });

  testWidgets('a cashier has no void', (tester) async {
    await _button(tester, 'cashier', _Api(), onVoided: () {});
    expect(find.text('Void sale'), findsNothing);
  });

  testWidgets('a manager voids with a reason', (tester) async {
    final api = _Api();
    var voided = false;
    await _button(tester, 'manager', api, onVoided: () => voided = true);
    await tester.tap(find.text('Void sale'));
    await tester.pumpAndSettle();
    final confirm = find.widgetWithText(FilledButton, 'Void sale');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull); // no reason yet
    await tester.enterText(find.byType(TextField), 'rang up twice');
    await tester.pump();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(api.calls, ['s1: rang up twice']);
    expect(voided, isTrue);
    expect(find.text('The sale was voided.'), findsOneWidget);
  });

  testWidgets('a cash sale whose shift has closed is not voided, and the till says why', (tester) async {
    final api = _Api()..refusal = AuthApiException('SALE_SHIFT_CLOSED', statusCode: 409);
    var voided = false;
    await _button(tester, 'owner', api, onVoided: () => voided = true);
    await tester.tap(find.text('Void sale'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'customer changed mind');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Void sale'));
    await tester.pumpAndSettle();
    expect(voided, isFalse);
    expect(find.textContaining("shift is already closed"), findsOneWidget);
  });
}
