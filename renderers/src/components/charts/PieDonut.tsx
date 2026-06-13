"use client"

import { TrendingUp } from "lucide-react"
import { Pie, PieChart } from "recharts"

import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
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
import { chartConfigWithValue, PieChartPayload } from "@/types/chart-data"
import { useTheme } from "../theme-provider"

const defaultPayload: PieChartPayload = {
  title: "Pie Chart - Donut",
  description: "January - June 2024",
  footerTitle: "Trending up by 5.2% this month",
  footerDescription: "Showing total visitors for the last 6 months",
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

export default function PieDonut() {
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
            <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />
            <Pie data={chartData} dataKey={payload.valueKey} nameKey={payload.nameKey} innerRadius="45%" outerRadius="80%" />
          </PieChart>
        </ChartContainer>
      </CardContent>
      {(payload.footerTitle || payload.footerDescription) ? (
        <CardFooter className="flex-col gap-2 text-sm">
          {payload.footerTitle ? (
            <div className="flex items-center gap-2 font-medium leading-none">
              {payload.footerTitle} <TrendingUp className="h-4 w-4" />
            </div>
          ) : null}
          {payload.footerDescription ? (
            <div className="leading-none text-muted-foreground">
              {payload.footerDescription}
            </div>
          ) : null}
        </CardFooter>
      ) : null}
    </Card>
  )
}
