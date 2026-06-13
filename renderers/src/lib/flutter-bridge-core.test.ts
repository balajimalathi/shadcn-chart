import { describe, expect, it } from "vitest"
import {
  createChartBridge,
  mergeChartPayload,
  parseEncodedBridgePayload,
  parseBridgePayload,
} from "./flutter-bridge-core"

describe("parseBridgePayload", () => {
  it("parses JSON strings", () => {
    expect(parseBridgePayload('{"title":"Visitors trend"}')).toEqual({
      title: "Visitors trend",
    })
  })
})

describe("parseEncodedBridgePayload", () => {
  it("parses base64-encoded JSON", () => {
    const encodedPayload = btoa(
      JSON.stringify({
        title: "Visitors trend",
        description: "Interactive line chart",
      }),
    )

    expect(parseEncodedBridgePayload(encodedPayload)).toEqual({
      title: "Visitors trend",
      description: "Interactive line chart",
    })
  })

  it("parses URL-safe base64 JSON without padding", () => {
    const encodedPayload = btoa(JSON.stringify({ title: "Visitors trend" }))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "")

    expect(parseEncodedBridgePayload(encodedPayload)).toEqual({
      title: "Visitors trend",
    })
  })

  it("parses percent-encoded JSON", () => {
    const encodedPayload = encodeURIComponent(
      JSON.stringify({ title: "Visitors trend" }),
    )

    expect(parseEncodedBridgePayload(encodedPayload)).toEqual({
      title: "Visitors trend",
    })
  })
})

describe("createChartBridge", () => {
  it("queues payload until a listener subscribes", () => {
    const bridge = createChartBridge()
    bridge.applyPayload({
      title: "Visitors trend",
      description: "Interactive line chart",
    })

    const received: Record<string, unknown>[] = []
    bridge.subscribe((data) => received.push(data))

    expect(received).toEqual([
      { title: "Visitors trend", description: "Interactive line chart" },
    ])
    expect(bridge.getPendingPayload()).toBeNull()
  })

  it("delivers payload immediately when listener already exists", () => {
    const bridge = createChartBridge()
    const received: Record<string, unknown>[] = []
    bridge.subscribe((data) => received.push(data))

    bridge.applyPayload({ title: "Monthly visitors" })

    expect(received).toEqual([{ title: "Monthly visitors" }])
  })

  it("merges payloads queued before subscribe via applyEarlyPayloads", () => {
    const bridge = createChartBridge()
    bridge.applyEarlyPayloads([
      {
        title: "Visitors trend",
        description: "Interactive line chart",
        data: [{ date: "2026-06-01", desktop: 120 }],
      },
    ])

    const received: Record<string, unknown>[] = []
    bridge.subscribe((data) => received.push(data))

    expect(received).toEqual([
      {
        title: "Visitors trend",
        description: "Interactive line chart",
        data: [{ date: "2026-06-01", desktop: 120 }],
      },
    ])
  })

  it("consumes queued payload exactly once for synchronous initialization", () => {
    const bridge = createChartBridge()
    bridge.applyPayload({
      title: "Visitors trend",
      description: "Interactive line chart",
    })

    expect(bridge.consumePendingPayload()).toEqual({
      title: "Visitors trend",
      description: "Interactive line chart",
    })
    expect(bridge.consumePendingPayload()).toBeNull()

    const received: Record<string, unknown>[] = []
    bridge.subscribe((data) => received.push(data))

    expect(received).toEqual([])
  })
})

describe("mergeChartPayload", () => {
  it("clears optional text fields omitted from Flutter payload", () => {
    const current = {
      title: "Bar Chart - Interactive",
      description: "Showing total visitors for the last 3 months",
      data: [{ date: "2024-06-01", desktop: 178 }],
    }

    const merged = mergeChartPayload(current, {
      data: [{ date: "2026-06-01", desktop: 999, mobile: 888 }],
      series: [
        { key: "desktop", label: "Desktop" },
        { key: "mobile", label: "Mobile" },
      ],
    } as unknown as Partial<typeof current>)

    expect(merged.title).toBeUndefined()
    expect(merged.description).toBeUndefined()
    expect(merged.data).toEqual([
      { date: "2026-06-01", desktop: 999, mobile: 888 },
    ])
  })

  it("keeps optional text fields when Flutter payload includes them", () => {
    const current = {
      title: "Bar Chart - Interactive",
      description: "Default description",
      data: [],
    }

    const merged = mergeChartPayload(current, {
      title: "Visitors by device",
      description: "Interactive bar chart",
    })

    expect(merged.title).toBe("Visitors by device")
    expect(merged.description).toBe("Interactive bar chart")
  })

  it("applies early payload over renderer defaults before first render", () => {
    const defaults = {
      title: "Line Chart - Interactive",
      description: "Showing total visitors for the last 3 months",
      data: [{ date: "2024-06-01", desktop: 178 }],
    }

    const bridge = createChartBridge()
    bridge.applyEarlyPayloads([
      {
        title: "Visitors trend",
        description: "Interactive line chart with selectable series",
        data: [{ date: "2026-06-01", desktop: 178, mobile: 200 }],
      },
    ])

    const pendingPayload = bridge.consumePendingPayload()
    expect(pendingPayload).not.toBeNull()

    const initialPayload = mergeChartPayload(
      defaults,
      pendingPayload as Partial<typeof defaults>,
    )

    expect(initialPayload.title).toBe("Visitors trend")
    expect(initialPayload.description).toBe(
      "Interactive line chart with selectable series",
    )
    expect(initialPayload.data).toEqual([
      { date: "2026-06-01", desktop: 178, mobile: 200 },
    ])
  })
})
