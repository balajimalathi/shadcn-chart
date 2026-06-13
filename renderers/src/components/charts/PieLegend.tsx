"use client"

import { Pie, PieChart } from "recharts"
import {
  ChartConfig,
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
} from "../ui/chart"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { useFlutterChart } from "@/lib/flutter-bridge"
import { chartConfigWithValue, PieChartPayload } from "@/types/chart-data"
import { useTheme } from "../theme-provider"

const defaultPayload: PieChartPayload = {
  title: "Pie Chart - Legend",
  description: "January - June 2024",
  nameKey: "browser",
  valueKey: "visitors",
  segments: [
    { key: "chrome", label: "Chrome" },
    { key: "safari", label: "Safari" },
    { key: "firefox", label: "Firefox" },
    { key: "edge", label: "Edge" },
    { key: "other", label: "Other" },
  ],
  data: [
    { browser: "chrome", visitors: 275 },
    { browser: "safari", visitors: 200 },
    { browser: "firefox", visitors: 187 },
    { browser: "edge", visitors: 173 },
    { browser: "other", visitors: 90 },
  ],
}

export default function PieLegend() {
  const { setTheme } = useTheme()
  const payload = useFlutterChart(defaultPayload, setTheme)
  const chartConfig = chartConfigWithValue(
    payload.valueKey,
    "Value",
    payload.segments,
  ) as ChartConfig
  const chartData = payload.data.map((item) => ({
    ...item,
    fill: `var(--color-${item[payload.nameKey]})`,
  }))

  return (
    <Card className="flex flex-col">
      <CardHeader className="items-center pb-0">
        <CardTitle>{payload.title}</CardTitle>
        {payload.description ? (
          <CardDescription>{payload.description}</CardDescription>
        ) : null}
      </CardHeader>
      <CardContent className="flex min-h-0 flex-1 pb-0">
        <ChartContainer config={chartConfig}>
          <PieChart>
            <Pie data={chartData} dataKey={payload.valueKey} nameKey={payload.nameKey} />
            <ChartLegend
              content={<ChartLegendContent nameKey={payload.nameKey} />}
              className="-translate-y-2 flex-wrap gap-2 [&>*]:basis-1/4 [&>*]:justify-center"
            />
          </PieChart>
        </ChartContainer>
      </CardContent>
    </Card>
  )
}
