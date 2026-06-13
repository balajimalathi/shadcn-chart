import '../index.css'

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import BarMultiple from "@/components/charts/BarMultiple";

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <BarMultiple />
  </StrictMode>
);