import type { ReactElement } from "react";
import { STRINGS } from "./strings";

export function App(): ReactElement {
  return (
    <main>
      <h1>{STRINGS.brandName}</h1>
      <p>{STRINGS.tagline}</p>
    </main>
  );
}
