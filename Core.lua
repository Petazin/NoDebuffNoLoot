local addonName, ns = ...
NoDebuffNoLoot = LibStub("AceAddon-3.0"):NewAddon("NoDebuffNoLoot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot", true)

-- Valores por defecto para la base de datos
local defaults = {
    profile = {
        assignments = {
            -- ["Sunder Armor"] = "PlayerName",
        },
        hud = {
            shown = true,
            x = 0,
            y = 0,
        },
    },
}

function NoDebuffNoLoot:OnInitialize()
    -- Inicializar DB
    self.db = LibStub("AceDB-3.0"):New("NoDebuffNoLootDB", defaults, true)
    
    self:Print("Cargado correctamente. Escribe /ndnl para ver las opciones.")
end

function NoDebuffNoLoot:OnEnable()
    -- Registrar eventos
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
    -- Lógica para revisar los debuffs en el target
    if not UnitExists("target") or UnitIsFriend("player", "target") then
        -- Ocultar HUD o limpiar datos si no hay target válido
        return
    end

    for debuffName, data in pairs(ns.Data.Debuffs) do
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitAura("target", debuffName, nil, "HARMFUL")
        
        local assignedPlayer = self.db.profile.assignments[debuffName]
        if assignedPlayer then
            if name then
                -- Debuff presente
                -- ns.UI:SetStatus(debuffName, "ACTIVE", expirationTime - GetTime())
            else
                -- Debuff ausente
                -- ns.UI:SetStatus(debuffName, "MISSING")
            end
        end
    end
end
