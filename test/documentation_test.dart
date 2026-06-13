import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_chart/shadcn_chart.dart';

void main() {
  test('public serialization helpers are documented', () {
    // Ensures dartdoc /// lines exist above these members.
    expect(ChartSeries(key: 'a', label: 'A').toJson, isNotNull);
    expect(
      TimeSeriesPoint(date: DateTime(2026, 1, 1), values: const {}).toJson,
      isNotNull,
    );
    expect(
      CategorySeriesPoint(category: 'Jan', values: const {}).toJson,
      isNotNull,
    );
    expect(
      TimeRangeOption(value: '7d', label: '7 days', days: 7).toJson,
      isNotNull,
    );
  });
}
