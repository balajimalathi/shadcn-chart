import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import PieDonut from '@/components/charts/PieDonut';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <PieDonut />
  </StrictMode>
);