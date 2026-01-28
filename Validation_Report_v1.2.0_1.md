### 1. Reporte de Análisis (Validación 1 de 2)
- **Problemas Detectados**: Revisión de `Assignments.lua`. El prefijo `NDNL_SYNC` debe estar registrado en el `.toc` o inicializado correctamente. AceComm necesita que el addon herede de `AceComm-3.0` (ya lo hace).
- **Correcciones Aplicadas**: Se verificó la herencia en `Core.lua`. Se añadió el comando `/ndnlsync` para forzar la sincronización manual.

### 2. Análisis de Regresión
- **Componentes Afectados**: `Assignments.lua`, `Core.lua`.
- **Riesgo Estimado**: Medio. La comunicación entre clientes siempre tiene riesgos de lag o desincronización si no se maneja bien.

### 3. Plan de Pruebas (Test Plan)
#### Pruebas Funcionales
- [ ] **Caso 1**: Estar en grupo y cambiar una asignación. Verificar que aparece el mensaje "Configuración enviada".
- [ ] **Caso 2**: (Teórico) Otro jugador con el addon debería recibir la tabla.
- [ ] **Caso 3**: Dejar que un debuff propio expire. Verificar mensaje en `UIErrorsFrame`.

#### Pruebas de Regresión
- [ ] Verificar que el HUD sigue funcionando sin estar en grupo.
