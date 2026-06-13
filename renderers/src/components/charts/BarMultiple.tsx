"use client"

import { TrendingUp } from "lucide-react"
import { Bar, BarChart, CartesianGrid, XAxis } from "recharts"

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
import {
  CartesianChartPayload,
  chartConfigFromSeries,
} from "@/types/chart-data"
import { useTheme } from "../theme-provider"

const defaultPayload: CartesianChartPayload = {
  title: "Bar Chart - Multiple",
  description: "January - June 2024",
  footerTitle: "Trending up by 5.2% this month",
  footerDescription: "Showing total visitors for the last 6 months",
  xKey: "month",
  xType: "category",
  series: [
    { key: "desktop", label: "Desktop" },
    { key: "mobile", label: "Mobile" },
  ],
  data: [
    { month: "January", desktop: 186, mobile: 80 },
    { month: "February", desktop: 305, mobile: 200 },
    { month: "March", desktop: 237, mobile: 120 },
    { month: "April", desktop: 73, mobile: 190 },
    { month: "May", desktop: 209, mobile: 130 },
    { month: "June", desktop: 214, mobile: 140 },
  ],
}

export default function BarMultiple() {
  const { setTheme } = useTheme()
  const payload = useFlutterChart(defaultPayload, setTheme)
  const chartConfig = chartConfigFromSeries(payload.series) as ChartConfig

  return (
    <Card>
      <CardHeader>
        <CardTitle>{payload.title}</CardTitle>
        {payload.description ? (
          <CardDescription>{payload.description}</CardDescription>
        ) : null}
      </CardHeader>
      <CardContent className="pb-0">
        <ChartContainer config={chartConfig}>
          <BarChart accessibilityLayer data={payload.data}>
            <CartesianGrid vertical={false} />
            <XAxis
              dataKey={payload.xKey}
              tickLine={false}
              tickMargin={10}
              axisLine={false}
              tickFormatter={(value) => String(value).slice(0, 3)}
            />
            <ChartTooltip cursor={false} content={<ChartTooltipContent indicator="dashed" />} />
            {payload.series.map((series) => (
              <Bar
                key={series.key}
                dataKey={series.key}
                fill={`var(--color-${series.key})`}
                radius={4}
              />
            ))}
          </BarChart>
        </ChartContainer>
      </CardContent>
      {(payload.footerTitle || payload.footerDescription) ? (
        <CardFooter className="flex-col items-start gap-2 text-sm">
          {payload.footerTitle ? (
            <div className="flex gap-2 font-medium leading-none">
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
