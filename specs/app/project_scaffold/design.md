# Diseño — project_scaffold

## Enfoque

Adaptar la plantilla inicial de Vite existente en el repositorio para cumplir las reglas de arquitectura (`docs/architecture.md`), convenciones (`docs/conventions.md`), diseño (`docs/design.md`) y verificación (`docs/verification.md`):

1. **Dependencias de desarrollo permitidas (`docs/architecture.md`):**
   - Mantener `react` y `react-dom` como únicas dependencias de producción.
   - Incorporar en `devDependencies` únicamente los paquetes autorizados que faltan en la plantilla inicial: `vitest`, `jsdom`, `@testing-library/react`, `@testing-library/user-event`, `@playwright/test` y `prettier`.
2. **Configuración de compilación, calidad y pruebas:**
   - `vite.config.ts`: definir `base: "/"` (según respuesta a P1) y configurar el bloque `test` de Vitest con entorno `jsdom`, inclusión de `src/**/*.test.{ts,tsx}` y exclusión de `e2e/**` y `node_modules/**`.
   - `tsconfig.app.json` y `tsconfig.node.json`: activar `"strict": true` y `"noUncheckedIndexedAccess": true`.
   - `eslint.config.js` y `.prettierrc.json`: verificar código TypeScript/React en `src/` y `e2e/` e integrar el chequeo de formato en `npm run lint` (`eslint . && prettier --check "src/**/*.{ts,tsx,css}" "e2e/**/*.ts"`).
   - `playwright.config.ts`: apuntar a `testDir: "./e2e"`, levantar el servidor con `npm run dev` en puerto fijo y ejecutar en Chromium headless.
   - `package.json`: exponer los scripts:
     - `"dev": "vite"`
     - `"build": "tsc -b && vite build"`
     - `"typecheck": "tsc -b"`
     - `"lint": "eslint . && prettier --check \"src/**/*.{ts,tsx,css}\" \"e2e/**/*.ts\""`
     - `"test": "vitest run"`
     - `"test:e2e": "playwright test"`
     - `"verify": "npm run lint && npm run typecheck && npm run test && npm run build"`
3. **Estructura de capas en `src/`:**
   - Eliminar el boilerplate de demostración de Vite (`src/App.tsx`, `src/App.css`, `src/index.css`, `src/assets/`).
   - Crear las cinco capas de `docs/architecture.md` con puntos de entrada explícitos (`index.ts`):
     ```ts
     // src/engine/index.ts, src/metrics/index.ts, src/text/index.ts, src/storage/index.ts
     export {};
     ```
   - En `src/ui/`:
     - `src/ui/strings.ts`: objeto inmutable `STRINGS` (`as const`) con `brandName: "MEKA"` y `tagline: "Estudia de manera práctica"`.
     - `src/ui/styles/tokens.css`: variables CSS en `:root` con los tokens exactos de `docs/design.md` y estilos base para `body`, `button`, `input` y `textarea` (radio `0px`, fondo `var(--color-background)`, texto `var(--color-text)`, fuente `var(--font-body)`).
     - `src/ui/App.tsx`: componente funcional mínimo que muestra el encabezado `<h1>{STRINGS.brandName}</h1>` y `<p>{STRINGS.tagline}</p>`.
     - `src/ui/index.ts`: reexporta `App` y `STRINGS`.
4. **Tokens de `docs/design.md` utilizados:**
   - Colores: `--color-text: #F9F0F1`, `--color-background: #003052`, `--color-border: #000000`, `--color-primary: #D4F4DD`, `--color-secondary: #748CAB`, `--color-error: #9E1A30`.
   - Tipografías: `--font-heading: "Basic", sans-serif`, `--font-body: "Montserrat", sans-serif`, `--font-mono: "Roboto Mono", monospace` (pesos `300`, `400`, `500`, `600` cargados desde Google Fonts en `index.html`).
   - Espaciado y bordes: `--space-base: 8px`, `--space-md: 16px`, `--space-lg: 32px`, `--radius-none: 0px`.

## Archivos

| Archivo | Contenido |
|---|---|
| `package.json` | Scripts `dev`, `build`, `lint`, `typecheck`, `test`, `test:e2e`, `verify` y dependencias permitidas |
| `vite.config.ts` | Configuración de Vite (`base: "/"`, plugin React) y Vitest (`environment: "jsdom"`) |
| `tsconfig.app.json` | Opciones estrictas (`strict: true`, `noUncheckedIndexedAccess: true`) para `src/` |
| `tsconfig.node.json` | Opciones estrictas (`strict: true`, `noUncheckedIndexedAccess: true`) para archivos de configuración y `e2e/` |
| `.prettierrc.json` | Configuración de formato consistente |
| `playwright.config.ts` | Configuración de tests e2e en `e2e/` con `webServer` local |
| `index.html` | Documento raíz con `lang="es-AR"`, carga de Google Fonts (`Basic`, `Montserrat`, `Roboto Mono`) y título `MEKA` |
| `src/engine/index.ts` | Punto de entrada público de la capa `engine` |
| `src/metrics/index.ts` | Punto de entrada público de la capa `metrics` |
| `src/text/index.ts` | Punto de entrada público de la capa `text` |
| `src/storage/index.ts` | Punto de entrada público de la capa `storage` |
| `src/ui/strings.ts` | Textos de interfaz en español rioplatense (`STRINGS`) |
| `src/ui/styles/tokens.css` | Variables CSS `:root` y estilos globales base |
| `src/ui/App.tsx` | Componente raíz inicial de MEKA |
| `src/ui/App.test.tsx` | Tests unitarios y de componente `[project_scaffold R1..R6]` |
| `src/ui/index.ts` | API pública de la capa `ui` |
| `src/main.tsx` | Montaje de `App` e importación de `src/ui/styles/tokens.css` |
| `e2e/project_scaffold.spec.ts` | Test e2e de humo con Playwright `[project_scaffold R7]` |

## Alternativa descartada

**Usar CSS-in-JS o Tailwind CSS para definir el sistema de diseño.** Se descartó porque `docs/architecture.md` restringe las dependencias permitidas y exige cero dependencias no listadas sin aprobación humana, además de que las variables CSS nativas (`:root`) cumplen directamente el criterio de aceptación de exponer las fuentes y tokens como variables globales sin sobrecarga de runtime ni compilación adicional.

## Riesgos (cuatro R)

| R | Riesgo | Mitigación |
|---|---|---|
| Riesgo | Que Vitest intente ejecutar los archivos `.spec.ts` de Playwright en `e2e/` y falle | Configurar `include: ["src/**/*.test.{ts,tsx}"]` y `exclude: ["e2e/**", "node_modules/**"]` en `vite.config.ts` |
| Legibilidad | Que queden archivos residuales del boilerplate de Vite mezclados con la arquitectura por capas | Eliminar `src/App.tsx`, `src/App.css`, `src/index.css` y `src/assets/` al mover el componente raíz a `src/ui/App.tsx` |
| Fiabilidad | Que futuras ediciones rompan el aislamiento de capas o desactiven `strict` / `noUncheckedIndexedAccess` | Incluir tests automatizados `[project_scaffold R2]` y `[project_scaffold R3]` que validan `tsconfig*.json` y las fronteras de `src/` en cada corrida |
| Resiliencia | Que la carga de fuentes externas de Google Fonts falle sin conexión en entornos de CI o pruebas locales | Definir familias de respaldo (`sans-serif`, `monospace`) en las variables `--font-*` y usar `display=swap` en la hoja de Google Fonts |
