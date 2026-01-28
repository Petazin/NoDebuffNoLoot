local addonName, ns = ...
NoDebuffNoLoot = LibStub("AceAddon-3.0"):NewAddon("NoDebuffNoLoot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

local defaults = {
    profile = {
        assignments = {},
        hud = {
            shown = true,
            locked = false,
            scale = 1.0,
            x = 0,
            y = 0,
        },
    },
}

-- Estados temporales de alertas para evitar spam y contaminación de Data.lua
local alertStates = {}

function NoDebuffNoLoot:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("NoDebuffNoLootDB", defaults, true)
    
    self:SetupOptions()
    
    if ns.UI and ns.UI.Init then
        ns.UI:Init()
    end

    self:RegisterComm("NDNL_SYNC", function(...) ns.Assignments:OnCommReceived(...) end)

    self:RegisterChatCommand("ndnl", "OpenOptions")
    self:RegisterChatCommand("ndnlsync", function() ns.Assignments:PushConfiguration() end)
    
    self:Print(L["TRACKER_LOADED"])
end

function NoDebuffNoLoot:OpenOptions()
    if self.optionsFrame then
        -- Doble llamada para mitigar el bug de Blizzard en el panel de opciones
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end
end

function NoDebuffNoLoot:OnEnable()
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function NoDebuffNoLoot:UNIT_AURA(event, unit)
    if unit == "target" then
        self:UpdateTracker()
    end
end

function NoDebuffNoLoot:PLAYER_TARGET_CHANGED()
    self:UpdateTracker()
end

function NoDebuffNoLoot:UpdateTracker()
    if not UnitExists("target") or UnitIsFriend("player", "target") or UnitIsDead("target") then
        if ns.UI and ns.UI.Clear then ns.UI:Clear() end
        return
    end

    if not self.db.profile.hud.shown then 
        if ns.UI and ns.UI.Clear then ns.UI:Clear() end
        return 
    end

    local playerName = UnitName("player")

    for debuffName, info in pairs(ns.Data.Debuffs) do
        local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("target", debuffName, nil, "HARMFUL")
        
        local assignedPlayer = self.db.profile.assignments[debuffName]
        
        if assignedPlayer then
            alertStates[debuffName] = alertStates[debuffName] or { missing = false, expire = false }
            
            if name then
                local timeLeft = expirationTime > 0 and (expirationTime - GetTime()) or 999
                ns.UI:SetStatus(debuffName, L["STATUS_ACTIVE"], timeLeft, assignedPlayer, icon or info.icon)
                
                -- Alerta de expiración
                if assignedPlayer == playerName and timeLeft < 5 then
                    if not alertStates[debuffName].expire then
                        UIErrorsFrame:AddMessage(string.format(L["ALERT_EXPIRE"], debuffName), 1.0, 1.0, 0.0)
                        alertStates[debuffName].expire = true
                    end
                elseif timeLeft >= 5 then
                    alertStates[debuffName].expire = false
                end
                -- Reset alerta de missing
                alertStates[debuffName].missing = false
            else
                ns.UI:SetStatus(debuffName, L["STATUS_MISSING"], 0, assignedPlayer, info.icon)
                
                -- Alerta de missing
                if assignedPlayer == playerName then
                    if not alertStates[debuffName].missing then
                        UIErrorsFrame:AddMessage(string.format(L["ALERT_MISSING"], debuffName), 1.0, 0.0, 0.0)
                        alertStates[debuffName].missing = true
                    end
                end
                -- Reset alerta de expire
                alertStates[debuffName].expire = false
            end
        end
    end
end
