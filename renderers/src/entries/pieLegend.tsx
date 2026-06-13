import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import PieLegend from '@/components/charts/PieLegend';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <PieLegend />
  </StrictMode>
);