import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import RadialStacked from '@/components/charts/RadialStacked';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <RadialStacked />
  </StrictMode>
);
