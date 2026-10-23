# Verificación — MEKA

## Comando único

```bash
./init.sh
```

Corre, en orden: entorno → archivos base → estado y consistencia de `feature_list.json` → specs y aprobaciones → trazabilidad → `npm run verify`. Una feature no se cierra con `init.sh` en rojo.

`npm run verify` (definido en F01) ejecuta: `lint` → `typecheck` → `test` → `build`.

## Niveles

| Nivel | Qué prueba | Herramienta | Cuándo es obligatorio |
|---|---|---|---|
| **1. Unitario** | Funciones y módulos puros (`engine`, `metrics`, `text`, `storage`) | Vitest | Siempre |
| **2. Componente** | Comportamiento de componentes React | Vitest + Testing Library | Features con UI |
| **3. e2e** | El flujo principal en un navegador real | Playwright | Features con UI visibles al usuario (al menos un flujo feliz y un caso de error) |
| **4. Trazabilidad** | Cada `R<n>` tiene su test `[<feature> R<n>]` | `init.sh` | Siempre, para features `done` |
| **5. Manual** | Lo que la automatización no cubre bien: teclas muertas reales y tipografía visual | Checklist | Features que tocan teclado, motor o UI de práctica |

## Checklist manual de teclado (C7)

Se completa en el informe del `implementer` con el sistema operativo y el layout usados. Marcar cada ítem como `OK`, `FALLA` o `N/A`.

- [ ] Tildes por tecla muerta: á é í ó ú (minúsculas y mayúsculas).
- [ ] Diéresis: ü.
- [ ] ñ y Ñ.
- [ ] ¿ y ¡.
- [ ] Una tecla muerta seguida de una letra que no admite tilde (por ejemplo `´` + `x`).
- [ ] Tecla muerta seguida de espacio (produce el acento suelto).
- [ ] Backspace sobre un carácter compuesto (según la regla definida en la spec).
- [ ] Texto con comillas y rayas tipográficas según la política de normalización vigente.
- [ ] Pegar texto largo y empezar a escribir sin retrasos perceptibles.

Sistemas sugeridos como mínimo: Windows y macOS con layout español latinoamericano. Si algún sistema no se pudo probar, se anota como `N/A` con el motivo.

## Qué debe contener un buen test

- Nombre que cita el requisito: `[<feature> R<n>] …`.
- Datos de entrada explícitos y el resultado esperado concreto.
- Determinismo: tiempo inyectado, sin esperas reales.
- Casos de borde de la spec: vacío, longitud máxima, caracteres especiales, datos corruptos.

## Anti-patrones (hacen fallar la review)

1. Tests que solo comprueban que "no lanza error".
2. Tests que repiten la implementación para calcular el valor esperado.
3. `skip`, `only`, o umbrales relajados para lograr el verde.
4. Capturas de snapshot enormes que nadie lee.
5. Mocks que reemplazan justo lo que se quería probar.
6. `sleep`/`setTimeout` reales para sincronizar.
7. Probar el motor desde un test de UI en lugar de directamente.
8. Cobertura "de relleno": requisitos con un test que no verifica el requisito.

## Evidencia

Todo lo que no es automático queda registrado en `progress/impl_*.md` (qué se probó, en qué sistema, resultado). Sin evidencia, el `reviewer` lo trata como no verificado.
