import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import AreaInteractive from '@/components/charts/AreaInteractive';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <AreaInteractive />
  </StrictMode>
);