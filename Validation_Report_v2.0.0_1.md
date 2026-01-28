### 1. Reporte de Análisis (Validación 1 de 2)
- **Problemas Detectados**: Se revisó la carga de Locales en el `.toc`. El orden es correcto (Locales antes que Core).
- **Correcciones Aplicadas**: Se optimizó la tabla `alertStates` en `Core.lua` para que sea local y no contamine el espacio global o la base de datos de debuffs.

### 2. Análisis de Regresión
- **Componentes Afectados**: Todo el sistema de strings (`Core`, `Options`, `Assignments`, `UI`).
- **Riesgo Estimado**: Bajo-Medio. Un error en la clave de un locale podría causar un error de Lua, pero se ha verificado que todas las claves coinciden.

### 3. Plan de Pruebas (Test Plan)
#### Pruebas Funcionales (Lanzamiento Final)
- [ ] **Caso 1**: Verificar que no hay errores de Lua al arrancar (carga de AceLocale).
- [ ] **Caso 2**: Cambiar el idioma del juego (si fuera posible) o verificar que los strings en español cargan correctamente.
- [ ] **Caso 3**: Verificar que las alertas visuales (`UIErrorsFrame`) se muestran correctamente con el texto localizado.

#### Pruebas de Regresión
- [ ] Verificar que el HUD sigue funcionando y las asignaciones se mantienen tras la refactorización.
