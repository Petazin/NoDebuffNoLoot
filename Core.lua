local addonName, ns = ...
NoDebuffNoLoot = LibStub("AceAddon-3.0"):NewAddon("NoDebuffNoLoot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

-- ... (Rest of lines maintained implicitly by tool, but I should be precise if replacing chunks)

function NoDebuffNoLoot:OnEnable()
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    
    -- Usar C_Timer nativo por robustez. Tick cada 0.5s para no sobrecargar
    if self.timer then self.timer:Cancel() end
    self.timer = C_Timer.NewTicker(0.5, function()
        -- Proteger la llamada con xpcall para que un error no mate el timer para siempre
        xpcall(function() self:UpdateTracker() end, geterrorhandler())
    end)
end

function NoDebuffNoLoot:OnDisable()
    if self.timer then
        self:CancelTimer(self.timer)
        self.timer = nil
    end
end

local defaults = {
    profile = {
        assignments = {},
        hud = {
            shown = true,
            locked = false,
            scale = 1.0,
            x = 0,
            scale = 1.0,
            x = 0,
            y = 0,
            filterMine = false,
        },
        alerts = {
            chat = true,
            sound = true,
            visual_flash = true,
        },
        minimap = {
            hide = false,
        },
    },
}

-- Estados temporales de alertas para evitar spam y contaminación de Data.lua
local alertStates = {}

-- Caché de nombres localizados: Localizado -> Ingles
local localizedToEnglish = {}

function NoDebuffNoLoot:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("NoDebuffNoLootDB", defaults, true)
    
    -- Generar mapeo de nombres localizados usando los IDs de Data.lua
    for englishName, info in pairs(ns.Data.Debuffs) do
        local localizedName = GetSpellInfo(info.id)
        if localizedName then
            localizedToEnglish[localizedName] = englishName
        end
    end
    
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
    -- Detectar si estamos en un cliente moderno (Anniversary/Retail) o clásico antiguo
    if Settings and Settings.OpenToCategory then
        -- WoW Moderno (10.0+ o Classic Anniversary)
        Settings.OpenToCategory("NoDebuffNoLoot")
    elseif InterfaceOptionsFrame_OpenToCategory then
        -- WoW Clásico Antiguo / TBC Original build
        if self.optionsFrame then
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        end
    else
        -- Fallback: Abrir el menú principal si nada funciona
        ToggleHelpFrame() 
    end
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
    
    -- 1. Escanear todos los debuffs del objetivo una sola vez
    local activeDebuffs = {}
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("target", i, "HARMFUL")
        if not name then break end
        
        -- Si este debuff localizado está en nuestra base de datos, lo guardamos
        local englishKey = localizedToEnglish[name]
        if englishKey then
            activeDebuffs[englishKey] = {
                name = name,
                icon = icon,
                duration = duration,
                expirationTime = expirationTime,
                spellId = spellId
            }
        end
    end

    -- 2. Actualizar el HUD basado en las asignaciones
    for debuffName, info in pairs(ns.Data.Debuffs) do
        local assignedPlayer = self.db.profile.assignments[debuffName]
        
        if assignedPlayer then
            -- Filter: Show Only Mine
            if not self.db.profile.hud.filterMine or assignedPlayer == playerName then
                alertStates[debuffName] = alertStates[debuffName] or { missing = false, expire = false }
            
            local activeData = activeDebuffs[debuffName]
            
            if activeData then
                local timeLeft = activeData.expirationTime > 0 and (activeData.expirationTime - GetTime()) or 999
                
                -- DEBUG VERBOSO eliminado por limpieza
                ns.UI:SetStatus(debuffName, "ACTIVE", timeLeft, assignedPlayer, activeData.icon or info.icon)
                
                -- Alerta de expiración
                if assignedPlayer == playerName and timeLeft < 5 then
                    if not alertStates[debuffName].expire then
                        UIErrorsFrame:AddMessage(string.format(L["ALERT_EXPIRE"], debuffName), 1.0, 1.0, 0.0)
                        alertStates[debuffName].expire = true
                    end
                elseif timeLeft >= 5 then
                    alertStates[debuffName].expire = false
                end
                alertStates[debuffName].missing = false
            else
                ns.UI:SetStatus(debuffName, "MISSING", 0, assignedPlayer, info.icon)
                
                -- Alerta de missing (Solo si estamos en combate)
                if assignedPlayer == playerName then
                    -- Resetear estado si no estamos en combate para permitir re-alerta al iniciar
                    if not InCombatLockdown() then
                        alertStates[debuffName].missing = false
                    elseif not alertStates[debuffName].missing then
                         UIErrorsFrame:AddMessage(string.format(L["ALERT_MISSING"], debuffName), 1.0, 0.0, 0.0)
                        
                        -- Chat Log Alert
                        if self.db.profile.alerts.chat then
                            self:Print(string.format(L["ALERT_MISSING"], debuffName))
                        end

                        if ns.UI and ns.UI.FlashScreen then
                             ns.UI:FlashScreen()
                        end
                        
                        alertStates[debuffName].missing = true
                    end
                end
                alertStates[debuffName].expire = false
            end

            else
                if ns.UI and ns.UI.HideRow then ns.UI:HideRow(debuffName) end
            end
        end
    end
end

