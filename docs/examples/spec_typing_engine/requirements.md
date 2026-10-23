# Requisitos — typing_engine (EJEMPLO ilustrativo)

- **Feature:** F02 — Motor de tipeo
- **Scope:** app
- **Estado:** borrador

## Contexto

M�dulo puro que mantiene el estado de una sesión de tipeo a partir de un texto objetivo y una secuencia de entradas. No conoce el DOM, React ni el reloj.

## Requisitos

- **R1.** CUANDO se crea una sesión con un texto objetivo no vacío, el sistema DEBE iniciar con el cursor en la posición 0, cero entradas y estado `idle`.
- **R2.** CUANDO el usuario ingresa un carácter igual al esperado en la posición del cursor, el sistema DEBE registrar la entrada como correcta y avanzar el cursor una posición.
- **R3.** CUANDO el usuario ingresa un carácter distinto del esperado, el sistema DEBE registrar un error en esa posición y NO DEBE avanzar el cursor. *(ilustra la respuesta "el error bloquea el avance" a la pregunta P1)*
- **R4.** CUANDO el cursor alcanza el final del texto objetivo, el sistema DEBE pasar la sesión al estado `finished`.
- **R5.** MIENTRAS la sesión está en estado `finished`, el sistema DEBE ignorar las nuevas entradas y devolver el mismo estado.
- **R6.** CUANDO se ingresa el primer carácter, el sistema DEBE registrar la marca de inicio con el tiempo provisto por el reloj inyectado y pasar a `running`.
- **R7.** CUANDO el texto objetivo contiene caracteres del español (á, é, í, ó, ú, ü, ñ, ¿, ¡), el sistema DEBE compararlos como un carácter único normalizado (NFC).
- **R8.** SI se crea una sesión con un texto vacío, ENTONCES el sistema DEBE devolver un error `EmptyTargetError` y NO DEBE crear estado.
- **R9.** El sistema NO DEBE leer el reloj global (`Date.now`, `performance.now`): el tiempo se recibe como dato.

## Cobertura de criterios de `acceptance`

| Criterio de `feature_list.json` | Requisitos |
|---|---|
| Expone cursor, correctos, errores y fin | R1, R2, R3, R4 |
| Entrada igual avanza; distinta se registra como error | R2, R3 |
| Determinista, tiempo inyectado | R6, R9 |
| Soporta caracteres del español | R7 |
| Sesión terminada no acepta entradas | R5 |
| Entrada inválida o texto vacío → error explícito | R8 |

## Fuera de alcance

- Captura de eventos de teclado y teclas muertas del navegador (vive en `ui/`).
- Cálculo de velocidad, precisión y puntaje (feature `metrics`).
- Persistencia de la sesión.

## Preguntas abiertas

- **P1.** ¿Un error bloquea el avance o el cursor avanza marcando el error? — *Impacto: R3, y la definición de precisión en `metrics`.* **Resuelta (en este ejemplo): bloquea el avance.**
- **P2.** ¿Se permite Backspace y los errores corregidos cuentan para la precisión? — *Impacto: nuevos requisitos de retroceso.* **Abierta:** hasta que se resuelva, este ejemplo no incluye retroceso.
