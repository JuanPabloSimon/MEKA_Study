# Tareas — typing_engine (EJEMPLO ilustrativo)

- **T1.** Definir tipos y `EmptyTargetError`. — *cubre: R8*
  - Tests: `[typing_engine R8]` creación con texto vacío devuelve error.
- **T2.** Implementar `createSession` con normalización NFC. — *cubre: R1, R7*
  - Tests: `[typing_engine R1]` estado inicial; `[typing_engine R7]` "á" compuesta y descompuesta son equivalentes.
- **T3.** Implementar `applyInput` para entradas correctas. — *cubre: R2, R6*
  - Tests: `[typing_engine R2]` avanza el cursor; `[typing_engine R6]` la primera entrada fija `startedAt` y pasa a `running`.
- **T4.** Implementar el manejo de errores de tipeo. — *cubre: R3*
  - Tests: `[typing_engine R3]` registra el error y el cursor no avanza.
- **T5.** Implementar el fin de sesión. — *cubre: R4, R5*
  - Tests: `[typing_engine R4]` pasa a `finished` al llegar al final; `[typing_engine R5]` las entradas posteriores no cambian el estado.
- **T6.** Garantizar el determinismo. — *cubre: R9*
  - Tests: `[typing_engine R9]` el resultado solo depende de los argumentos (misma secuencia → mismo estado, con relojes simulados distintos) y no existe referencia a `Date.now`/`performance.now` en `src/engine/`.
