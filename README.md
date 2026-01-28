# NoDebuffNoLoot (TBC)

Addon diseñado para optimizar el rendimiento de las raids en World of Warcraft TBC mediante el rastreo estricto de los debuffs críticos en jefes.

## ¿Qué hace NoDebuffNoLoot?

El addon identifica qué debuffs esenciales (como *Hendedura de armadura* o *Fuego de hadas*) faltan en tu objetivo. A diferencia de otros rastreadores genéricos, **NoDebuffNoLoot** permite asignar cada debuff a un jugador específico de la raid, haciendo que la responsabilidad de mantener el debuff sea clara y visible para todos.

### Información proporcionada por el Addon:
*   **HUD Visual Dinámico**: Un panel flotante que muestra los iconos de los debuffs rastreados.
    *   **Verde**: El debuff está activo y tiene tiempo suficiente (> 5s).
    *   **Amarillo**: El debuff está a punto de expirar (< 5s). ¡Renovación urgente!
    *   **Rojo**: El debuff no está presente en el jefe.
*   **Identificación por Jugador**: El HUD muestra el nombre del jugador asignado junto a cada debuff.
*   **Alertas Críticas**: Si eres el responsable de un debuff y este falta o va a caducar, recibirás un aviso visual en el centro de tu pantalla.

## Comandos de Chat

| Comando | Acción |
| :--- | :--- |
| `/ndnl` | Abre el panel de configuración (Menú de Blizzard). |
| `/ndnlsync` | Fuerza la sincronización manual de las asignaciones con todos los miembros de la raid que usen el addon. |

## Opciones Disponibles

Desde el panel de configuración (`/ndnl`), puedes:
1.  **Habilitar/Deshabilitar el HUD**: Oculta el panel si no lo necesitas.
2.  **Gestionar Asignaciones**: Un listado completo de los debuffs soportados donde puedes escribir el nombre del jugador responsable (ej. "Pepito" para *Sunder Armor*).
3.  **Sincronización Automática**: Al cambiar una asignación estando en grupo, el addon intentará enviar los cambios automáticamente a los demás.

## Debuffs Rastreados por Clase

| Clase | Hechizos Soportados |
| :--- | :--- |
| **Guerrero** | Sunder Armor, Thunder Clap, Demoralizing Shout |
| **Druida** | Faerie Fire, Demoralizing Roar |
| **Hunter** | Hunter's Mark, Scorpid Sting |
| **Paladín** | Judgement of Light, Judgement of Wisdom, Judgement of the Crusader |
| **Warlock** | Curse of Elements, Curse of Recklessness, Curse of Weakness |

## Instalación
1.  Descarga el repositorio.
2.  Copia la carpeta `NoDebuffNoLoot` en tu directorio `Interface/AddOns/`.
3.  Asegúrate de que las librerías en la carpeta `Libs` estén presentes.
