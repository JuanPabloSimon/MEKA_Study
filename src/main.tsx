import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./ui";
import "./ui/styles/tokens.css";

const rootElement = document.getElementById("root");
if (!rootElement) {
  throw new Error("Root element #root not found in document");
}

createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
