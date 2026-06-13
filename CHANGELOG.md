# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
