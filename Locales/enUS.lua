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
L["OPT_FILTER_MINE"] = "Only My Assignments"
L["OPT_FILTER_MINE_DESC"] = "Hide assignments that are not yours from the HUD"

L["CONFIG_TITLE"] = "NoDebuffNoLoot - Assignments"
L["CONFIG_SPELL"] = "Spell ID / Name"
L["CONFIG_PRIMARY"] = "Primary"
L["CONFIG_BACKUP"] = "Backup"
L["CONFIG_DELAY"] = "Delay"
L["CONFIG_PRIORITY"] = "Priority"
L["CONFIG_ADD_NEW"] = "Add New Debuff"
L["CONFIG_ANNOUNCE"] = "Announce to Raid"
L["ANN_RW_FORMAT"] = "%s - Primary: %s - Backup: %s"
L["ANN_WISP_PRIMARY"] = "You are assigned to %s as PRIMARY."
L["ANN_WISP_BACKUP"] = "You are assigned to %s as BACKUP."
L["ANN_REQ_PRIVILEGE"] = "You must be Raid Leader or Assistant to announce assignments."

L["OPT_ALWAYS_SHOW"] = "Always Show HUD"
L["OPT_ALWAYS_SHOW_DESC"] = "Show HUD frames even without a valid target."
L["OPT_LOCK"] = "Lock HUD"
L["OPT_LOCK_DESC"] = "Lock the HUD frame to prevent moving"
L["OPT_BOSS_ONLY"] = "Only on Bosses"
L["OPT_BOSS_ONLY_DESC"] = "Only monitor debuffs and show alerts when targeting a Boss (Skull Level or World Boss)."
L["OPT_ONLY_MISSING"] = "Show Only Missing"
L["OPT_ONLY_MISSING_DESC"] = "Only display the HUD rows for assignments that are actually missing on the target."

L["OPT_ALERTS_HEADER"] = "Alerts & Notifications"
L["OPT_CHAT"] = "Chat Alerts"
L["OPT_CHAT_DESC"] = "Print alerts to chat window"
L["OPT_SOUND"] = "Sound Alerts"
L["OPT_SOUND_DESC"] = "Play sounds on alert"
L["OPT_FLASH"] = "Screen Flash"
L["OPT_FLASH_DESC"] = "Flash screen borders on critical missing debuffs"

L["OPT_MINIMAP_HEADER"] = "Minimap Icon"
L["OPT_MINIMAP"] = "Show Minimap Icon"
L["OPT_MINIMAP_DESC"] = "Toggle the minimap button (requires Reload)"

L["ASSIGNMENTS_MOVED"] = "The assignments configuration has been moved to a new Custom Panel.\n\nClick the button below to open the new assignments interface."
L["OPT_OPEN_ASSIGNMENTS"] = "Open Assignments Panel"
L["OPT_OPEN_ASSIGNMENTS_DESC"] = "Opens the dynamic assignments window."

L["STATUS_IDLE"] = "Waiting Target..."

L["LDB_CLICK_TOGGLE"] = "|cFFEDA55FClick|r to Toggle HUD"
L["LDB_SHIFT_CLICK_ASSIGNMENTS"] = "|cFFEDA55FShift-Click|r for Assignments"
L["LDB_RIGHT_CLICK_OPTIONS"] = "|cFFEDA55FRight-Click|r for Options"

-- Intelligence v2.3.0
L["ERR_WRONG_CLASS"] = "Wrong class for this debuff."
L["ERR_MISSING_TALENT"] = "Player missing required talent."
L["SUGGESTED_DEBUFFS"] = "Suggested Debuffs"
L["SUGGESTED_PLAYERS"] = "Suggested Players"
L["IMPROVED"] = "Improved"
L["CONFIG_DELEGATE"] = "Co-Assigner:"

-- HUD Redesign v2.6.0
L["OPT_HUD_SCALE"] = "HUD Scale"
L["OPT_HUD_SCALE_DESC"] = "Adjust the overall scale of the HUD interface."
L["OPT_HUD_WIDTH"] = "HUD Width"
L["OPT_HUD_WIDTH_DESC"] = "Adjust the pixel width of the HUD bars."
L["OPT_SHOW_SPELL_NAME"] = "Show Spell Name"
L["OPT_SHOW_SPELL_NAME_DESC"] = "If disabled, only the icon and player name will be shown on the HUD, hiding the spell name."
L["OPT_PRE_RAID_ALL"] = "All Classes (Pre-Raid)"
L["OPT_ALERT_TOOLTIP_FORMAT"] = "|cFFFF8800Optimization Available!|r\nThe assigned player does not have the improved talent, but there are players of their class who have it and are free:%s\n\n|cFFFFD100It is recommended to change the assignment.|r"
L["OPT_SCAN_ONLY_IN_INSTANCE"] = "Scan Only in Instance"
L["OPT_SCAN_ONLY_IN_INSTANCE_DESC"] = "Limits group talent scanning to only perform inside Dungeons and Raids."

-- Auto-HUD & Local Presets v2.7.0
L["OPT_AUTO_HUD"] = "Auto-HUD Mode"
L["OPT_AUTO_HUD_DESC"] = "Automatically tracks and displays active debuffs based on the classes present in your party/raid, without requiring manual assignments."
L["OPT_DISABLE_SYNC"] = "Disable Sync (Local Mode)"
L["OPT_DISABLE_SYNC_DESC"] = "Ignores assignments sent by the raid leader and allows you to freely edit your local configuration.\n\n|cFFFF3333WARNING:|r If active, you will NOT receive any assignments or changes sent by the raid leader. Your HUD will only show your manual local assignments. Use with caution in guild runs!"
L["CONFIG_LOAD_PRESET"] = "Load Preset"
L["LOAD_PRESET_SUCCESS"] = "Loaded default presets for current raid composition."
L["LOAD_PRESET_NO_PERMS"] = "You do not have permissions to modify assignments."



