"use client"

import * as React from "react"
import { Bar, BarChart, CartesianGrid, XAxis } from "recharts"

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart"
import { useFlutterChart } from "@/lib/flutter-bridge"
import {
  CartesianChartPayload,
  chartConfigWithValue,
} from "@/types/chart-data"

const defaultPayload: CartesianChartPayload = {
  title: "Bar Chart - Interactive",
  description: "Showing total visitors for the last 3 months",
  valueLabel: "Page Views",
  xKey: "date",
  xType: "date",
  activeSeries: "desktop",
  series: [
    { key: "desktop", label: "Desktop" },
    { key: "mobile", label: "Mobile" },
  ],
  data: [
    { date: "2024-06-01", desktop: 178, mobile: 200 },
    { date: "2024-06-05", desktop: 294, mobile: 250 },
    { date: "2024-06-10", desktop: 155, mobile: 200 },
    { date: "2024-06-15", desktop: 307, mobile: 350 },
    { date: "2024-06-20", desktop: 408, mobile: 450 },
    { date: "2024-06-30", desktop: 446, mobile: 400 },
  ],
}

export default function BarInteractive() {
  const payload = useFlutterChart(defaultPayload)
  const firstSeries = payload.series[0]?.key ?? ""
  const [selectedSeries, setSelectedSeries] = React.useState(
    payload.activeSeries ?? firstSeries,
  )
  const activeSeries = payload.series.some((item) => item.key === selectedSeries)
    ? selectedSeries
    : firstSeries
  const chartConfig = chartConfigWithValue(
    "views",
    payload.valueLabel ?? "Value",
    payload.series,
    payload.colors,
  ) as ChartConfig

  React.useEffect(() => {
    setSelectedSeries(payload.activeSeries ?? firstSeries)
  }, [payload.activeSeries, firstSeries])

  const total = React.useMemo(
    () =>
      Object.fromEntries(
        payload.series.map((series) => [
          series.key,
          payload.data.reduce((acc, item) => acc + Number(item[series.key] ?? 0), 0),
        ]),
      ),
    [payload.data, payload.series],
  )

  return (
    <Card>
      <CardHeader className="flex flex-col items-stretch space-y-0 border-b p-0 sm:flex-row">
        {payload.title || payload.description ? (
          <div className="flex flex-1 flex-col justify-center gap-1 px-6 py-3 sm:py-4">
            {payload.title ? <CardTitle>{payload.title}</CardTitle> : null}
            {payload.description ? (
              <CardDescription>{payload.description}</CardDescription>
            ) : null}
          </div>
        ) : null}
        <div className="flex">
          {payload.series.map((series) => (
            <button
              key={series.key}
              data-active={activeSeries === series.key}
              className="relative z-30 flex flex-1 flex-col justify-center gap-1 border-t px-4 py-3 text-left even:border-l data-[active=true]:bg-muted/50 sm:border-l sm:border-t-0 sm:px-6 sm:py-4"
              onClick={() => setSelectedSeries(series.key)}
            >
              <span className="text-xs text-muted-foreground">{series.label}</span>
              <span className="text-lg font-bold leading-none sm:text-2xl">
                {(total[series.key] ?? 0).toLocaleString()}
              </span>
            </button>
          ))}
        </div>
      </CardHeader>
      <CardContent className="px-2 py-3 sm:p-4">
        <ChartContainer config={chartConfig}>
          <BarChart accessibilityLayer data={payload.data} margin={{ left: 12, right: 12 }}>
            <CartesianGrid vertical={false} />
            <XAxis
              dataKey={payload.xKey}
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              minTickGap={32}
              tickFormatter={(value) => {
                if (payload.xType !== "date") return String(value)
                return new Date(value).toLocaleDateString("en-US", {
                  month: "short",
                  day: "numeric",
                })
              }}
            />
            <ChartTooltip
              content={
                <ChartTooltipContent
                  className="w-[150px]"
                  nameKey="views"
                  labelFormatter={(value) => {
                    if (payload.xType !== "date") return String(value)
                    return new Date(String(value)).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                      year: "numeric",
                    })
                  }}
                />
              }
            />
            <Bar dataKey={activeSeries} fill={`var(--color-${activeSeries})`} />
          </BarChart>
        </ChartContainer>
      </CardContent>
    </Card>
  )
}
