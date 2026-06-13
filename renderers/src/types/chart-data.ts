export type ChartValue = string | number

export type ChartDatum = Record<string, ChartValue>

export interface ChartSeries {
  key: string
  label: string
  color?: string
}

export interface TimeRangeOption {
  value: string
  label: string
  days: number
}

export interface BaseChartPayload {
  title?: string
  description?: string
  footerTitle?: string
  footerDescription?: string
  colors?: string[]
}

export interface CartesianChartPayload extends BaseChartPayload {
  data: ChartDatum[]
  series: ChartSeries[]
  xKey: string
  xType?: "date" | "category"
  activeSeries?: string
  valueLabel?: string
  defaultTimeRange?: string
  referenceDate?: string
  timeRanges?: TimeRangeOption[]
}

export interface PieChartPayload extends BaseChartPayload {
  data: ChartDatum[]
  segments: ChartSeries[]
  nameKey: string
  valueKey: string
}

export interface RadialChartPayload extends BaseChartPayload {
  data: ChartDatum[]
  series: ChartSeries[]
  centerLabel?: string
}

export function chartConfigFromSeries(series: ChartSeries[], colors?: string[]) {
  return Object.fromEntries(
    series.map((item, index) => [
      item.key,
      {
        label: item.label,
        color:
          item.color ??
          colors?.[index] ??
          `var(--chart-${(index % 5) + 1})`,
      },
    ]),
  )
}

export function chartConfigWithValue(
  valueKey: string,
  valueLabel: string,
  series: ChartSeries[],
  colors?: string[],
) {
  return {
    [valueKey]: { label: valueLabel },
    ...chartConfigFromSeries(series, colors),
  }
}
