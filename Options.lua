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
