### 1. Reporte de Análisis (Validación 2 de 2)
- **Problemas Detectados**: Revisión de `Options.lua`. Se detectó que si el usuario ingresa un nombre con espacios accidentales, la lógica de `ns.Data.Debuffs` podría no emparejar correctamente si se usa como clave.
- **Correcciones Aplicadas**: Se aseguró que la clave de la tabla de opciones sea segura (`gsub("%s+", "")`) pero la asignación en la DB use el nombre de hechizo original.

### 2. Análisis de Regresión
- **Componentes Afectados**: `Options.lua`.
- **Riesgo Estimado**: Muy Bajo.

### 3. Plan de Pruebas (Test Plan)
#### Pruebas Funcionales
- [ ] **Caso 1**: Abrir `/ndnl`.
- [ ] **Caso 2**: Asignar nombre a un debuff.
- [ ] **Caso 3**: Verificar persistencia tras `/reload`.

#### Pruebas de Regresión
- [ ] Verificar que el rastreo en combate no se vio afectado por la carga del nuevo archivo de opciones.
