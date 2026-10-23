# Especificaciones (SDD) — MEKA

En este proyecto **la spec va antes que el código**. La spec es el contrato entre el humano, el `spec_author`, el `implementer` y el `reviewer`.

## Ciclo de vida de una feature

```
pending ──► spec_ready ──► in_progress ──► done
   │            │               │
   └────────────┴───────────────┴──► blocked (con blocked_reason)
```

| Estado | Significa | Quién lo cambia |
|---|---|---|
| `pending` | Sin spec todavía | — |
| `spec_ready` | `spec_author` entregó los tres archivos; esperando revisión humana | leader |
| `in_progress` | El humano **aprobó** la spec; se está implementando y revisando | leader (registra `approved_at`) |
| `done` | Review aprobada e `init.sh` en verde | leader |
| `blocked` | No puede avanzar; se anota `blocked_reason` | leader |

**Puerta humana:** el paso `spec_ready → in_progress` requiere aprobación explícita de una persona. `init.sh` verifica que toda feature `in_progress` o `done` tenga `approved_at`.

## Estructura de una spec

`specs/<scope>/<name>/` contiene:

1. **`requirements.md`** — *qué* se debe cumplir. Requisitos EARS `R1…Rn`, fuera de alcance y preguntas abiertas.
2. **`design.md`** — *cómo*. Enfoque técnico, archivos, contratos, **una alternativa descartada**, riesgos.
3. **`tasks.md`** — *en qué orden*. Tareas `T1…Tn`, cada una con `cubre: R…` y los tests esperados.

Plantillas de ejemplo en `docs/examples/`.

## Notación EARS

Cada requisito sigue una de estas plantillas, en español:

| Tipo | Plantilla | Ejemplo MEKA |
|---|---|---|
| Ubicuo | El sistema DEBE `<respuesta>` | El sistema DEBE mantener el cursor dentro de los límites del texto objetivo. |
| Por evento | CUANDO `<evento>`, el sistema DEBE `<respuesta>` | CUANDO el usuario ingresa un carácter distinto del esperado, el sistema DEBE registrar un error en esa posición. |
| Por estado | MIENTRAS `<estado>`, el sistema DEBE `<respuesta>` | MIENTRAS la sesión está terminada, el sistema DEBE ignorar las nuevas entradas. |
| Opcional | DONDE `<característica>`, el sistema DEBE `<respuesta>` | DONDE la política de tipografía es "reemplazar", el sistema DEBE convertir las comillas curvas en comillas rectas. |
| No deseado | SI `<condición no deseada>`, ENTONCES el sistema DEBE `<respuesta>` | SI el texto está vacío, ENTONCES el sistema DEBE rechazarlo con un mensaje claro. |

Reglas de un buen requisito: **atómico** (una sola cosa), **verificable** (se puede escribir un test), **sin ambigüedad** (nada de "rápido", "amigable", "adecuado"; usar números y condiciones), **independiente de la implementación**.

## Trazabilidad requisito → tarea → test

- Cada criterio de `acceptance` de `feature_list.json` queda cubierto por al menos un `R<n>`.
- Cada `R<n>` está cubierto por al menos una tarea `T<n>` y al menos un test.
- Cada test cita sus requisitos en el título con el formato **`[<feature> R<n>]`** (varios: `[<feature> R1, R3]`).
- `init.sh` comprueba automáticamente que toda feature `done` tiene un test por cada `R<n>` de su `requirements.md`.

## Preguntas abiertas

Todo lo ambiguo va a la sección **Preguntas abiertas** de `requirements.md` con su impacto. Las resuelve el humano, no el `spec_author`. Una spec con preguntas que bloquean requisitos esenciales no se aprueba hasta resolverlas.

## Cambios de spec durante la implementación

El `implementer` **no edita la spec**. Si encuentra un error u omisión, lo documenta en su informe y el leader lo escala al humano. Si el humano aprueba el cambio, se relanza al `spec_author` y la feature vuelve a pasar por aprobación.

## Features que tocan interfaz

El `design.md` de la spec referencia los tokens de `docs/design.md` que usa. Lo que ese documento no define (hoy: *Componentes y patrones*, *Guardarraíles*, colores de estado correcto/cursor/foco, color de texto sobre el botón primario) se registra como pregunta abierta y **no se inventa**.
