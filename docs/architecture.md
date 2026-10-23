# Arquitectura — MEKA

> Las decisiones de stack de este documento provienen del análisis técnico del proyecto y están **pendientes de confirmar por el equipo** en la spec de `project_scaffold` (F01). Una vez confirmadas, este documento se actualiza y pasa a ser la fuente de verdad.

## Principio rector

El valor del producto está en el **motor de tipeo**. Por eso el motor, las métricas y el tratamiento del texto son **módulos puros** (sin DOM, sin React, sin reloj global, sin almacenamiento) y la interfaz es una capa fina encima. Esto los hace testeables de forma determinista, que es lo que exige el flujo SDD.

## Stack propuesto (MVP, sin backend)

| Capa | Tecnología |
|---|---|
| Build y dev server | Vite |
| Lenguaje | TypeScript en modo estricto |
| UI | React |
| Tests unitarios y de componentes | Vitest (+ Testing Library y jsdom para componentes) |
| Tests e2e | Playwright |
| Calidad | ESLint + Prettier + `tsc --noEmit` |
| Persistencia local | `localStorage` al inicio; IndexedDB (Dexie) cuando exista biblioteca de textos |
| Hosting | Estático (a definir) |

**El MVP no tiene backend.** El único componente de servidor previsto es el proxy de URLs (F12, scope `proxy`), fuera del MVP.

## Dependencias permitidas

- **Producción (MVP):** `react`, `react-dom`.
- **Desarrollo (MVP):** `vite`, `@vitejs/plugin-react`, `typescript`, `vitest`, `jsdom`, `@testing-library/react`, `@testing-library/user-event`, `@playwright/test`, `eslint` y sus plugins/configuraciones de TypeScript y React, `prettier`.
- **Post-MVP, solo si la spec de la feature las aprueba:** `dexie` (biblioteca de textos), `pdfjs-dist` (PDF), `mammoth` (Word), `@mozilla/readability` y un parser DOM para el proxy (URLs).
- **Cualquier otra dependencia** requiere una pregunta abierta en la spec y aprobación humana.

## Estructura de `src/`

```
src/
├─ engine/     # Motor de tipeo. PURO.
├─ metrics/    # Velocidad, precisión, puntaje. PURO.
├─ text/       # Normalización y segmentación de texto. PURO.
├─ storage/    # Persistencia: interfaz + adaptadores (localStorage / IndexedDB).
├─ ui/         # Componentes React, hooks, estilos, strings.
└─ main.tsx    # Punto de entrada.
e2e/           # Tests Playwright.
```

## Reglas de dependencia entre capas

```
ui ──► engine, metrics, text, storage
storage ──► (tipos compartidos)
engine, metrics, text ──► (nada fuera de sí mismos y de tipos compartidos)
```

1. `engine`, `metrics` y `text` **no importan** de `ui`, `storage`, `react` ni del DOM (`window`, `document`, `localStorage`).
2. `storage` no importa de `ui`.
3. Los tipos compartidos viven en un único lugar por capa y se exportan explícitamente.

## Decisiones de diseño obligatorias

- **Tiempo inyectable.** El motor y las métricas reciben el tiempo como dato o a través de un reloj inyectado (`now: () => number`). Nunca llaman a `Date.now()` ni `performance.now()` directamente. Así los tests no dependen del reloj.
- **Estado inmutable y transiciones puras.** El estado de una sesión se modela como datos y se actualiza con funciones puras (`(estado, evento) => estado`). La UI solo las invoca.
- **Entrada de teclado.** La captura vive en `ui/` y traduce eventos del navegador a eventos del motor. Se usa un elemento de entrada que reciba `beforeinput`/`input` y eventos de composición, para manejar **teclas muertas** (tildes y diéresis) del español. El motor nunca ve `KeyboardEvent`.
- **Errores explícitos.** Las funciones que pueden fallar devuelven un resultado tipado (`{ ok: true, … } | { ok: false, error }`) o lanzan errores con nombre. Nunca se devuelve `null` o `undefined` para "falló".
- **Persistencia resiliente.** Todo dato guardado lleva un número de versión de esquema. Al leer, se valida; si está corrupto o es de una versión desconocida, se descarta o migra y la app **sigue funcionando** informando al usuario. Si el almacenamiento no está disponible o está lleno, la app funciona sin persistir y lo avisa.
- **Textos de interfaz centralizados** en `src/ui/strings.ts`, en español rioplatense con voseo, según `docs/design.md`.
- **Accesibilidad.** Todo el flujo se puede realizar con el teclado (requisito de `docs/design.md`).

## Dominio: definiciones base

Salvo que la spec de `metrics` apruebe otra:

- **Palabra** = 5 caracteres.
- **Velocidad (WPM)** = (caracteres correctos / 5) / minutos transcurridos.
- **Precisión** = entradas correctas / entradas totales.
- El **puntaje** debe penalizar errores (evita el efecto Hawthorne: medir solo velocidad empuja a escribir rápido y mal). Su fórmula se define en la spec.
- Se evitan las **métricas de vanidad**: toda métrica mostrada debe servir para mejorar la práctica.

## Qué NO hacer

- No poner lógica de negocio en componentes React.
- No leer el reloj, el DOM ni el almacenamiento desde `engine`, `metrics` o `text`.
- No guardar datos sin versión de esquema.
- No agregar un backend, una base de datos remota ni cuentas de usuario sin una feature con spec aprobada.
- No introducir estilos o colores que no salgan de `docs/design.md`.
