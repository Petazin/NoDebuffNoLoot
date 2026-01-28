local addonName, ns = ...
NoDebuffNoLoot = LibStub("AceAddon-3.0"):NewAddon("NoDebuffNoLoot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")

-- Configuración de AceLocale (aunque temporalmente usemos español directamente si no hay locales aún)
local L = setmetatable({}, { __index = function(t, k) return k end })

-- Valores por defecto para la base de datos
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

function NoDebuffNoLoot:OnInitialize()
    -- Inicializar DB
    self.db = LibStub("AceDB-3.0"):New("NoDebuffNoLootDB", defaults, true)
    
    -- Inicializar Opciones
    self:SetupOptions()
    
    -- Inicializar UI
    if ns.UI and ns.UI.Init then
        ns.UI:Init()
    end

    -- Registrar Comm
    self:RegisterComm("NDNL_SYNC", function(...) ns.Assignments:OnCommReceived(...) end)

    self:RegisterChatCommand("ndnl", "OpenOptions")
    self:RegisterChatCommand("ndnlsync", function() ns.Assignments:PushConfiguration() end)
    self:Print("Cargado correctamente. v1.2.0. Escribe /ndnl para configurar.")
end

function NoDebuffNoLoot:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame) -- Doble llamada para bug de Blizzard
end

function NoDebuffNoLoot:OnEnable()
    -- Registrar eventos
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function NoDebuffNoLoot:UNIT_AURA(event, unit)
    if unit == "target" then
        self:UpdateTracker()
    end
end

function NoDebuffNoLoot:PLAYER_TARGET_CHANGED()
    self:UpdateTracker()
end

function NoDebuffNoLoot:COMBAT_LOG_EVENT_UNFILTERED()
    -- Podríamos usar esto para detectar quién aplicó qué debuff con más precisión
    -- Por ahora confiaremos en UnitAura para el target
end

-- Actualización principal de la lógica
function NoDebuffNoLoot:UpdateTracker()
    if not UnitExists("target") or UnitIsFriend("player", "target") or UnitIsDead("target") then
        if ns.UI and ns.UI.Clear then ns.UI:Clear() end
        return
    end

    for debuffName, info in pairs(ns.Data.Debuffs) do
        -- En TBC UnitAura usa el nombre o el ID
        local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("target", debuffName, nil, "HARMFUL")
        
        local assignedPlayer = self.db.profile.assignments[debuffName]
        
        -- Si no hay nadie asignado, igual lo mostramos pero sin responsable?
        -- Por ahora basémonos en si el usuario quiere trackearlo
        if assignedPlayer then
            if name then
                local timeLeft = expirationTime > 0 and (expirationTime - GetTime()) or 999
                ns.UI:SetStatus(debuffName, "ACTIVE", timeLeft, assignedPlayer, icon or info.icon)
                
                -- Alerta si va a expirar y el jugador es el local
                if assignedPlayer == UnitName("player") and timeLeft < 5 and not info.alertSent then
                    UIErrorsFrame:AddMessage("¡TU DEBUFF EXPIRA: " .. debuffName .. "!", 1.0, 1.0, 0.0)
                    info.alertSent = true
                elseif timeLeft >= 5 then
                    info.alertSent = false
                end
            else
                ns.UI:SetStatus(debuffName, "MISSING", 0, assignedPlayer, info.icon)
                
                -- Alerta si falta y el jugador es el local
                if assignedPlayer == UnitName("player") and not info.missingAlertSent then
                    UIErrorsFrame:AddMessage("¡FALTA TU DEBUFF: " .. debuffName .. "!", 1.0, 0.0, 0.0)
                    info.missingAlertSent = true
                end
            end
            
            -- Si el debuff aparece, resetear alerta de missing
            if name then info.missingAlertSent = false end
        end
    end
end
