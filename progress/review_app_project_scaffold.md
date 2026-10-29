Veredicto: APPROVED

# Revisión — `project_scaffold` (`F01`, scope `app`)

## 1. Verificación ejecutable (`./init.sh` y `npm run test:e2e`)

Ejecutados de forma independiente por el revisor:

### `bash ./init.sh`

```text
== MEKA · init.sh ==
[1/4] Entorno
  ✓ Node v24.19.0
  ✓ npm 12.0.2
[2/4] Archivos base
  ✓ AGENTS.md
  ✓ CHECKPOINTS.md
  ✓ feature_list.json
  ✓ init.sh
  ✓ .antigravity/rules.md
  ✓ .antigravity/agents/leader.md
  ✓ .antigravity/agents/spec_author.md
  ✓ .antigravity/agents/implementer.md
  ✓ .antigravity/agents/reviewer.md
  ✓ docs/architecture.md
  ✓ docs/conventions.md
  ✓ docs/specs.md
  ✓ docs/verification.md
  ✓ docs/design.md
  ✓ progress/current.md
  ✓ progress/history.md
[3/4] Estado, specs y trazabilidad
  ✓ feature_list.json consistente (13 features — in_progress: 1, pending: 12)
    Archivos de test detectados: 2
[4/4] Verificación (lint, tipos, tests, build)
Checking formatting...
All matched files use Prettier code style!

 RUN  v5.0.5 C:/Users/jsimo/Proyectos/meka-study

 ✓ src/ui/App.test.tsx (6 tests) 176ms

 Test Files  1 passed (1)
      Tests  6 passed (6)

vite v8.3.5 building client environment for production...
✓ 18 modules transformed.
dist/index.html                   0.79 kB │ gzip:  0.42 kB
dist/assets/index-BDw4MZFX.css    0.59 kB │ gzip:  0.33 kB
dist/assets/index-qB168rfF.js   219.75 kB │ gzip: 68.70 kB
✓ built in 187ms
  ✓ npm run verify en verde
------------------------------------------
RESULTADO: VERDE — 0 fallas, 0 advertencia(s)
```

### `npm run test:e2e`

```text
Running 1 test using 1 worker

  ok 1 [chromium] › e2e\project_scaffold.spec.ts:3:1 › [project_scaffold R7] muestra la pantalla inicial con MEKA, el lema y los colores de fondo y texto del sistema de diseño (3.4s)

  1 passed (9.1s)
```

## 2. Control de alcance y diff (`git status` / `git diff`)

- Solo se crearon, modificaron o eliminaron archivos justificados por la spec `specs/app/project_scaffold/design.md` y sus tareas `T1..T4`.
- El directorio `specs/` no sufrió modificaciones no autorizadas.
- Se eliminó limpiamente el boilerplate inicial de Vite (`src/App.tsx`, `src/App.css`, `src/index.css`, `src/assets/*`).

## 3. Trazabilidad `R<n>` → Tests y Tareas `T<n>`

| Requisito | Tarea | Test(s) | Archivo | Evaluación |
|---|---|---|---|---|
| **R1** (Scripts `lint`, `typecheck`, `test`, `build`, `verify` en `package.json` y `base: "/"` en `vite.config.ts`) | T1 | `[project_scaffold R1] define los scripts lint, typecheck, test, build y verify en package.json y base '/' en vite.config.ts` | `src/ui/App.test.tsx` | Cubierto y sustantivo: inspecciona `package.json` y `vite.config.ts` reales. |
| **R2** (`strict: true` y `noUncheckedIndexedAccess: true` en `tsconfig.app.json` y `tsconfig.node.json`) | T1 | `[project_scaffold R2] exige strict: true y noUncheckedIndexedAccess: true en tsconfig.app.json y tsconfig.node.json` | `src/ui/App.test.tsx` | Cubierto y sustantivo: parsea ambos archivos `tsconfig*.json` y comprueba ambos flags en `compilerOptions`. |
| **R3** (Cinco capas en `src/` con `index.ts` y aislamiento de capas puras `engine`, `metrics`, `text`) | T2 | `[project_scaffold R3] organiza src/ en las cinco capas con index.ts y mantiene aisladas las capas puras` | `src/ui/App.test.tsx` | Cubierto y sustantivo: verifica la existencia de `index.ts` en cada capa y escanea todos los `.ts/.tsx` de `engine`, `metrics` y `text` contra imports de `ui`/`storage`/`react` y globales del DOM. |
| **R4** (`src/ui/strings.ts` en `es-AR` con `"MEKA"` y `"Estudia de manera práctica"`) | T2 | `[project_scaffold R4] centraliza los textos visibles iniciales en src/ui/strings.ts con marca y lema de MEKA` | `src/ui/App.test.tsx` | Cubierto y sustantivo: comprueba los valores exportados por `STRINGS`. |
| **R5** (Variables CSS `:root` en `tokens.css` y carga de fuentes `Basic`, `Montserrat`, `Roboto Mono` en `index.html` con `lang="es-AR"`) | T3 | `[project_scaffold R5] declara las variables CSS globales en tokens.css y carga las fuentes en index.html con lang='es-AR'` | `src/ui/App.test.tsx` | Cubierto y sustantivo: verifica todos los tokens de color, tipografía, espaciado y radio (`0px`), el atributo `lang="es-AR"` y los pesos `300;400;500;600` en `index.html`. |
| **R6** (Renderizado de `<App />` con título `"MEKA"` y lema `"Estudia de manera práctica"`) | T3 | `[project_scaffold R6] renderiza el título MEKA y el lema 'Estudia de manera práctica' al montar App` | `src/ui/App.test.tsx` | Cubierto y sustantivo: monta `<App />` con Testing Library y verifica el `heading` nivel 1 y el párrafo del lema. |
| **R7** (Pantalla inicial en navegador real con encabezado, lema y colores `#003052` / `#F9F0F1`) | T4 | `[project_scaffold R7] muestra la pantalla inicial con MEKA, el lema y los colores de fondo y texto del sistema de diseño` | `e2e/project_scaffold.spec.ts` | Cubierto y sustantivo: comprueba en Chromium real con Playwright la visibilidad de los textos, las custom properties en `:root` y los estilos computados de `body`. |

Todos los criterios de `acceptance` de `F01` en `feature_list.json` están cumplidos.

## 4. Hallazgos

| # | Severidad | Archivo | Descripción y cambio sugerido |
|---|---|---|---|
| 1 | `mejora` | `.gitignore` | Al ejecutar `npm run test:e2e`, Playwright genera el directorio `test-results/` (y eventualmente `playwright-report/`). Ambos ya están ignorados en `eslint.config.js`, pero conviene agregarlos a `.gitignore` en una próxima iteración para evitar que queden como archivos sin seguimiento tras correr pruebas E2E locales. |

*(0 hallazgos bloqueantes).*

## 5. Evaluación de las cuatro R y Sistema de Diseño

- **Riesgo:** Las dependencias añadidas en `package.json` (`vitest`, `jsdom`, `@testing-library/react`, `@testing-library/user-event`, `@playwright/test`, `prettier`) pertenecen estrictamente a la lista permitida en `docs/architecture.md`. Las pruebas de Vitest y Playwright están correctamente separadas mediante `include`/`exclude` en `vite.config.ts` y `testDir: "./e2e"` en `playwright.config.ts`.
- **Legibilidad:** Código claro, conciso y alineado con `docs/conventions.md`. La estructura de `src/` refleja exactamente las 5 capas de `docs/architecture.md` (`engine`, `metrics`, `text`, `storage`, `ui`), cada una con su `index.ts`.
- **Fiabilidad:** `strict: true` y `noUncheckedIndexedAccess: true` activos en `tsconfig.app.json` y `tsconfig.node.json`. Cero usos de `any`, `@ts-ignore` o `@ts-expect-error`. Tiempos deterministas sin `setTimeout` en tests. `src/main.tsx` valida explícitamente la existencia de `#root`.
- **Resiliencia:** Las variables tipográficas en `src/ui/styles/tokens.css` incluyen familias de respaldo (`sans-serif`, `monospace`) y Google Fonts se carga con `display=swap`, permitiendo que la app funcione sin bloquearse incluso sin conectividad externa.
- **Sistema de diseño (`docs/design.md`):** Se respetaron todos los tokens de color, tipografía (`Basic`, `Montserrat`, `Roboto Mono`), espaciado (`8px`, `16px`, `32px`), radios (`0px` en `button`, `input`, `textarea`) y textos en `es-AR`. No se inventaron tokens ni estilos de las secciones pendientes de `docs/design.md`.
