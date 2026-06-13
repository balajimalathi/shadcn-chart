"use client"

import * as React from "react"
import { Area, AreaChart, CartesianGrid, XAxis } from "recharts"

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
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useFlutterChart } from "@/lib/flutter-bridge"
import {
  CartesianChartPayload,
  chartConfigWithValue,
} from "@/types/chart-data"

const defaultPayload: CartesianChartPayload = {
  title: "Area Chart - Interactive",
  description: "Showing total visitors for the last 3 months",
  valueLabel: "Visitors",
  xKey: "date",
  xType: "date",
  defaultTimeRange: "90d",
  referenceDate: "2024-06-30",
  timeRanges: [
    { value: "90d", label: "Last 3 months", days: 90 },
    { value: "30d", label: "Last 30 days", days: 30 },
    { value: "7d", label: "Last 7 days", days: 7 },
  ],
  series: [
    { key: "desktop", label: "Desktop" },
    { key: "mobile", label: "Mobile" },
  ],
  data: [
    { date: "2024-04-01", desktop: 222, mobile: 150 },
    { date: "2024-05-01", desktop: 165, mobile: 220 },
    { date: "2024-05-15", desktop: 473, mobile: 380 },
    { date: "2024-06-01", desktop: 178, mobile: 200 },
    { date: "2024-06-15", desktop: 307, mobile: 350 },
    { date: "2024-06-30", desktop: 446, mobile: 400 },
  ],
}

export default function AreaInteractive() {
  const payload = useFlutterChart(defaultPayload)
  const [timeRange, setTimeRange] = React.useState(
    payload.defaultTimeRange ?? payload.timeRanges?.[0]?.value ?? "all",
  )
  const chartConfig = chartConfigWithValue(
    "visitors",
    payload.valueLabel ?? "Value",
    payload.series,
    payload.colors,
  ) as ChartConfig

  React.useEffect(() => {
    setTimeRange(payload.defaultTimeRange ?? payload.timeRanges?.[0]?.value ?? "all")
  }, [payload.defaultTimeRange, payload.timeRanges])

  const selectedRange = payload.timeRanges?.find((item) => item.value === timeRange)
  const filteredData = React.useMemo(() => {
    if (!selectedRange || payload.xType !== "date") return payload.data
    const referenceDate = new Date(
      payload.referenceDate ?? String(payload.data[payload.data.length - 1]?.[payload.xKey]),
    )
    const startDate = new Date(referenceDate)
    startDate.setDate(startDate.getDate() - selectedRange.days)
    return payload.data.filter((item) => new Date(String(item[payload.xKey])) >= startDate)
  }, [payload, selectedRange])

  return (
    <Card>
      {payload.title || payload.description || payload.timeRanges?.length ? (
        <CardHeader className="flex items-center gap-2 space-y-0 border-b py-3 sm:flex-row">
          {payload.title || payload.description ? (
            <div className="grid flex-1 gap-1 text-left">
              {payload.title ? <CardTitle>{payload.title}</CardTitle> : null}
              {payload.description ? (
                <CardDescription>{payload.description}</CardDescription>
              ) : null}
            </div>
          ) : null}
          {payload.timeRanges?.length ? (
            <Select value={timeRange} onValueChange={setTimeRange}>
              <SelectTrigger className="w-[160px] rounded-lg sm:ml-auto" aria-label="Select a value">
                <SelectValue placeholder={payload.timeRanges[0]?.label} />
              </SelectTrigger>
              <SelectContent className="rounded-xl">
                {payload.timeRanges.map((range) => (
                  <SelectItem key={range.value} value={range.value} className="rounded-lg">
                    {range.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          ) : null}
        </CardHeader>
      ) : null}
      <CardContent className="px-2 py-3 sm:px-4">
        <ChartContainer config={chartConfig}>
          <AreaChart data={filteredData}>
            <defs>
              {payload.series.map((series) => (
                <linearGradient
                  key={series.key}
                  id={`fill-${series.key}`}
                  x1="0"
                  y1="0"
                  x2="0"
                  y2="1"
                >
                  <stop offset="5%" stopColor={`var(--color-${series.key})`} stopOpacity={0.8} />
                  <stop offset="95%" stopColor={`var(--color-${series.key})`} stopOpacity={0.1} />
                </linearGradient>
              ))}
            </defs>
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
              cursor={false}
              content={
                <ChartTooltipContent
                  labelFormatter={(value) => {
                    if (payload.xType !== "date") return String(value)
                    return new Date(String(value)).toLocaleDateString("en-US", {
                      month: "short",
                      day: "numeric",
                    })
                  }}
                  indicator="dot"
                />
              }
            />
            {payload.series.map((series) => (
              <Area
                key={series.key}
                dataKey={series.key}
                type="natural"
                fill={`url(#fill-${series.key})`}
                stroke={`var(--color-${series.key})`}
                stackId="a"
              />
            ))}
            <ChartLegend content={<ChartLegendContent />} />
          </AreaChart>
        </ChartContainer>
      </CardContent>
    </Card>
  )
}
