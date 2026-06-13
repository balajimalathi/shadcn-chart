import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_chart/shadcn_chart.dart';

void main() {
  const series = [
    ChartSeries(key: 'desktop', label: 'Desktop', color: Color(0xff0f766e)),
    ChartSeries(key: 'mobile', label: 'Mobile', color: Color(0xffea580c)),
  ];

  test('interactive line chart serializes to renderer payload', () {
    final chart = InteractiveLineChartData(
      title: 'Traffic',
      description: 'Last week',
      activeSeriesKey: 'mobile',
      series: series,
      data: [
        TimeSeriesPoint(
          date: DateTime(2026, 6, 1),
          values: const {'desktop': 120, 'mobile': 98},
        ),
      ],
    );

    expect(chart.type, ShadcnChartType.lineInteractive);
    expect(chart.toJson(), {
      'title': 'Traffic',
      'description': 'Last week',
      'valueLabel': 'Page Views',
      'xKey': 'date',
      'xType': 'date',
      'activeSeries': 'mobile',
      'series': [
        {'key': 'desktop', 'label': 'Desktop', 'color': '#0f766e'},
        {'key': 'mobile', 'label': 'Mobile', 'color': '#ea580c'},
      ],
      'data': [
        {'date': '2026-06-01', 'desktop': 120, 'mobile': 98},
      ],
    });
  });

  test('charts can serialize fallback Flutter color palettes', () {
    final chart = InteractiveLineChartData(
      colors: const [Colors.red, Color(0x802196f3)],
      series: const [
        ChartSeries(key: 'desktop', label: 'Desktop'),
        ChartSeries(key: 'mobile', label: 'Mobile', color: Colors.teal),
      ],
      data: [
        TimeSeriesPoint(
          date: DateTime(2026, 6, 1),
          values: const {'desktop': 120, 'mobile': 98},
        ),
      ],
    );

    expect(chart.toJson()['colors'], ['#f44336', '#2196f380']);
    expect(chart.toJson()['series'], [
      {'key': 'desktop', 'label': 'Desktop'},
      {'key': 'mobile', 'label': 'Mobile', 'color': '#009688'},
    ]);
  });

  test('chart titles are optional', () {
    final chart = InteractiveLineChartData(
      series: const [ChartSeries(key: 'desktop', label: 'Desktop')],
      data: [
        TimeSeriesPoint(
          date: DateTime(2026, 6, 1),
          values: const {'desktop': 120},
        ),
      ],
    );

    expect(chart.toJson().containsKey('title'), isFalse);
  });

  test('interactive bar chart serializes active series', () {
    final chart = InteractiveBarChartData(
      title: 'Visitors',
      activeSeriesKey: 'desktop',
      series: series,
      data: [
        TimeSeriesPoint(
          date: DateTime(2026, 6, 1),
          values: const {'desktop': 120, 'mobile': 98},
        ),
      ],
    );

    expect(chart.type, ShadcnChartType.barInteractive);
    expect(chart.toJson()['activeSeries'], 'desktop');
    expect(chart.toJson()['title'], 'Visitors');
  });

  test('area chart serializes time ranges and reference date', () {
    final chart = AreaChartData(
      data: [
        TimeSeriesPoint(
          date: DateTime(2026, 6, 1),
          values: const {'desktop': 1},
        ),
      ],
      series: const [ChartSeries(key: 'desktop', label: 'Desktop')],
      referenceDate: DateTime(2026, 6, 7),
    );

    expect(chart.type, ShadcnChartType.areaInteractive);
    expect(chart.toJson()['referenceDate'], '2026-06-07');
    expect(chart.toJson()['timeRanges'], isNotEmpty);
  });

  test('multiple bar chart serializes category data', () {
    final chart = MultipleBarChartData(
      title: 'Monthly',
      series: series,
      data: const [
        CategorySeriesPoint(
          category: 'January',
          values: {'desktop': 186, 'mobile': 80},
        ),
      ],
    );

    expect(chart.type, ShadcnChartType.barMultiple);
    expect(chart.toJson()['xType'], 'category');
    expect(chart.toJson()['data'], [
      {'category': 'January', 'desktop': 186, 'mobile': 80},
    ]);
  });

  test('pie chart serializes segments into data and config arrays', () {
    const chart = PieDonutChartData(
      title: 'Browsers',
      segments: [
        PieChartSegment(key: 'chrome', label: 'Chrome', value: 275),
        PieChartSegment(
          key: 'safari',
          label: 'Safari',
          value: 200,
          color: Color(0xff2563eb),
        ),
      ],
    );

    expect(chart.type, ShadcnChartType.pieDonut);
    expect(chart.toJson(), {
      'title': 'Browsers',
      'nameKey': 'name',
      'valueKey': 'value',
      'segments': [
        {'key': 'chrome', 'label': 'Chrome'},
        {'key': 'safari', 'label': 'Safari', 'color': '#2563eb'},
      ],
      'data': [
        {'name': 'chrome', 'value': 275},
        {'name': 'safari', 'value': 200},
      ],
    });
  });

  test('legend pie chart serializes segments', () {
    const chart = PieLegendChartData(
      title: 'Browsers',
      segments: [
        PieChartSegment(key: 'chrome', label: 'Chrome', value: 275),
      ],
    );

    expect(chart.type, ShadcnChartType.pieLegend);
    expect(chart.toJson()['title'], 'Browsers');
    expect(chart.toJson()['segments'], [
      {'key': 'chrome', 'label': 'Chrome'},
    ]);
  });

  test('radial stacked chart serializes values map', () {
    const chart = RadialStackedChartData(
      title: 'Devices',
      centerLabel: 'Total',
      series: series,
      values: {'desktop': 1260, 'mobile': 570},
    );

    expect(chart.type, ShadcnChartType.radialStacked);
    expect(chart.toJson()['centerLabel'], 'Total');
    expect(chart.toJson()['data'], [
      {'desktop': 1260, 'mobile': 570},
    ]);
  });

  test('chart type exposes package asset keys', () {
    expect(
      ShadcnChartType.barInteractive.packageAssetKey,
      'packages/shadcn_chart/assets/charts/bar-interactive.html',
    );
    expect(
      ShadcnChartType.radialStacked.assetPath,
      'assets/charts/radial-stacked.html',
    );
  });
}
