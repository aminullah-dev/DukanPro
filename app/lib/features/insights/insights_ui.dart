import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Renders a server insight/notification code + data into a localized message.
String insightMessage(AppLocalizations l, String code, Map<String, Object?> data) {
  String s(Object? v) => (v ?? '').toString();
  int n(Object? v) => v is int ? v : int.tryParse('$v') ?? 0;
  return switch (code) {
    'insight.reorder' => l.insightReorder(s(data['product'])),
    'insight.dead_stock' => l.insightDeadStock(s(data['product']), n(data['days'])),
    'insight.debt_risk' => l.insightDebtRisk(s(data['customer'])),
    'insight.digest' => l.insightDigest(n(data['count'])),
    _ => l.insightUnknown,
  };
}

/// Icon + colour for a severity (info | warning | critical).
({IconData icon, Color color}) severityStyle(BuildContext context, String severity) {
  final scheme = Theme.of(context).colorScheme;
  return switch (severity) {
    'critical' => (icon: Icons.error_outline, color: scheme.error),
    'warning' => (icon: Icons.warning_amber_outlined, color: Colors.orange.shade700),
    _ => (icon: Icons.lightbulb_outline, color: scheme.primary),
  };
}
