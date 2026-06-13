import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import BarInteractive from "@/components/charts/BarInteractive";

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BarInteractive />
  </StrictMode>
);