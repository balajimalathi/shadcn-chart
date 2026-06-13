import '../index.css'

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import BarMultiple from "@/components/charts/BarMultiple";

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <BarMultiple />
    </ThemeProvider>
  </StrictMode>
);