import 'package:flutter_test/flutter_test.dart';
import 'package:truckcalc/Model/calculation_model.dart';
import 'package:truckcalc/Utils/report_formatting.dart';

void main() {
  test('report dates use padded month/day/year', () {
    expect(formatReportDate(DateTime.utc(2026, 8, 16)), '08/16/2026');
    expect(formatReportDate(DateTime(2026, 1, 2)), '01/02/2026');
    expect(formatReportDate(DateTime.utc(2028, 2, 29)), '02/29/2028');
    expect(formatReportDate(DateTime.utc(2026, 12, 31, 23, 59)), '12/31/2026');
  });

  test('load preview renders actual amounts including cents and DH miles', () {
    final load = LoadData.fromJson({
      'loadedMiles': 900, 'dhMiles': 29,
      'totalRevenue': 950, 'totalCost': 585.27, 'totalProfit': 364.73,
    });
    expect(formatLoadPreview(load),
        r'Load: 929 mi | Rev: $950.00 | Cost: $585.27 | Profit: $364.73');
  });

  test('load preview preserves zero and negative amounts', () {
    expect(formatLoadPreview(LoadData(
      loadedMiles: 133, totalRevenue: 0, totalCost: 83.79, totalProfit: -83.79,
    )), r'Load: 133 mi | Rev: $0.00 | Cost: $83.79 | Profit: $-83.79');
  });

  test('missing amounts are not displayed as null or invented zeroes', () {
    expect(formatLoadPreview(LoadData()),
        'Load: 0 mi | Rev: - | Cost: - | Profit: -');
  });
}
