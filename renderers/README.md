# shadcn_chart renderer template

React, shadcn/ui, Recharts, and Vite source for the HTML chart renderers shipped
by the Flutter `shadcn_chart` package.

The Flutter package does not publish this template directory. It publishes the
single-file HTML outputs copied to `../assets/charts/`.

## Structure

```text
renderers/
  templates/              # Per-chart HTML shells used by Vite builds
  scripts/copy-assets.mjs # Copies dist HTML into the Flutter package assets
  src/components/charts/  # React chart implementations
  src/entries/            # Per-chart React entrypoints
  vite.chart.config.ts    # Shared single-file build config
  vite.config.ts          # Dev server config
```

## Install

```bash
npm install
```

## Development preview

```bash
npm run dev
```

`index.html` uses `src/main.tsx` and a `body data-page` value to select a chart.
Supported values:

- `area_interactive`
- `bar_interactive`
- `bar_multiple`
- `line_interactive`
- `pie_donut`
- `pie_legend`
- `radial_stacked`

## Build commands

Build every chart into `dist/<chart>/templates/<chart>.html`:

```bash
npm run build:all
```

Build and copy the generated HTML files into the Flutter package assets:

```bash
npm run build:package-assets
```

Build one chart:

```bash
npm run build:bar-interactive
npm run build:area-interactive
npm run build:pie-donut
```

Copy already-built files into `../assets/charts/`:

```bash
npm run copy:assets
```

## Flutter bridge

Each built renderer exposes:

- `window.updateChartData(json)` to replace chart data/options.
- `window.setChartOptions(json)` as an alias for partial option updates.
- `window.setHostTheme(json)` to apply Flutter Material theme colors as CSS variables.

## Before publishing the Flutter package

From this directory:

```bash
npm run build:package-assets
```

From the repository root:

```bash
flutter analyze
flutter test
flutter pub publish --dry-run
```
