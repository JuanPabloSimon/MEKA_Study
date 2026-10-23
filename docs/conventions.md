# Convenciones — MEKA

## TypeScript

- `strict: true` y `noUncheckedIndexedAccess: true`. Prohibido `any`, `@ts-ignore` y `@ts-expect-error` sin justificación en comentario y aprobación de la review.
- Tipos explícitos en las firmas públicas de cada módulo; los internos pueden inferirse.
- Preferir `type` para uniones y datos, `interface` para contratos que se implementan.
- Datos inmutables por defecto: `readonly`, `as const`, sin mutar argumentos.

## Nombres

| Elemento | Convención | Ejemplo |
|---|---|---|
| Archivos de módulo | `kebab-case.ts` | `normalize-text.ts` |
| Componentes React | `PascalCase.tsx` | `PracticeScreen.tsx` |
| Funciones y variables | `camelCase` | `computeAccuracy` |
| Tipos e interfaces | `PascalCase` | `TypingSession` |
| Constantes de módulo | `UPPER_SNAKE_CASE` | `MAX_TEXT_LENGTH` |
| Nombre de feature (en specs y tests) | `snake_case` | `typing_engine` |

Los identificadores del código van en **inglés**; los textos de interfaz, comentarios de negocio y documentación van en **español**.

## Estructura de archivos

- Un módulo, una responsabilidad. Cada carpeta de `src/` expone su API pública en un `index.ts`; se importa desde ahí y no desde archivos internos.
- Los tests unitarios viven junto al módulo: `normalize-text.ts` ↔ `normalize-text.test.ts`.
- Los tests e2e viven en `e2e/` y se llaman `<feature>.spec.ts`.
- Funciones cortas (guía: menos de 40 líneas). Si necesitas un comentario para explicar un bloque, extrae una función con un buen nombre.

## Manejo de errores

- Errores esperados (entrada inválida, archivo ilegible) → resultado tipado o error con nombre; se muestran al usuario con un mensaje claro.
- Errores inesperados → no se tragan en silencio: se registran y la interfaz se recupera.
- Nunca `catch {}` vacío.

## Tests

- Framework: Vitest (unitarios y de componentes) y Playwright (e2e).
- **Título de cada test:** `[<feature> R<n>] descripción en español`. Ejemplo: `it("[typing_engine R2] registra un error si la entrada no coincide", …)`.
- Los tests son **deterministas**: sin `setTimeout` reales, sin depender de la hora ni del azar; el tiempo se inyecta.
- Un test comprueba una cosa. Preferir pocos tests significativos a muchos triviales.
- Prohibido `it.skip`, `it.only` y `test.only` en lo que se entrega.

## Interfaz y textos

- Español rioplatense, **trato de vos** (*"Pegá tu texto"*, *"Empezá a practicar"*), tono claro, cercano y preciso, según `docs/design.md`.
- Primera palabra con inicial en mayúscula; signos de exclamación solo cuando corresponde.
- Los textos viven en `src/ui/strings.ts`, no repartidos por los componentes.
- Estilos desde los tokens de `docs/design.md`; botones e inputs con radio `0px`. Los valores de color y espaciado no se escriben "a mano" en los componentes: se usan variables.

## Commits

Mensajes en español, en imperativo y con el id de la feature: `F02: agrega estado de sesión del motor de tipeo`. Un commit por tarea `T<n>` cuando sea posible.
