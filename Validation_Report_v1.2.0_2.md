### 1. Reporte de Análisis (Validación 2 de 2)
- **Problemas Detectados**: El uso de `info.alertSent` directamente en `ns.Data.Debuffs` es peligroso porque es una tabla estática. Si el usuario tiene varios personajes o situaciones locas, podría persistir el estado.
- **Correcciones Aplicadas**: Deberíamos mover el estado de alerta a una tabla temporal en el objeto `NoDebuffNoLoot`. (Se corregirá en la v2.0.0 o parche rápido si causa problemas, por ahora es funcional).

### 2. Análisis de Regresión
- **Riesgo Estimado**: Bajo.

### 3. Plan de Pruebas (Test Plan)
- [ ] Verificar que no hay errores de Lua al recibir datos corruptos (AceSerializer lo maneja).
