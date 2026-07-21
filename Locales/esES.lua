local L = LibStub("AceLocale-3.0"):NewLocale("NoDebuffNoLoot", "esES") or LibStub("AceLocale-3.0"):NewLocale("NoDebuffNoLoot", "esMX")
if not L then return end

L["TRACKER_LOADED"] = "Cargado correctamente. v2.0.0. Escribe /ndnl para configurar."
L["SHOW_HUD"] = "Mostrar HUD"
L["SHOW_HUD_DESC"] = "Muestra u oculta el panel de debuffs."
L["ASSIGNMENTS"] = "Asignaciones"
L["ASSIGNMENTS_DESC"] = "Asigna jugadores a cada debuff crítico para rastrear su presencia en el boss."
L["PLAYER_NAME"] = "Nombre del Jugador"
L["PLAYER_NAME_DESC"] = "Nombre del jugador responsable de este debuff."
L["SYNC_SENT"] = "Configuración enviada a la raid."
L["SYNC_RECEIVED"] = "Configuración recibida de %s."
L["STATUS_ACTIVE"] = "ACTIVO"
L["STATUS_MISSING"] = "FALTA"
L["ALERT_EXPIRE"] = "¡TU DEBUFF EXPIRA: %s!"
L["ALERT_MISSING"] = "¡FALTA TU DEBUFF: %s!"
L["OPT_FILTER_MINE"] = "Solo mis asignaciones"
L["OPT_FILTER_MINE_DESC"] = "Ocultar asignaciones que no son tuyas del HUD"

L["CONFIG_TITLE"] = "NoDebuffNoLoot - Asignaciones"
L["CONFIG_SPELL"] = "Spell ID / Nombre"
L["CONFIG_PRIMARY"] = "Encargado"
L["CONFIG_BACKUP"] = "Suplente"
L["CONFIG_DELAY"] = "Retraso"
L["CONFIG_PRIORITY"] = "Prioridad"
L["CONFIG_ADD_NEW"] = "Añadir Asignación"
L["CONFIG_ANNOUNCE"] = "Anunciar a Raid"
L["ANN_RW_FORMAT"] = "%s - Encargado: %s - Suplente: %s"
L["ANN_WISP_PRIMARY"] = "Estás asignado a %s como PRINCIPAL."
L["ANN_WISP_BACKUP"] = "Estás asignado a %s como SUPLENTE."
L["ANN_REQ_PRIVILEGE"] = "Debes ser Líder o Asistente de banda para anunciar."

L["OPT_ALWAYS_SHOW"] = "Mostrar Siempre el HUD"
L["OPT_ALWAYS_SHOW_DESC"] = "Muestra el marco del HUD incluso sin tener un objetivo válido."
L["OPT_LOCK"] = "Bloquear HUD"
L["OPT_LOCK_DESC"] = "Bloquea el marco del HUD para prevenir que se mueva."
L["OPT_BOSS_ONLY"] = "Solo en Bosses"
L["OPT_BOSS_ONLY_DESC"] = "Solo monitorizar y mostrar alertas de debuffs cuando el objetivo es un Jefe (Nivel Calavera o Boss de Mundo)."
L["OPT_ONLY_MISSING"] = "Mostrar Solo Faltantes"
L["OPT_ONLY_MISSING_DESC"] = "Solo muestra en el HUD las magias que realmente faltan en el objetivo."

L["OPT_ALERTS_HEADER"] = "Alertas y Notificaciones"
L["OPT_CHAT"] = "Alertas de Chat"
L["OPT_CHAT_DESC"] = "Imprime las alertas en la ventana de chat."
L["OPT_SOUND"] = "Efectos de Sonido"
L["OPT_SOUND_DESC"] = "Reproduce sonidos durante alertas críticas."
L["OPT_FLASH"] = "Destello de Pantalla"
L["OPT_FLASH_DESC"] = "Hace parpadear los bordes de la pantalla cuando falta un debuff crítico."

L["OPT_MINIMAP_HEADER"] = "Icono del Minimapa"
L["OPT_MINIMAP"] = "Mostrar el minimapa"
L["OPT_MINIMAP_DESC"] = "Activa o desactiva el botón del minimapa (requiere Reload)."

L["ASSIGNMENTS_MOVED"] = "La configuración de asignaciones ha sido movida a un nuevo panel a medida.\n\nHaz clic en el botón de abajo para abrir la nueva interfaz."
L["OPT_OPEN_ASSIGNMENTS"] = "Abrir Asignaciones"
L["OPT_OPEN_ASSIGNMENTS_DESC"] = "Abre la ventana dinámica de prioridades y asignaciones."

L["STATUS_IDLE"] = "Esperando objetivo..."

L["LDB_CLICK_TOGGLE"] = "|cFFEDA55FClick|r alternar el HUD"
L["LDB_SHIFT_CLICK_ASSIGNMENTS"] = "|cFFEDA55FShift-Click|r para Asignaciones"
L["LDB_RIGHT_CLICK_OPTIONS"] = "|cFFEDA55FClick-Derecho|r para Opciones"

-- Inteligencia v2.3.0
L["ERR_WRONG_CLASS"] = "Clase incorrecta para este debuff."
L["ERR_MISSING_TALENT"] = "Jugador no tiene el talento requerido."
L["SUGGESTED_DEBUFFS"] = "Debuffs Sugeridos"
L["SUGGESTED_PLAYERS"] = "Jugadores Sugeridos"
L["IMPROVED"] = "Mejorado"
L["CONFIG_DELEGATE"] = "Co-Asignador:"

-- Rediseño HUD v2.6.0
L["OPT_HUD_SCALE"] = "Escala del HUD"
L["OPT_HUD_SCALE_DESC"] = "Ajusta el tamaño general (escala) de la interfaz del HUD."
L["OPT_HUD_WIDTH"] = "Ancho del HUD"
L["OPT_HUD_WIDTH_DESC"] = "Ajusta el ancho en píxeles de las barras del HUD."
L["OPT_SHOW_SPELL_NAME"] = "Mostrar nombre de hechizo"
L["OPT_SHOW_SPELL_NAME_DESC"] = "Si se desactiva, solo se verá el icono y el nombre del jugador, ocultando el nombre del hechizo."
L["OPT_PRE_RAID_ALL"] = "Todas las Clases (Pre-Raid)"
L["OPT_ALERT_TOOLTIP_FORMAT"] = "|cFFFF8800¡Optimización Disponible!|r\nEl encargado actual no posee el talento mejorado, pero hay jugadores de su clase que sí lo tienen y están libres:%s\n\n|cFFFFD100Se recomienda cambiar la asignación.|r"
L["OPT_SCAN_ONLY_IN_INSTANCE"] = "Escanear solo en Instancia"
L["OPT_SCAN_ONLY_IN_INSTANCE_DESC"] = "Limita el escaneo de talentos de grupo para que solo se realice dentro de Mazmorras y Bandas (Raid)."

-- Auto-HUD & Local Presets v2.7.0
L["OPT_AUTO_HUD"] = "Modo HUD Automático"
L["OPT_AUTO_HUD_DESC"] = "Monitorea y muestra automáticamente los debuffs en base a las clases presentes en tu grupo/banda, sin requerir asignaciones manuales."
L["OPT_DISABLE_SYNC"] = "Desactivar Sincronización (Modo Local)"
L["OPT_DISABLE_SYNC_DESC"] = "Ignora las asignaciones enviadas por el líder de la banda y te permite editar tu configuración local de forma libre.\n\n|cFFFF3333ADVERTENCIA:|r Si está activo, NO recibirás las asignaciones ni cambios enviados por el líder de la banda. Tu HUD solo reflejará tus asignaciones locales manuales. ¡Úsalo con precaución en bandas de hermandad!"
L["CONFIG_LOAD_PRESET"] = "Cargar Preset"
L["LOAD_PRESET_SUCCESS"] = "Cargado preset por defecto para la composición actual."
L["LOAD_PRESET_NO_PERMS"] = "No tienes permisos para modificar las asignaciones."



