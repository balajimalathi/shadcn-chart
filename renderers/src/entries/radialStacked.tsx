import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import RadialStacked from '@/components/charts/RadialStacked';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <RadialStacked />
    </ThemeProvider>
  </StrictMode>
);
