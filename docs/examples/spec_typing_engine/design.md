# Diseño — typing_engine (EJEMPLO ilustrativo)

## Enfoque

Estado inmutable y transiciones puras, en `src/engine/`:

```ts
type SessionStatus = "idle" | "running" | "finished";

interface TypingSession {
  readonly target: string;            // texto objetivo ya normalizado (NFC)
  readonly cursor: number;            // posición esperada
  readonly status: SessionStatus;
  readonly startedAt: number | null;  // marca del reloj inyectado
  readonly entries: readonly Entry[]; // historial de entradas
}

interface Entry {
  readonly position: number;
  readonly typed: string;
  readonly correct: boolean;
  readonly at: number;
}

function createSession(target: string): Result<TypingSession, EmptyTargetError>;
function applyInput(session: TypingSession, typed: string, at: number): TypingSession;
```

- `at` es el tiempo en milisegundos, recibido como parámetro (R9).
- `createSession` normaliza a NFC (R7) y valida que no esté vacío (R8).
- `applyInput` es una función pura: no muta `session` y devuelve un estado nuevo.

## Archivos

| Archivo | Contenido |
|---|---|
| `src/engine/types.ts` | Tipos `TypingSession`, `Entry`, `SessionStatus` |
| `src/engine/errors.ts` | `EmptyTargetError` |
| `src/engine/session.ts` | `createSession`, `applyInput` |
| `src/engine/session.test.ts` | Tests `[typing_engine R<n>]` |
| `src/engine/index.ts` | API pública |

## Alternativa descartada

**Clase `TypingSession` con estado mutable interno.** Se descartó porque dificulta los tests (hay que reconstruir el estado paso a paso), complica el uso desde React (el estado cambia "por debajo") y hace más fácil introducir estados imposibles. Con funciones puras, cada test es una tabla de entradas y salidas.

## Riesgos (cuatro R)

| R | Riesgo | Mitigación |
|---|---|---|
| Riesgo | Que el motor dependa de eventos del navegador | El motor solo recibe cadenas; la traducción de teclas muertas vive en `ui/` |
| Legibilidad | Estado disperso | Un único objeto `TypingSession` y una única función de transición |
| Fiabilidad | Estados imposibles (cursor fuera de rango) | Test de invariante: `0 <= cursor <= target.length` tras cualquier secuencia |
| Resiliencia | Entrada inesperada (cadena vacía, varios caracteres) | `applyInput` ignora entradas vacías y la spec de la UI define el tratamiento de ráfagas |
