import { useEffect, useState } from "react"
import type { BaseChartPayload } from "@/types/chart-data"
import { createChartBridge, mergeChartPayload } from "./flutter-bridge-core"

type HostThemePayload = Record<string, string>

type BridgeWindow<T> = Window &
  typeof globalThis & {
    updateChartData?: (newData: string | Partial<T>) => void
    setChartOptions?: (newData: string | Partial<T>) => void
    setHostTheme?: (theme: string | HostThemePayload) => void
  }

const hostThemeVariables: Record<string, string> = {
  background: "--background",
  foreground: "--foreground",
  card: "--card",
  cardForeground: "--card-foreground",
  popover: "--popover",
  popoverForeground: "--popover-foreground",
  primary: "--primary",
  primaryForeground: "--primary-foreground",
  secondary: "--secondary",
  secondaryForeground: "--secondary-foreground",
  muted: "--muted",
  mutedForeground: "--muted-foreground",
  accent: "--accent",
  accentForeground: "--accent-foreground",
  destructive: "--destructive",
  border: "--border",
  input: "--input",
  ring: "--ring",
  chart1: "--chart-1",
  chart2: "--chart-2",
  chart3: "--chart-3",
  chart4: "--chart-4",
  chart5: "--chart-5",
}

function applyHostTheme(newTheme: string | HostThemePayload) {
  const theme =
    typeof newTheme === "string"
      ? (JSON.parse(newTheme) as HostThemePayload)
      : newTheme
  const root = document.documentElement

  root.classList.toggle("dark", theme.brightness === "dark")
  root.classList.toggle("light", theme.brightness === "light")

  for (const [key, variable] of Object.entries(hostThemeVariables)) {
    const value = theme[key]
    if (value) {
      root.style.setProperty(variable, value)
    }
  }
}

function canScrollLocally(event: WheelEvent) {
  const target = event.target

  if (!(target instanceof Element)) {
    return false
  }

  const deltaY = event.deltaY
  const deltaX = event.deltaX

  for (let element: Element | null = target; element; element = element.parentElement) {
    const style = window.getComputedStyle(element)
    const canScrollY =
      /(auto|scroll)/.test(style.overflowY) &&
      element.scrollHeight > element.clientHeight &&
      ((deltaY < 0 && element.scrollTop > 0) ||
        (deltaY > 0 &&
          element.scrollTop + element.clientHeight < element.scrollHeight))
    const canScrollX =
      /(auto|scroll)/.test(style.overflowX) &&
      element.scrollWidth > element.clientWidth &&
      ((deltaX < 0 && element.scrollLeft > 0) ||
        (deltaX > 0 &&
          element.scrollLeft + element.clientWidth < element.scrollWidth))

    if (canScrollY || canScrollX) {
      return true
    }

    if (element === document.body || element === document.documentElement) {
      break
    }
  }

  return false
}

function forwardWheelToParent(event: WheelEvent) {
  if (window.parent === window || canScrollLocally(event)) {
    return
  }

  const frameRect = window.frameElement?.getBoundingClientRect()
  const forwardedEvent = new WheelEvent("wheel", {
    bubbles: true,
    cancelable: true,
    composed: true,
    deltaX: event.deltaX,
    deltaY: event.deltaY,
    deltaZ: event.deltaZ,
    deltaMode: event.deltaMode,
    clientX: event.clientX + (frameRect?.left ?? 0),
    clientY: event.clientY + (frameRect?.top ?? 0),
    screenX: event.screenX,
    screenY: event.screenY,
    ctrlKey: event.ctrlKey,
    shiftKey: event.shiftKey,
    altKey: event.altKey,
    metaKey: event.metaKey,
  })

  const target =
    window.parent.document.elementFromPoint(
      forwardedEvent.clientX,
      forwardedEvent.clientY,
    ) ?? window.parent.document

  event.preventDefault()
  target.dispatchEvent(forwardedEvent)
}

type EarlyBridgeWindow = Window & {
  __chartBridgeEarlyPayloads?: Record<string, unknown>[]
  __chartBridgeEarlyThemes?: HostThemePayload[]
}

const chartBridge = createChartBridge()
let pendingTheme: HostThemePayload | null = null

function drainEarlyBridgeCalls() {
  const earlyWindow = window as EarlyBridgeWindow
  const earlyPayloads = earlyWindow.__chartBridgeEarlyPayloads ?? []
  delete earlyWindow.__chartBridgeEarlyPayloads
  chartBridge.applyEarlyPayloads(earlyPayloads)

  const earlyThemes = earlyWindow.__chartBridgeEarlyThemes ?? []
  delete earlyWindow.__chartBridgeEarlyThemes
  const latestTheme = earlyThemes.at(-1)
  if (latestTheme) {
    applyHostTheme(latestTheme)
    pendingTheme = latestTheme
  }
}

function installBridge() {
  drainEarlyBridgeCalls()

  const bridgeWindow = window as BridgeWindow<unknown>

  bridgeWindow.updateChartData = (newData) => {
    try {
      chartBridge.applyPayload(newData as string | Record<string, unknown>)
    } catch (error) {
      console.error("Invalid chart JSON from Flutter:", newData)
      console.error(error)
    }
  }
  bridgeWindow.setChartOptions = bridgeWindow.updateChartData
  bridgeWindow.setHostTheme = (newTheme) => {
    try {
      const theme =
        typeof newTheme === "string"
          ? (JSON.parse(newTheme) as HostThemePayload)
          : newTheme
      applyHostTheme(theme)
      pendingTheme = theme
    } catch (error) {
      console.error("Invalid host theme from Flutter:", newTheme)
      console.error(error)
    }
  }
}

installBridge()

export function useFlutterChart<T extends BaseChartPayload>(defaults: T) {
  const [payload, setPayload] = useState<T>(() => {
    const pendingPayload = chartBridge.consumePendingPayload()
    if (!pendingPayload) {
      return defaults
    }

    return mergeChartPayload(defaults, pendingPayload as Partial<T>)
  })

  useEffect(() => {
    if (pendingTheme) {
      applyHostTheme(pendingTheme)
      pendingTheme = null
    }

    return chartBridge.subscribe((parsed) => {
      setPayload((current) => {
        return mergeChartPayload(current, parsed as Partial<T>)
      })
    })
  }, [])

  useEffect(() => {
    window.addEventListener("wheel", forwardWheelToParent, { passive: false })

    return () => {
      window.removeEventListener("wheel", forwardWheelToParent)
    }
  }, [])

  return payload
}
