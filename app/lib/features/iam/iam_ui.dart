import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/error_text.dart';

/// Built-in role names, in privilege order (matches the server).
const kRoleNames = ['owner', 'manager', 'cashier', 'stock_keeper', 'accountant'];

String roleLabel(AppLocalizations l, String roleName) => switch (roleName) {
      'owner' => l.roleOwner,
      'manager' => l.roleManager,
      'cashier' => l.roleCashier,
      'stock_keeper' => l.roleStockKeeper,
      'accountant' => l.roleAccountant,
      _ => roleName,
    };

/// Runs [action] behind a progress overlay, so it cannot be sent twice; on
/// success shows [okMessage], on failure a localized error.
Future<bool> runIam(
  BuildContext context,
  AppLocalizations l,
  Future<void> Function() action, {
  String? okMessage,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  unawaited(showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())),
  ));
  Object? failure;
  try {
    await action();
  } on Object catch (e) {
    failure = e;
  } finally {
    navigator.pop();
  }
  final message = failure == null ? okMessage : appErrorText(l, failure);
  if (context.mounted && message != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  return failure == null;
}
