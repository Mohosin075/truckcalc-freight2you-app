import 'package:truckcalc/Model/calculation_model.dart';

/// Keep report dates independent of device locale and preserve the stored day.
String formatReportDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year.toString().padLeft(4, '0')}';
}

String _formatMoney(double? value) {
  if (value == null) return '-';
  return '\$${value.toStringAsFixed(2)}';
}

String formatLoadPreview(LoadData load) {
  final miles = (load.loadedMiles ?? 0) + (load.dhMiles ?? 0);
  return 'Load: $miles mi | Rev: ${_formatMoney(load.totalRevenue)} | '
      'Cost: ${_formatMoney(load.totalCost)} | '
      'Profit: ${_formatMoney(load.totalProfit)}';
}
