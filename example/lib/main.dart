import 'package:flutter/material.dart';
import 'package:shadcn_chart/shadcn_chart.dart';

void main() {
  runApp(const ChartExampleApp());
}

class ChartExampleApp extends StatefulWidget {
  const ChartExampleApp({super.key});

  @override
  State<ChartExampleApp> createState() => _ChartExampleAppState();
}

class _ChartExampleAppState extends State<ChartExampleApp> {
  int _revision = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('shadcn_chart example'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => setState(() => _revision++),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh data'),
        ),
        body: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.25,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _ChartPanel(title: 'Interactive bar', data: _interactiveBar()),
            _ChartPanel(title: 'Multiple bar', data: _multipleBar()),
            _ChartPanel(title: 'Interactive area', data: _area()),
            _ChartPanel(title: 'Interactive line', data: _interactiveLine()),
            _ChartPanel(title: 'Donut pie', data: _pieDonut()),
            _ChartPanel(title: 'Legend pie', data: _pieLegend()),
            _ChartPanel(title: 'Stacked radial', data: _radial()),
          ],
        ),
      ),
    );
  }

  List<ChartSeries> get _trafficSeries => const [
        ChartSeries(key: 'desktop', label: 'Desktop', color: Colors.teal),
        ChartSeries(key: 'mobile', label: 'Mobile', color: Colors.deepOrange),
      ];

  List<TimeSeriesPoint> get _trafficData {
    final bump = _revision * 18;
    return [
      TimeSeriesPoint(
        date: DateTime(2026, 6, 1),
        values: {'desktop': 178 + bump, 'mobile': 200 + bump},
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 6, 5),
        values: {'desktop': 294 + bump, 'mobile': 250 + bump},
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 6, 10),
        values: {'desktop': 155 + bump, 'mobile': 200 + bump},
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 6, 15),
        values: {'desktop': 307 + bump, 'mobile': 350 + bump},
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 6, 20),
        values: {'desktop': 408 + bump, 'mobile': 450 + bump},
      ),
      TimeSeriesPoint(
        date: DateTime(2026, 6, 30),
        values: {'desktop': 446 + bump, 'mobile': 400 + bump},
      ),
    ];
  }

  InteractiveBarChartData _interactiveBar() => InteractiveBarChartData(
        // title: 'Visitors by device',
        // description: 'Interactive bar chart with selectable series',
        series: _trafficSeries,
        activeSeriesKey: 'desktop',
        data: _trafficData,
      );

  InteractiveLineChartData _interactiveLine() => InteractiveLineChartData(
        title: 'Visitors trend',
        description: 'Interactive line chart with selectable series',
        series: _trafficSeries,
        activeSeriesKey: 'mobile',
        data: _trafficData,
      );

  AreaChartData _area() => AreaChartData(
        title: 'Visitors over time',
        description: 'Area chart with range filtering',
        series: _trafficSeries,
        referenceDate: DateTime(2026, 6, 30),
        data: _trafficData,
      );

  MultipleBarChartData _multipleBar() => MultipleBarChartData(
        title: 'Monthly visitors',
        description: 'January - June 2026',
        footerTitle: 'Trending up by ${5 + _revision}.2% this month',
        footerDescription: 'Grouped desktop and mobile totals',
        series: _trafficSeries,
        data: [
          CategorySeriesPoint(
            category: 'January',
            values: {'desktop': 186 + _revision, 'mobile': 80 + _revision},
          ),
          CategorySeriesPoint(
            category: 'February',
            values: {'desktop': 305 + _revision, 'mobile': 200 + _revision},
          ),
          CategorySeriesPoint(
            category: 'March',
            values: {'desktop': 237 + _revision, 'mobile': 120 + _revision},
          ),
          CategorySeriesPoint(
            category: 'April',
            values: {'desktop': 73 + _revision, 'mobile': 190 + _revision},
          ),
          CategorySeriesPoint(
            category: 'May',
            values: {'desktop': 209 + _revision, 'mobile': 130 + _revision},
          ),
          CategorySeriesPoint(
            category: 'June',
            values: {'desktop': 214 + _revision, 'mobile': 140 + _revision},
          ),
        ],
      );

  List<PieChartSegment> get _browserSegments => [
        PieChartSegment(
          key: 'chrome',
          label: 'Chrome',
          value: 275 + _revision,
          color: Colors.teal,
        ),
        PieChartSegment(
          key: 'safari',
          label: 'Safari',
          value: 200 + _revision,
          color: Colors.deepOrange,
        ),
        PieChartSegment(
          key: 'firefox',
          label: 'Firefox',
          value: 187 + _revision,
          color: Colors.blue,
        ),
        PieChartSegment(
          key: 'edge',
          label: 'Edge',
          value: 173 + _revision,
          color: Colors.deepPurple,
        ),
        PieChartSegment(
          key: 'other',
          label: 'Other',
          value: 90 + _revision,
          color: Colors.amber,
        ),
      ];

  PieDonutChartData _pieDonut() => PieDonutChartData(
        title: 'Browser share',
        description: 'Donut chart',
        footerTitle: 'Trending up by 5.2% this month',
        footerDescription: 'Total visitors by browser',
        segments: _browserSegments,
      );

  PieLegendChartData _pieLegend() => PieLegendChartData(
        title: 'Browser legend',
        description: 'Pie chart with legend',
        segments: _browserSegments,
      );

  RadialStackedChartData _radial() => RadialStackedChartData(
        title: 'Device total',
        description: 'Stacked radial chart',
        footerTitle: 'Trending up by 5.2% this month',
        footerDescription: 'Desktop and mobile visitors',
        centerLabel: 'Visitors',
        series: _trafficSeries,
        values: {
          'desktop': 1260 + (_revision * 10),
          'mobile': 570 + (_revision * 10),
        },
      );
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.title, required this.data});

  final String title;
  final ShadcnChartData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 360,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ShadcnChartView(data: data),
            ),
          ),
        ],
      ),
    );
  }
}
