local L = LibStub("AceLocale-3.0"):NewLocale("NoDebuffNoLoot", "enUS", true)
if not L then return end

L["TRACKER_LOADED"] = "Loaded correctly. v2.0.0. Type /ndnl to configure."
L["SHOW_HUD"] = "Show HUD"
L["SHOW_HUD_DESC"] = "Shows or hides the debuff panel."
L["ASSIGNMENTS"] = "Assignments"
L["ASSIGNMENTS_DESC"] = "Assign players to each critical debuff to track their presence on the boss."
L["PLAYER_NAME"] = "Player Name"
L["PLAYER_NAME_DESC"] = "Name of the player responsible for this debuff."
L["SYNC_SENT"] = "Configuration sent to the raid."
L["SYNC_RECEIVED"] = "Configuration received from %s."
L["STATUS_ACTIVE"] = "ACTIVE"
L["STATUS_MISSING"] = "MISSING"
L["ALERT_EXPIRE"] = "YOUR DEBUFF EXPIRES: %s!"
L["ALERT_MISSING"] = "YOUR DEBUFF IS MISSING: %s!"
