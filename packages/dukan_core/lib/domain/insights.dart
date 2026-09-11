/// Insight rules. Mirrors server/dukan/domain/insights.py — the SAME rules run
/// in both languages. Pure: no imports. Quantities are integer minor units
/// (see Money invariant); an insight is a decision, its wording lives in the UI.

enum InsightSeverity { info, warning, critical }

/// Suggested reorder quantity (minor units) to bring stock back to twice the
/// reorder point, or 0 when stock still covers lead + safety demand.
///
/// reorderPoint = avgDailySales × (leadTimeDays + safetyDays).
int reorderSuggestion({
  required int onHandMinor,
  required int avgDailySalesMinor,
  int leadTimeDays = 7,
  int safetyDays = 3,
}) {
  if (avgDailySalesMinor <= 0) return 0;
  final reorderPoint = avgDailySalesMinor * (leadTimeDays + safetyDays);
  if (onHandMinor > reorderPoint) return 0;
  final qty = reorderPoint * 2 - onHandMinor;
  return qty < 0 ? 0 : qty;
}

/// Stock that is on hand but has not sold within [deadAfterDays] — capital tied
/// up in slow inventory.
bool isDeadStock({
  required int onHandMinor,
  required int daysSinceLastSale,
  int deadAfterDays = 30,
}) =>
    onHandMinor > 0 && daysSinceLastSale >= deadAfterDays;

/// How urgent a customer's outstanding balance is, relative to their credit
/// limit: at/over the limit is critical, ≥80% is a warning.
InsightSeverity debtSeverity({
  required int balanceMinor,
  required int creditLimitMinor,
}) {
  if (balanceMinor <= 0 || creditLimitMinor <= 0) return InsightSeverity.info;
  if (balanceMinor >= creditLimitMinor) return InsightSeverity.critical;
  if (balanceMinor * 10 >= creditLimitMinor * 8) return InsightSeverity.warning;
  return InsightSeverity.info;
}
