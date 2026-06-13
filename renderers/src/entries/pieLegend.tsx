import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import PieLegend from '@/components/charts/PieLegend';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <PieLegend />
    </ThemeProvider>
  </StrictMode>
);