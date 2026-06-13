import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import AreaInteractive from '@/components/charts/AreaInteractive';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <AreaInteractive />
    </ThemeProvider>
  </StrictMode>
);