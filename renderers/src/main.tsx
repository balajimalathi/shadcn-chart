import './index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import BarInteractive from "@/components/charts/BarInteractive";
import BarMultiple from "@/components/charts/BarMultiple";
import AreaInteractive from "@/components/charts/AreaInteractive";
import LineInteractive from "@/components/charts/LineInteractive";
import PieDonut from "@/components/charts/PieDonut";
import PieLegend from "@/components/charts/PieLegend";
import RadialStacked from "@/components/charts/RadialStacked";

// Find which page to render
const page = document.body.getAttribute('data-page');

const components = {
  "bar_interactive": BarInteractive,
  "bar_multiple": BarMultiple,
  "area_interactive": AreaInteractive,
  "line_interactive": LineInteractive,
  "pie_donut": PieDonut,
  "pie_legend": PieLegend,
  "radial_stacked": RadialStacked,
};

const ComponentToRender = components[page as keyof typeof components];

if (!ComponentToRender) {
  throw new Error(`Unknown page: ${page}`);
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <ComponentToRender />
    </ThemeProvider>
  </StrictMode>
);
