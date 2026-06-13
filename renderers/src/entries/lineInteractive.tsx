import '../index.css' 

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import LineInteractive from '@/components/charts/LineInteractive';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <LineInteractive />
  </StrictMode>
);