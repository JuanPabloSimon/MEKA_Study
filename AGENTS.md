# AGENTS.md — MEKA

> Mapa de navegación del repositorio. No es una enciclopedia de reglas: te dice **dónde mirar** y **qué nunca romper**.

## 0. Antes de cualquier tarea

1. Lee `.antigravity/rules.md` y actúa con el rol que indica (por defecto, **leader**).
2. Lee `progress/current.md` para saber en qué quedó la sesión anterior.
3. Corre `./init.sh` para confirmar que el repo está sano antes de tocar nada.

## 1. Qué es MEKA

Aplicación web de estudio (*"Estudia de manera práctica"*) para estudiantes universitarios jóvenes: el usuario pega un texto de estudio y lo **reescribe con el teclado**, practicando mecanografía al tacto (*touch typing*) mientras refuerza la retención de la información. Referencia funcional: Keybr.

- **MVP:** texto plano pegado en un cuadro de texto → motor de tipeo con velocidad, precisión y puntaje en vivo → resultados e historial local.
- **Después del MVP:** subida de TXT, PDF y Word, lectura de URLs (requiere proxy), layouts de teclado, meta diaria.
- **Backlog completo y estado:** `feature_list.json`.

## 2. Mapa del repositorio

| Ruta | Qué hay | Cuándo leerla |
|---|---|---|
| `.antigravity/rules.md` | Rol obligatorio de la sesión | Siempre, al empezar |
| `.antigravity/agents/` | `leader`, `spec_author`, `implementer`, `reviewer`, `security_reviewer` | Si vas a ejercer o lanzar un rol |
| `feature_list.json` | Backlog con estados, dependencias y criterios | Siempre |
| `progress/current.md` | Estado de la sesión en curso | Siempre, al empezar |
| `progress/history.md` | Bitácora de features cerradas | Si necesitas contexto histórico |
| `progress/impl_*.md`, `review_*.md`, `security_*.md` | Informes de subagentes | Los lee quien recibe el relevo |
| `specs/<scope>/<name>/` | `requirements.md`, `design.md`, `tasks.md` de cada feature | Al implementar o revisar esa feature |
| `docs/architecture.md` | Capas, dependencias y límites | Antes de crear o mover código |
| `docs/conventions.md` | Estilo, nombres, errores, tests | Antes de escribir código |
| `docs/specs.md` | Proceso SDD, EARS, trazabilidad | Al escribir o revisar una spec |
| `docs/verification.md` | Niveles de verificación y anti-patrones | Al verificar o revisar |
| `docs/design.md` | Sistema de diseño de MEKA (colores, tipografías, voz) | **Solo si la tarea toca interfaz** |
| `CHECKPOINTS.md` | Puntos de control C1–C7 | Al cerrar una feature |
| `init.sh` | Verificación ejecutable del repo | Al empezar y al cerrar |

## 3. Reglas duras (no negociables)

1. **Una feature `in_progress` por scope.** No arranques otra hasta cerrar la actual.
2. **Sin spec aprobada no hay código.** El flujo es `pending → spec_ready → (aprobación humana) → in_progress → done`.
3. **Nadie edita lo que no le corresponde.** `spec_author` solo escribe en `specs/`; `implementer` solo en código y tests; `reviewer` y `security_reviewer` no editan nada salvo su informe en `progress/`.
4. **Todo requisito tiene un test y todo test cita su requisito** con el formato `[<feature> R<n>]` (ver `docs/specs.md`).
5. **Cero dependencias nuevas sin spec que las apruebe.** La lista permitida está en `docs/architecture.md`.
6. **No infieras decisiones de diseño.** `docs/design.md` tiene secciones sin completar (*Componentes y patrones*, *Guardarraíles*) y no define ciertos colores de estado. Si una feature las necesita, pregunta al humano; no inventes.
7. **Los subagentes escriben a disco y responden en una sola línea** (regla anti-teléfono-descompuesto). Quien recibe el relevo lee el archivo, no el chat.
8. **Los subagentes son asíncronos: se espera su resultado antes de continuar.** Nunca se lanzan dos subagentes de escritura a la vez.
9. **Una feature no está `done` hasta que `./init.sh` termina en verde.**

## 4. Flujo de trabajo (resumen)

```
leader ──► spec_author ──► [APROBACIÓN HUMANA] ──► implementer ──► reviewer ──► (security_reviewer) ──► done
              │                                          ▲              │
              └── preguntas abiertas ► humano            └─ CHANGES_REQUESTED (máx. 2 vueltas, luego escala)
```

Detalle completo en `.antigravity/agents/leader.md` y `docs/specs.md`.

## 5. Cierre de sesión

Antes de terminar, el leader actualiza `progress/current.md` (qué se hizo, qué sigue, bloqueos) y deja `./init.sh` en verde. Si hay cambios sin cerrar, lo anota explícitamente.
