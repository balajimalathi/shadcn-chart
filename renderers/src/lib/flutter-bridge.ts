import { useEffect, useState } from "react"
import type { BaseChartPayload, ChartTheme } from "@/types/chart-data"
import type { Theme } from "@/components/theme-provider"

type BridgeWindow<T> = Window &
  typeof globalThis & {
    updateChartData?: (newData: string | Partial<T>) => void
    setChartOptions?: (newData: string | Partial<T>) => void
    setTheme?: (newTheme: ChartTheme) => void
  }

function parseBridgePayload<T>(newData: string | Partial<T>): Partial<T> {
  if (typeof newData === "string") {
    return JSON.parse(newData) as Partial<T>
  }

  return newData
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

export function useFlutterChart<T extends BaseChartPayload>(
  defaults: T,
  setTheme: (theme: Theme) => void,
) {
  const [payload, setPayload] = useState<T>(defaults)

  useEffect(() => {
    const bridgeWindow = window as BridgeWindow<T>

    const applyPayload = (newData: string | Partial<T>) => {
      try {
        const parsed = parseBridgePayload<T>(newData)
        setPayload((current) => ({ ...current, ...parsed }))

        if (
          parsed.theme === "dark" ||
          parsed.theme === "light" ||
          parsed.theme === "system"
        ) {
          setTheme(parsed.theme)
        }
      } catch (error) {
        console.error("Invalid chart JSON from Flutter:", newData)
        console.error(error)
      }
    }

    bridgeWindow.updateChartData = applyPayload
    bridgeWindow.setChartOptions = applyPayload
    bridgeWindow.setTheme = (newTheme: ChartTheme) => {
      if (newTheme === "dark" || newTheme === "light" || newTheme === "system") {
        setTheme(newTheme)
      }
    }
  }, [setTheme])

  useEffect(() => {
    window.addEventListener("wheel", forwardWheelToParent, { passive: false })

    return () => {
      window.removeEventListener("wheel", forwardWheelToParent)
    }
  }, [])

  return payload
}
