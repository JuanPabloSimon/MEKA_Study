# CHECKPOINTS.md — Puntos de control

Antes de dar una feature por cerrada, el leader recorre estos puntos. Cada uno tiene una verificación concreta, no una opinión.

| # | Punto de control | Cómo se verifica |
|---|---|---|
| **C1** | **Alcance**: la feature cumple lo que pide `feature_list.json` y nada más | El reviewer compara el diff contra `requirements.md` y `acceptance` |
| **C2** | **Spec**: existe, está aprobada y no cambió durante la implementación sin pasar por el humano | `approved_at` en `feature_list.json`; `git diff` de `specs/` sin cambios no autorizados |
| **C3** | **Trazabilidad**: cada `R<n>` tiene al menos un test `[<feature> R<n>]` y cada tarea `T<n>` cubre algún `R<n>` | `./init.sh` (paso de trazabilidad) |
| **C4** | **Verificación automática**: lint, tipos, tests y build en verde | `npm run verify` dentro de `./init.sh` |
| **C5** | **Las cuatro R** (Riesgo, Legibilidad, Fiabilidad, Resiliencia) revisadas | Informe del reviewer en `progress/review_*.md` |
| **C6** | **Estado y memoria**: `feature_list.json`, `progress/current.md` e `history.md` actualizados | Lectura del leader |
| **C7** | **Motor de tipeo y texto en español** (solo features que tocan teclado, normalización o métricas): teclas muertas, tildes, ñ, ¿ ¡ y caracteres tipográficos cubiertos | Tests unitarios específicos + checklist manual en el informe del implementer (ver `docs/verification.md`) |

**Regla:** si un punto falla, la feature vuelve a `in_progress` o se marca `blocked` con el motivo. No se "cierra con deuda" en silencio.
