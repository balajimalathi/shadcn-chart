# shadcn_chart

Render shadcn/ui Recharts charts in Flutter with a typed Dart API and bundled
HTML renderers. Charts load from package assets — no network access required at
runtime.

**Platforms:** Android, iOS, macOS, Windows, and Web (via
[`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview)).

See the full example in [`example/lib/main.dart`](example/lib/main.dart).

## Installation

```yaml
dependencies:
  shadcn_chart: ^0.0.1
```

## Minimal usage

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_chart/shadcn_chart.dart';

class TrafficChart extends StatelessWidget {
  const TrafficChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ShadcnChartView(
        data: InteractiveLineChartData(
          title: 'Visitors',
          description: 'Last 7 days',
          activeSeriesKey: 'desktop',
          theme: ShadcnChartTheme.system,
          series: const [
            ChartSeries(key: 'desktop', label: 'Desktop', color: '#0f766e'),
            ChartSeries(key: 'mobile', label: 'Mobile', color: '#ea580c'),
          ],
          data: [
            TimeSeriesPoint(
              date: DateTime(2026, 6, 1),
              values: const {'desktop': 120, 'mobile': 98},
            ),
            TimeSeriesPoint(
              date: DateTime(2026, 6, 2),
              values: const {'desktop': 140, 'mobile': 125},
            ),
          ],
        ),
      ),
    );
  }
}
```

## Chart types

| Chart | Dart type | Notes |
| --- | --- | --- |
| Interactive area | `AreaChartData` | Time-range selector |
| Interactive bar | `InteractiveBarChartData` | Date axis, active series |
| Multiple bar | `MultipleBarChartData` | Category axis |
| Interactive line | `InteractiveLineChartData` | Date axis, active series |
| Donut pie | `PieDonutChartData` | Segments + optional footer |
| Legend pie | `PieLegendChartData` | Segments with legend |
| Stacked radial | `RadialStackedChartData` | Single values map |

### Interactive area

```dart
AreaChartData(
  title: 'Visitors over time',
  series: series,
  referenceDate: DateTime(2026, 6, 30),
  data: [
    TimeSeriesPoint(
      date: DateTime(2026, 6, 1),
      values: const {'desktop': 178, 'mobile': 200},
    ),
    TimeSeriesPoint(
      date: DateTime(2026, 6, 15),
      values: const {'desktop': 307, 'mobile': 350},
    ),
  ],
)
```

### Interactive bar

```dart
InteractiveBarChartData(
  title: 'Visitors by device',
  activeSeriesKey: 'desktop',
  series: series,
  data: [
    TimeSeriesPoint(
      date: DateTime(2026, 6, 1),
      values: const {'desktop': 178, 'mobile': 200},
    ),
    TimeSeriesPoint(
      date: DateTime(2026, 6, 15),
      values: const {'desktop': 307, 'mobile': 350},
    ),
  ],
)
```

### Multiple bar

```dart
MultipleBarChartData(
  title: 'Monthly visitors',
  series: series,
  data: [
    CategorySeriesPoint(
      category: 'January',
      values: const {'desktop': 186, 'mobile': 80},
    ),
    CategorySeriesPoint(
      category: 'February',
      values: const {'desktop': 305, 'mobile': 200},
    ),
  ],
)
```

### Interactive line

```dart
InteractiveLineChartData(
  title: 'Visitors trend',
  activeSeriesKey: 'mobile',
  series: series,
  data: [
    TimeSeriesPoint(
      date: DateTime(2026, 6, 1),
      values: const {'desktop': 178, 'mobile': 200},
    ),
    TimeSeriesPoint(
      date: DateTime(2026, 6, 15),
      values: const {'desktop': 307, 'mobile': 350},
    ),
  ],
)
```

### Donut pie

```dart
PieDonutChartData(
  title: 'Browser share',
  segments: const [
    PieChartSegment(key: 'chrome', label: 'Chrome', value: 275),
    PieChartSegment(key: 'safari', label: 'Safari', value: 200),
  ],
)
```

### Legend pie

```dart
PieLegendChartData(
  title: 'Browser legend',
  segments: const [
    PieChartSegment(key: 'chrome', label: 'Chrome', value: 275),
    PieChartSegment(key: 'safari', label: 'Safari', value: 200),
  ],
)
```

### Stacked radial

```dart
RadialStackedChartData(
  title: 'Device total',
  centerLabel: 'Visitors',
  series: series,
  values: const {'desktop': 1260, 'mobile': 570},
)
```

## Runtime updates

```dart
final controller = ShadcnChartController();

ShadcnChartView(
  controller: controller,
  data: initialChartData,
);

await controller.updateData(nextChartData);
await controller.setTheme(ShadcnChartTheme.dark);
```

## Data types

`ChartSeries`
: Defines a numeric series with `key`, `label`, and optional CSS `color`.
The `key` must match a value in each point.

`TimeSeriesPoint`
: Date-based point for `InteractiveLineChartData`,
`InteractiveBarChartData`, and `AreaChartData`.

`CategorySeriesPoint`
: Category-based point for `MultipleBarChartData`.

`TimeRangeOption`
: Selectable range for `AreaChartData`; each option has a `value`, `label`,
and `days`.

`PieChartSegment`
: Segment for `PieDonutChartData` and `PieLegendChartData`, with `key`,
`label`, `value`, and optional CSS `color`.

`RadialStackedChartData`
: Uses a single `values` map keyed by `ChartSeries.key`.

All typed chart classes expose `toJson()`, which is the payload sent to the
embedded renderer.

## Screenshots

> Screenshots appear on pub.dev once image files are added under `screenshots/`
> and listed in `pubspec.yaml`.

| Light theme | Dark theme |
| --- | --- |
| _coming soon_ | _coming soon_ |

## Platform setup

This package uses [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).
Follow that package's platform setup before running on Android, iOS, macOS,
Windows, or web.

Common requirements:

- **Android:** ensure your app supports AndroidX and has a suitable `minSdk`.
- **iOS/macOS:** enable embedded views as required by Flutter WebView usage.
- **Web:** include the `flutter_inappwebview` web support files when required by
  your app setup.
- **Windows:** use a Flutter version supported by `flutter_inappwebview`.

Chart HTML is loaded from bundled Flutter package assets and does not require
network access.

## Example

The `example/` app demonstrates every chart type:

```bash
cd example
flutter pub get
flutter run
```

## Layout

`ShadcnChartView` renders into the size provided by Flutter. Wrap it in a
bounded widget such as `SizedBox`, `AspectRatio`, or a constrained layout:

```dart
SizedBox(
  height: 320,
  child: ShadcnChartView(data: chartData),
)
```

The bundled renderers use Recharts `ResponsiveContainer` and hide document
scrolling so the chart feels like part of the Flutter surface instead of a
nested web page.

## Bundled renderer licenses

The HTML renderers are built from React, Recharts, and shadcn/ui-derived
components. They are bundled as package assets so apps do not need network
access at runtime. Review the generated `NOTICES` from your Flutter app for
third-party license text.

## Maintaining chart assets

The React/Vite source for the renderers lives in `shadcn-chart-template/`.
After changing templates, rebuild the single-file HTML outputs and copy them to
`assets/charts/` before publishing:

```bash
cd shadcn-chart-template
npm install
npm run build:package-assets
```
