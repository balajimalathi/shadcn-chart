import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import PieDonut from '@/components/charts/PieDonut';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <PieDonut />
    </ThemeProvider>
  </StrictMode>
);