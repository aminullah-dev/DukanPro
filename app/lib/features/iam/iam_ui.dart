import 'dart:async';

import 'package:flutter/material.dart';

import '../../infrastructure/auth_api.dart' show AuthApiException, NetworkException;
import '../../l10n/app_localizations.dart';

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

/// Maps a thrown IAM error to a human message in the active locale.
String iamErrorMessage(AppLocalizations l, Object error) {
  if (error is NetworkException) return l.errNetwork;
  if (error is AuthApiException) {
    return switch (error.code) {
      'USER_LAST_OWNER' => l.errUserLastOwner,
      'BRANCH_LAST_ACTIVE' => l.errBranchLastActive,
      'USER_DUPLICATE_USERNAME' => l.errUsernameTaken,
      'ACCESS_DENIED' => l.permissionDenied,
      _ => l.errGeneric,
    };
  }
  return l.errGeneric;
}

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
  final message = failure == null ? okMessage : iamErrorMessage(l, failure);
  if (context.mounted && message != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  return failure == null;
}
