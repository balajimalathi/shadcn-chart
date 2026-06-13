import type { BaseChartPayload } from "@/types/chart-data"

export const optionalTextPayloadFields = [
  "title",
  "description",
  "footerTitle",
  "footerDescription",
] as const

export function mergeChartPayload<T extends BaseChartPayload>(
  current: T,
  parsed: Partial<T>,
): T {
  const merged = { ...current, ...parsed } as T

  for (const field of optionalTextPayloadFields) {
    if (!Object.prototype.hasOwnProperty.call(parsed, field)) {
      delete (merged as Record<string, unknown>)[field]
    }
  }

  return merged
}

export function parseBridgePayload<T>(newData: string | Partial<T>): Partial<T> {
  if (typeof newData === "string") {
    return JSON.parse(newData) as Partial<T>
  }

  return newData
}

export type PayloadListener = (data: Record<string, unknown>) => void

export function createChartBridge() {
  let pendingPayload: Record<string, unknown> | null = null
  const listeners = new Set<PayloadListener>()

  const applyPayload = (newData: string | Record<string, unknown>) => {
    const parsed = parseBridgePayload<Record<string, unknown>>(newData)
    if (listeners.size === 0) {
      pendingPayload = mergeChartPayload(
        (pendingPayload ?? {}) as BaseChartPayload,
        parsed as Partial<BaseChartPayload>,
      ) as Record<string, unknown>
      return
    }
    listeners.forEach((listener) => listener(parsed))
  }

  const subscribe = (listener: PayloadListener) => {
    listeners.add(listener)
    if (pendingPayload) {
      listener(pendingPayload)
      pendingPayload = null
    }
    return () => {
      listeners.delete(listener)
    }
  }

  const consumePendingPayload = () => {
    const payload = pendingPayload
    pendingPayload = null
    return payload
  }

  const applyEarlyPayloads = (payloads: Record<string, unknown>[]) => {
    for (const payload of payloads) {
      applyPayload(payload)
    }
  }

  return {
    applyPayload,
    applyEarlyPayloads,
    consumePendingPayload,
    subscribe,
    getPendingPayload: () => pendingPayload,
  }
}
