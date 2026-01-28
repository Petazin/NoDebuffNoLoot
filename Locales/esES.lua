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
