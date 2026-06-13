/// Chart renderers bundled with this package.
enum ShadcnChartType {
  /// Interactive area chart with a time-range selector.
  areaInteractive,

  /// Interactive bar chart with a date axis and active series toggle.
  barInteractive,

  /// Grouped bar chart with a category axis.
  barMultiple,

  /// Interactive line chart with a date axis and active series toggle.
  lineInteractive,

  /// Donut pie chart with optional footer text.
  pieDonut,

  /// Pie chart with a side legend.
  pieLegend,

  /// Stacked radial chart with a center total label.
  radialStacked,
}

/// Supported chart themes passed to the embedded renderer.
enum ShadcnChartTheme {
  /// Light color scheme.
  light,

  /// Dark color scheme.
  dark,

  /// Follow the host system preference.
  system,
}

/// Asset path helpers for [ShadcnChartType].
extension ShadcnChartTypeAsset on ShadcnChartType {
  /// The bundled HTML asset used by this chart type.
  String get assetPath {
    return switch (this) {
      ShadcnChartType.areaInteractive => 'assets/charts/area-interactive.html',
      ShadcnChartType.barInteractive => 'assets/charts/bar-interactive.html',
      ShadcnChartType.barMultiple => 'assets/charts/bar-multiple.html',
      ShadcnChartType.lineInteractive => 'assets/charts/line-interactive.html',
      ShadcnChartType.pieDonut => 'assets/charts/pie-donut.html',
      ShadcnChartType.pieLegend => 'assets/charts/pie-legend.html',
      ShadcnChartType.radialStacked => 'assets/charts/radial-stacked.html',
    };
  }

  /// Asset key for loading the chart from another package.
  String get packageAssetKey => 'packages/shadcn_chart/$assetPath';
}

/// JSON theme values for [ShadcnChartTheme].
extension ShadcnChartThemeValue on ShadcnChartTheme {
  /// JSON value expected by the bundled chart runtime.
  String get value => name;
}

/// Series metadata shared by cartesian and radial charts.
class ChartSeries {
  /// Creates a chart series.
  const ChartSeries({
    required this.key,
    required this.label,
    this.color,
  });

  /// Data object key used by Recharts.
  final String key;

  /// Human-readable label shown in legends and tooltips.
  final String label;

  /// Optional CSS color, for example `#0f766e` or `hsl(173 58% 39%)`.
  final String? color;

  /// Serializes this series to the JSON shape expected by the renderer.
  Map<String, Object?> toJson() => {
        'key': key,
        'label': label,
        if (color != null) 'color': color,
      };
}

/// A date-based point for line, area, and interactive bar charts.
class TimeSeriesPoint {
  /// Creates a time series point.
  const TimeSeriesPoint({
    required this.date,
    required this.values,
  });

  /// Date represented by this point.
  final DateTime date;

  /// Numeric values keyed by [ChartSeries.key].
  final Map<String, num> values;

  /// Serializes this point to a JSON map keyed by [date] and series keys.
  Map<String, Object?> toJson() => {
        'date': _dateOnly(date),
        ...values,
      };
}

/// A category-based point for grouped bar charts.
class CategorySeriesPoint {
  /// Creates a category series point.
  const CategorySeriesPoint({
    required this.category,
    required this.values,
  });

  /// Category label shown on the x-axis.
  final String category;

  /// Numeric values keyed by [ChartSeries.key].
  final Map<String, num> values;

  /// Serializes this category point to a JSON map.
  Map<String, Object?> toJson() => {
        'category': category,
        ...values,
      };
}

/// A selectable range for area charts.
class TimeRangeOption {
  /// Creates a time range option.
  const TimeRangeOption({
    required this.value,
    required this.label,
    required this.days,
  });

  /// Stable value used by the WebView selector.
  final String value;

  /// Visible range label.
  final String label;

  /// Number of days to show from the reference date.
  final int days;

  /// Serializes this time range option for the area chart selector.
  Map<String, Object?> toJson() => {
        'value': value,
        'label': label,
        'days': days,
      };
}

/// A segment in pie and donut charts.
class PieChartSegment {
  /// Creates a pie chart segment.
  const PieChartSegment({
    required this.key,
    required this.label,
    required this.value,
    this.color,
  });

  /// Stable segment key.
  final String key;

  /// Human-readable segment label.
  final String label;

  /// Numeric segment value.
  final num value;

  /// Optional CSS color.
  final String? color;

  Map<String, Object?> get _seriesJson => {
        'key': key,
        'label': label,
        if (color != null) 'color': color,
      };

  Map<String, Object?> get _datumJson => {
        'name': key,
        'value': value,
      };
}

/// Base class for all typed chart payloads.
abstract class ShadcnChartData {
  /// Creates chart data.
  const ShadcnChartData();

  /// Renderer type for this payload.
  ShadcnChartType get type;

  /// JSON sent to the embedded chart runtime.
  Map<String, Object?> toJson();
}

/// Data for the interactive bar chart.
class InteractiveBarChartData extends ShadcnChartData {
  /// Creates interactive bar chart data.
  const InteractiveBarChartData({
    required this.data,
    required this.series,
    this.title = 'Bar Chart - Interactive',
    this.description,
    this.valueLabel = 'Page Views',
    this.activeSeriesKey,
    this.theme,
  });

  /// Time-ordered points rendered on the date axis.
  final List<TimeSeriesPoint> data;

  /// Series metadata; each [ChartSeries.key] must appear in point values.
  final List<ChartSeries> series;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Tooltip and legend label for numeric values.
  final String valueLabel;

  /// Initially highlighted series key, if any.
  final String? activeSeriesKey;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.barInteractive;

  @override
  Map<String, Object?> toJson() => _cartesianTimeJson(
        title: title,
        description: description,
        valueLabel: valueLabel,
        data: data,
        series: series,
        activeSeriesKey: activeSeriesKey,
        theme: theme,
      );
}

/// Data for the interactive line chart.
class InteractiveLineChartData extends ShadcnChartData {
  /// Creates interactive line chart data.
  const InteractiveLineChartData({
    required this.data,
    required this.series,
    this.title = 'Line Chart - Interactive',
    this.description,
    this.valueLabel = 'Page Views',
    this.activeSeriesKey,
    this.theme,
  });

  /// Time-ordered points rendered on the date axis.
  final List<TimeSeriesPoint> data;

  /// Series metadata; each [ChartSeries.key] must appear in point values.
  final List<ChartSeries> series;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Tooltip and legend label for numeric values.
  final String valueLabel;

  /// Initially highlighted series key, if any.
  final String? activeSeriesKey;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.lineInteractive;

  @override
  Map<String, Object?> toJson() => _cartesianTimeJson(
        title: title,
        description: description,
        valueLabel: valueLabel,
        data: data,
        series: series,
        activeSeriesKey: activeSeriesKey,
        theme: theme,
      );
}

/// Data for the interactive area chart.
class AreaChartData extends ShadcnChartData {
  /// Creates area chart data.
  const AreaChartData({
    required this.data,
    required this.series,
    this.title = 'Area Chart - Interactive',
    this.description,
    this.valueLabel = 'Visitors',
    this.timeRanges = const [
      TimeRangeOption(value: '90d', label: 'Last 3 months', days: 90),
      TimeRangeOption(value: '30d', label: 'Last 30 days', days: 30),
      TimeRangeOption(value: '7d', label: 'Last 7 days', days: 7),
    ],
    this.defaultTimeRange = '90d',
    this.referenceDate,
    this.theme,
  });

  /// Time-ordered points rendered on the date axis.
  final List<TimeSeriesPoint> data;

  /// Series metadata; each [ChartSeries.key] must appear in point values.
  final List<ChartSeries> series;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Tooltip and legend label for numeric values.
  final String valueLabel;

  /// Selectable time ranges shown in the chart header.
  final List<TimeRangeOption> timeRanges;

  /// Initially selected [TimeRangeOption.value].
  final String? defaultTimeRange;

  /// End date used when filtering points by the selected range.
  final DateTime? referenceDate;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.areaInteractive;

  @override
  Map<String, Object?> toJson() => {
        ..._cartesianTimeJson(
          title: title,
          description: description,
          valueLabel: valueLabel,
          data: data,
          series: series,
          theme: theme,
        ),
        'timeRanges': timeRanges.map((item) => item.toJson()).toList(),
        if (defaultTimeRange != null) 'defaultTimeRange': defaultTimeRange,
        if (referenceDate != null) 'referenceDate': _dateOnly(referenceDate!),
      };
}

/// Data for the grouped bar chart.
class MultipleBarChartData extends ShadcnChartData {
  /// Creates grouped bar chart data.
  const MultipleBarChartData({
    required this.data,
    required this.series,
    this.title = 'Bar Chart - Multiple',
    this.description,
    this.footerTitle,
    this.footerDescription,
    this.theme,
  });

  /// Category points rendered on the x-axis.
  final List<CategorySeriesPoint> data;

  /// Series metadata; each [ChartSeries.key] must appear in point values.
  final List<ChartSeries> series;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Optional footer heading below the chart.
  final String? footerTitle;

  /// Optional footer body text below the chart.
  final String? footerDescription;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.barMultiple;

  @override
  Map<String, Object?> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (footerTitle != null) 'footerTitle': footerTitle,
        if (footerDescription != null) 'footerDescription': footerDescription,
        if (theme != null) 'theme': theme!.value,
        'xKey': 'category',
        'xType': 'category',
        'series': series.map((item) => item.toJson()).toList(),
        'data': data.map((item) => item.toJson()).toList(),
      };
}

/// Data for donut pie charts.
class PieDonutChartData extends ShadcnChartData {
  /// Creates donut pie chart data.
  const PieDonutChartData({
    required this.segments,
    this.title = 'Pie Chart - Donut',
    this.description,
    this.footerTitle,
    this.footerDescription,
    this.theme,
  });

  /// Slice definitions and values for the chart.
  final List<PieChartSegment> segments;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Optional footer heading below the chart.
  final String? footerTitle;

  /// Optional footer body text below the chart.
  final String? footerDescription;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.pieDonut;

  @override
  Map<String, Object?> toJson() => _pieJson(
        title: title,
        description: description,
        footerTitle: footerTitle,
        footerDescription: footerDescription,
        segments: segments,
        theme: theme,
      );
}

/// Data for pie charts with a legend.
class PieLegendChartData extends ShadcnChartData {
  /// Creates legend pie chart data.
  const PieLegendChartData({
    required this.segments,
    this.title = 'Pie Chart - Legend',
    this.description,
    this.theme,
  });

  /// Slice definitions and values for the chart.
  final List<PieChartSegment> segments;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.pieLegend;

  @override
  Map<String, Object?> toJson() => _pieJson(
        title: title,
        description: description,
        segments: segments,
        theme: theme,
      );
}

/// Data for the stacked radial chart.
class RadialStackedChartData extends ShadcnChartData {
  /// Creates stacked radial chart data.
  const RadialStackedChartData({
    required this.values,
    required this.series,
    this.title = 'Radial Chart - Stacked',
    this.description,
    this.centerLabel = 'Total',
    this.footerTitle,
    this.footerDescription,
    this.theme,
  });

  /// Numeric values keyed by [ChartSeries.key].
  final Map<String, num> values;

  /// Series metadata matching keys in [values].
  final List<ChartSeries> series;

  /// Card title shown above the chart.
  final String title;

  /// Optional subtitle shown below the title.
  final String? description;

  /// Label shown in the center of the radial chart.
  final String centerLabel;

  /// Optional footer heading below the chart.
  final String? footerTitle;

  /// Optional footer body text below the chart.
  final String? footerDescription;

  /// Embedded chart theme override.
  final ShadcnChartTheme? theme;

  @override
  ShadcnChartType get type => ShadcnChartType.radialStacked;

  @override
  Map<String, Object?> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (footerTitle != null) 'footerTitle': footerTitle,
        if (footerDescription != null) 'footerDescription': footerDescription,
        if (theme != null) 'theme': theme!.value,
        'centerLabel': centerLabel,
        'series': series.map((item) => item.toJson()).toList(),
        'data': [values],
      };
}

Map<String, Object?> _cartesianTimeJson({
  required String title,
  required String? description,
  required String valueLabel,
  required List<TimeSeriesPoint> data,
  required List<ChartSeries> series,
  String? activeSeriesKey,
  ShadcnChartTheme? theme,
}) {
  return {
    'title': title,
    if (description != null) 'description': description,
    if (theme != null) 'theme': theme.value,
    'valueLabel': valueLabel,
    'xKey': 'date',
    'xType': 'date',
    if (activeSeriesKey != null) 'activeSeries': activeSeriesKey,
    'series': series.map((item) => item.toJson()).toList(),
    'data': data.map((item) => item.toJson()).toList(),
  };
}

Map<String, Object?> _pieJson({
  required String title,
  required String? description,
  required List<PieChartSegment> segments,
  String? footerTitle,
  String? footerDescription,
  ShadcnChartTheme? theme,
}) {
  return {
    'title': title,
    if (description != null) 'description': description,
    if (footerTitle != null) 'footerTitle': footerTitle,
    if (footerDescription != null) 'footerDescription': footerDescription,
    if (theme != null) 'theme': theme.value,
    'nameKey': 'name',
    'valueKey': 'value',
    'segments': segments.map((item) => item._seriesJson).toList(),
    'data': segments.map((item) => item._datumJson).toList(),
  };
}

String _dateOnly(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
