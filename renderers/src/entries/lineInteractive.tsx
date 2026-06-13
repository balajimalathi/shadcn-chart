import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { ThemeProvider } from "@/components/theme-provider";
import LineInteractive from '@/components/charts/LineInteractive';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme">
      <LineInteractive />
    </ThemeProvider>
  </StrictMode>
);