import { copyFileSync, mkdirSync } from "node:fs"
import { resolve } from "node:path"

const charts = [
  "area-interactive",
  "bar-interactive",
  "bar-multiple",
  "line-interactive",
  "pie-donut",
  "pie-legend",
  "radial-stacked",
]

const templateRoot = resolve(import.meta.dirname, "..")
const packageAssets = resolve(templateRoot, "..", "assets", "charts")

mkdirSync(packageAssets, { recursive: true })

for (const chart of charts) {
  copyFileSync(
    resolve(templateRoot, "dist", chart, "templates", `${chart}.html`),
    resolve(packageAssets, `${chart}.html`),
  )
}

console.log(`Copied ${charts.length} chart assets to ${packageAssets}`)
