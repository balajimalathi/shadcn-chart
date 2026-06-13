"use client"

import { Label, PolarRadiusAxis, RadialBar, RadialBarChart } from "recharts"
import { TrendingUp } from "lucide-react"

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
import { chartConfigFromSeries, RadialChartPayload } from "@/types/chart-data"
import { useTheme } from "../theme-provider"

const defaultPayload: RadialChartPayload = {
  title: "Radial Chart - Stacked",
  description: "January - June 2024",
  footerTitle: "Trending up by 5.2% this month",
  footerDescription: "Showing total visitors for the last 6 months",
  centerLabel: "Visitors",
  series: [
    { key: "desktop", label: "Desktop" },
    { key: "mobile", label: "Mobile" },
  ],
  data: [{ month: "january", desktop: 1260, mobile: 570 }],
}

export default function RadialStacked() {
  const { setTheme } = useTheme()
  const payload = useFlutterChart(defaultPayload, setTheme)
  const chartConfig = chartConfigFromSeries(payload.series) as ChartConfig
  const row = payload.data[0] ?? {}
  const total = payload.series.reduce(
    (acc, series) => acc + Number(row[series.key] ?? 0),
    0,
  )

  return (
    <Card className="flex flex-col">
      <CardHeader className="items-center pb-0">
        <CardTitle>{payload.title}</CardTitle>
        {payload.description ? (
          <CardDescription>{payload.description}</CardDescription>
        ) : null}
      </CardHeader>
      <CardContent className="flex min-h-0 flex-1 items-center pb-0">
        <ChartContainer config={chartConfig}>
          <RadialBarChart data={[row]} endAngle={180} innerRadius="55%" outerRadius="90%">
            <ChartTooltip cursor={false} content={<ChartTooltipContent hideLabel />} />
            <PolarRadiusAxis tick={false} tickLine={false} axisLine={false}>
              <Label
                content={({ viewBox }) => {
                  if (viewBox && "cx" in viewBox && "cy" in viewBox) {
                    return (
                      <text x={viewBox.cx} y={viewBox.cy} textAnchor="middle">
                        <tspan
                          x={viewBox.cx}
                          y={(viewBox.cy || 0) - 16}
                          className="fill-foreground text-2xl font-bold"
                        >
                          {total.toLocaleString()}
                        </tspan>
                        <tspan
                          x={viewBox.cx}
                          y={(viewBox.cy || 0) + 4}
                          className="fill-muted-foreground"
                        >
                          {payload.centerLabel ?? "Total"}
                        </tspan>
                      </text>
                    )
                  }
                }}
              />
            </PolarRadiusAxis>
            {payload.series.map((series) => (
              <RadialBar
                key={series.key}
                dataKey={series.key}
                stackId="a"
                cornerRadius={5}
                fill={`var(--color-${series.key})`}
                className="stroke-transparent stroke-2"
              />
            ))}
          </RadialBarChart>
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
