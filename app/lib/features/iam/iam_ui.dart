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

/// Runs [action]; on success shows [okMessage], on failure a localized error.
Future<bool> runIam(
  BuildContext context,
  AppLocalizations l,
  Future<void> Function() action, {
  String? okMessage,
}) async {
  try {
    await action();
    if (context.mounted && okMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(okMessage)));
    }
    return true;
  } on Object catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(iamErrorMessage(l, e))));
    }
    return false;
  }
}
