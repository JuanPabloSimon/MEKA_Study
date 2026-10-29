# Requisitos — project_scaffold

- **Feature:** F01 — Andamiaje del repositorio y puerta de verificación
- **Scope:** app
- **Estado:** spec_ready

## Contexto

Adaptación del andamiaje base de Vite + React + TypeScript estricto a la arquitectura por capas de MEKA (`docs/architecture.md`), convenciones de código (`docs/conventions.md`), tokens del sistema de diseño (`docs/design.md`) y flujo de verificación automatizada (`docs/verification.md` e `init.sh`).

## Requisitos

- **R1.** El sistema DEBE definir en `package.json` los scripts `lint`, `typecheck`, `test`, `build` y `verify` (donde `verify` ejecuta en secuencia `lint`, `typecheck`, `test` y `build`), y configurar Vite en `vite.config.ts` con `base: "/"` para despliegue en la raíz del dominio.
- **R2.** El sistema DEBE exigir en la configuración de TypeScript (`tsconfig.app.json` y `tsconfig.node.json`) las opciones `strict: true` y `noUncheckedIndexedAccess: true`.
- **R3.** El sistema DEBE organizar `src/` en las cinco capas de `docs/architecture.md` (`src/engine/`, `src/metrics/`, `src/text/`, `src/storage/` y `src/ui/`), cada una con su archivo público `index.ts`, y las capas puras (`engine`, `metrics`, `text`) NO DEBEN importar desde `ui`, `storage`, `react` ni APIs del DOM.
- **R4.** El sistema DEBE centralizar los textos visibles iniciales en `src/ui/strings.ts` en español rioplatense (`es-AR`), exponiendo el nombre de marca `"MEKA"` y el lema `"Estudia de manera práctica"` según `docs/design.md`.
- **R5.** El sistema DEBE declarar en `:root` las variables CSS globales correspondientes a todos los tokens definidos en `docs/design.md` —colores (`--color-text: #F9F0F1`, `--color-background: #003052`, `--color-border: #000000`, `--color-primary: #D4F4DD`, `--color-secondary: #748CAB`, `--color-error: #9E1A30`), tipografías (`--font-heading` con `Basic`, `--font-body` con `Montserrat`, `--font-mono` con `Roboto Mono` en pesos `300, 400, 500, 600`), espaciado (`--space-base: 8px`, `--space-md: 16px`, `--space-lg: 32px`) y radio (`--radius-none: 0px`)— y cargar dichas fuentes en `index.html` con `<html lang="es-AR">`.
- **R6.** CUANDO se monta el componente raíz `App` en el entorno de pruebas de componentes (Vitest + Testing Library), el sistema DEBE renderizar el título `"MEKA"` y el lema `"Estudia de manera práctica"` provenientes de `src/ui/strings.ts`.
- **R7.** CUANDO el usuario abre la aplicación en el navegador (Playwright e2e), el sistema DEBE mostrar la pantalla inicial con el encabezado `"MEKA"` y el lema `"Estudia de manera práctica"`, aplicando el color de fondo `#003052` (`--color-background`) y el color de texto `#F9F0F1` (`--color-text`).

## Cobertura de criterios de `acceptance`

| Criterio de `feature_list.json` | Requisitos |
|---|---|
| `npm run lint`, `typecheck`, `test`, `build` y `verify` existen y terminan en verde sobre el proyecto vacío | R1, R2 |
| Existe al menos un test unitario de humo y un test e2e de humo que pasan | R6, R7 |
| La estructura de carpetas de `src/` coincide con `docs/architecture.md` | R3, R4 |
| Las fuentes de `docs/design.md` (`Basic`, `Montserrat`, `Roboto Mono`) y los tokens de color/espaciado están disponibles como variables globales de estilo | R5, R7 |
| `./init.sh` termina en verde y ya no muestra la advertencia de "sin scaffold" | R1, R6 |

## Fuera de alcance

- Lógica del motor de tipeo (`F02`), cálculo de métricas (`F03`), normalización de texto (`F04`), pantalla interactiva de práctica (`F05`) e historial (`F06`).
- Definición de colores o componentes de las secciones aún sin completar de `docs/design.md` (color de carácter correcto, cursor, foco o texto sobre botón primario).

## Preguntas abiertas

- **P1.** ¿Dónde se publicará la app (para decidir si hace falta configuración de base path)? — *Impacto: R1 (`base` en `vite.config.ts`).* **Resuelta por el humano:** raíz del dominio — Vercel, Netlify, Cloudflare Pages o dominio propio (`base: "/"`).
