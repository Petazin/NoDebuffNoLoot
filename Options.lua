local addonName, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

local options = {
    name = "NoDebuffNoLoot",
    handler = NoDebuffNoLoot,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L["SHOW_HUD"],
            order = 1,
            args = {
                desc = {
                    type = "description",
                    name = L["ASSIGNMENTS_DESC"],
                    order = 1,
                },
                showHud = {
                    type = "toggle",
                    name = L["SHOW_HUD"],
                    desc = L["SHOW_HUD_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.shown end,
                    set = function(_, val) 
                        NoDebuffNoLoot.db.profile.hud.shown = val 
                        if val then NoDebuffNoLoot:UpdateTracker() else ns.UI:Clear() end
                    end,
                    order = 2,
                },
                lockHud = {
                    type = "toggle",
                    name = "Lock HUD",
                    desc = "Lock the HUD frame to prevent moving",
                    get = function() return NoDebuffNoLoot.db.profile.hud.locked end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.locked = val
                        ns.UI:SetLocked(val)
                    end,
                    order = 3,
                },
                filterMine = {
                    type = "toggle",
                    name = L["OPT_FILTER_MINE"],
                    desc = L["OPT_FILTER_MINE_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.filterMine end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.filterMine = val
                        NoDebuffNoLoot:UpdateTracker()
                    end,
                    order = 4,
                    width = "full",
                },
                alertsHeader = {
                    type = "header",
                    name = "Alerts & Notifications",
                    order = 10,
                },
                alertChat = {
                    type = "toggle",
                    name = "Chat Alerts",
                    desc = "Print alerts to chat window",
                    get = function() return NoDebuffNoLoot.db.profile.alerts.chat end,
                    set = function(_, val) NoDebuffNoLoot.db.profile.alerts.chat = val end,
                    order = 11,
                },
                alertSound = {
                    type = "toggle",
                    name = "Sound Alerts",
                    desc = "Play sounds on alert",
                    get = function() return NoDebuffNoLoot.db.profile.alerts.sound end,
                    set = function(_, val) NoDebuffNoLoot.db.profile.alerts.sound = val end,
                    order = 12,
                },
                alertFlash = {
                    type = "toggle",
                    name = "Screen Flash",
                    desc = "Flash screen borders on critical missing debuffs",
                    get = function() return NoDebuffNoLoot.db.profile.alerts.visual_flash end,
                    set = function(_, val) NoDebuffNoLoot.db.profile.alerts.visual_flash = val end,
                    order = 13,
                },
                minimapHeader = {
                    type = "header",
                    name = "Minimap Icon",
                    order = 20,
                },
                minimapIcon = {
                    type = "toggle",
                    name = "Show Minimap Icon",
                    desc = "Toggle the minimap button (requires Reload)",
                    get = function() return not NoDebuffNoLoot.db.profile.minimap.hide end,
                    set = function(_, val) 
                        NoDebuffNoLoot.db.profile.minimap.hide = not val
                        if ns.LDBIcon then
                            if val then ns.LDBIcon:Show("NoDebuffNoLoot") else ns.LDBIcon:Hide("NoDebuffNoLoot") end
                        end
                    end,
                    order = 21,
                },
            },
        },
        assignments = {
            type = 'group',
            name = L["ASSIGNMENTS"],
            order = 2,
            args = {},
        },
    },
}

function NoDebuffNoLoot:SetupOptions()
    for name, info in pairs(ns.Data.Debuffs) do
        local localizedName, _, icon = GetSpellInfo(info.id)
        local displayName = localizedName or name
        
        options.args.assignments.args[name:gsub("[%s']+", "")] = {
            type = 'input',
            name = "|T" .. (icon or "") .. ":16|t " .. displayName,
            desc = L["PLAYER_NAME_DESC"],
            get = function() return self.db.profile.assignments[name] or "" end,
            set = function(_, val) 
                if val == "" then val = nil end
                self.db.profile.assignments[name] = val
                self:UpdateTracker()
                -- Auto-sync on change
                if ns.Assignments and ns.Assignments.PushConfiguration then
                    ns.Assignments:PushConfiguration()
                end
            end,
            order = 10,
        }
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("NoDebuffNoLoot", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("NoDebuffNoLoot", "NoDebuffNoLoot")
end
