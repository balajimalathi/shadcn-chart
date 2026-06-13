import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import { resolve } from "path"
import tailwindcss from "@tailwindcss/vite"
import { viteSingleFile } from "vite-plugin-singlefile"

const chart = process.env.CHART

if (!chart) {
  throw new Error("Set CHART to the chart slug, for example CHART=bar-interactive")
}

export default defineConfig({
  plugins: [react(), tailwindcss(), viteSingleFile()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "./src"),
    },
  },
  build: {
    outDir: `dist/${chart}`,
    rollupOptions: {
      input: {
        [chart]: resolve(__dirname, `templates/${chart}.html`),
      },
      output: {
        entryFileNames: "[name].js",
      },
    },
  },
})
