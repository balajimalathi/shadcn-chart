# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Restored separate bundled HTML assets per chart type after unified runtime loading
  issues in WebView.

## [0.2.0] - 2026-06-14

### Added

- Unified chart runtime asset (`chart-runtime.html`) shared by all chart types,
  selected at load time via a `data-page` placeholder.

### Changed

- Replaced seven duplicate bundled HTML assets (~4.5 MB) with one unified runtime
  (~750 KB).
- Chart data updates now compare serialized payloads instead of object identity.
- Consolidated color serialization helpers and card metadata JSON builders.
- Removed web platform support from declared platforms and runtime code paths.
- Package version bumped to 0.2.0.

### Fixed

- `ShadcnChartController.attach` now awaits pending script flush before load-stop
  handlers run theme and data updates.
- Auto-created controllers are detached when their `ShadcnChartView` disposes.

## [0.1.0] - 2026-06-14

### Added

- Early payload support so chart data and host theme are applied before the React
  bundle finishes loading (URL fragment encoding, bridge stub, and
  `flutter-bridge-core` with unit tests).
- VS Code launch configurations for the example app (debug, profile, and release).
- Android and iOS platform scaffolding for the example app
  (`com.skndan.flutter_chart`).
- Light and dark theme pub.dev screenshots from the Android example app.

### Changed

- README and bundled chart HTML updated for color and theme consistency with the
  host Flutter `Theme`.
- `ShadcnChartView`, `ShadcnChartController`, and chart models updated for the
  new bridge and loading flow.
- Renderer bridge refactored; host theme is applied via CSS variables instead of
  a standalone React theme provider.
- Regenerated all seven bundled chart HTML assets under `assets/charts/`.
- Example app layout and chart HTML module loading improved for React module
  preload compatibility.

### Fixed

- First Dart payload no longer lost when the WebView loads before
  `window.updateChartData` is available.
- Android example builds pin AGP to 8.11.1 for compatibility with
  `flutter_inappwebview_android` 1.1.3.

## [0.0.2] - 2026-06-13

### Fixed

- README preview image on pub.dev now uses an absolute GitHub URL (relative paths
  are not rendered in pub.dev READMEs).

### Changed

- Declare supported platforms (Android, iOS, macOS, Windows, Web) in
  `pubspec.yaml` for accurate pub.dev platform scoring.
- Complete dartdoc on serialization helpers and chart type extensions.

## [0.0.1] - 2026-06-13

### Added

- Seven bundled shadcn/Recharts chart renderers (area, bar, line, pie, radial).
- Typed Dart models (`InteractiveLineChartData`, `AreaChartData`, etc.).
- `ShadcnChartView` widget and `ShadcnChartController` for runtime updates.
- Example app demonstrating every chart type.
