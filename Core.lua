local addonName, ns = ...
NoDebuffNoLoot = LibStub("AceAddon-3.0"):NewAddon("NoDebuffNoLoot", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

-- ... (Rest of lines maintained implicitly by tool, but I should be precise if replacing chunks)

function NoDebuffNoLoot:OnEnable()
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    
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
        assignments = {
            -- Lista ordenada por defecto. Fallback. [1] = { debuff = "Sunder Armor", primary = "", backup = "" }
        },
        delegate = "", -- Nombre del Co-Asignador Delegado
        hud = {
            shown = true,
            alwaysShow = false,
            locked = false,
            scale = 1.0,
            width = 220,
            showSpellName = true,
            x = 0,
            y = 0,
            filterMine = false,
            onlyMissing = false,
            bossOnly = false,
        },
        alerts = {
            chat = true,
            sound = true,
            visual_flash = true,
            combatDelay = 3, -- Segundos de gracia
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
local combatStartTime = 0

function NoDebuffNoLoot:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("NoDebuffNoLootDB", defaults, true)
    
    -- Migración de IDs antiguos de Curse of Recklessness corruptos (27223 y 11718 -> 11717)
    if self.db.profile.assignments then
        for _, assignment in ipairs(self.db.profile.assignments) do
            if assignment.spellId == 27223 or assignment.spellId == 11718 then
                assignment.spellId = 11717
            end
        end
    end
    
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
        local categoryID = (self.optionsFrame and self.optionsFrame.name) or "NoDebuffNoLoot"
        Settings.OpenToCategory(categoryID)
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

function NoDebuffNoLoot:PLAYER_REGEN_DISABLED()
    combatStartTime = GetTime()
end

function NoDebuffNoLoot:UpdateTracker()
    if not self.db.profile.hud.shown then 
        if ns.UI and ns.UI.Clear then ns.UI:Clear() end
        return 
    end

    local validTarget = UnitExists("target") and not UnitIsFriend("player", "target") and not UnitIsDead("target")

    -- Filter by Boss
    if validTarget and self.db.profile.hud.bossOnly then
        local classification = UnitClassification("target")
        local isBoss = (classification == "worldboss" or UnitLevel("target") == -1)
        if not isBoss then
            validTarget = false
        end
    end

    if not validTarget and not self.db.profile.hud.alwaysShow then
        if ns.UI and ns.UI.Clear then ns.UI:Clear() end
        return
    end

    local playerName = UnitName("player")
    
    -- 1. Escanear todos los debuffs del objetivo solo si hay target
    local activeDebuffs = {}
    if validTarget then
        for i = 1, 40 do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("target", i, "HARMFUL")
            if not name then break end
            
            -- Guardamos el debuff tanto por su Spell ID como por su Nombre localizado en minúsculas (para soportar rangos)
            local data = {
                name = name,
                icon = icon,
                duration = duration,
                expirationTime = expirationTime,
                spellId = spellId
            }
            activeDebuffs[spellId] = data
            activeDebuffs[string.lower(name)] = data
        end
    end

    -- 2. Actualizar el HUD basado en la nueva lista ordenada de asignaciones
    for _, assignment in ipairs(self.db.profile.assignments) do
        local debuffId = assignment.spellId
        local assignedPlayer = assignment.primary
        local backupPlayer = assignment.backup
        
        -- Asegurar que debuffId exista
        if debuffId then
            local debuffName = GetSpellInfo(debuffId)
            local icon = GetSpellTexture(debuffId)
            
            -- Buscar si el debuff está activo en el objetivo (por ID o por coincidencia de nombre localizado)
            local activeData = activeDebuffs[debuffId]
            if not activeData and debuffName then
                activeData = activeDebuffs[string.lower(debuffName)]
            end

            -- Smart Overwrite: Expose Armor overrides Sunder Armor requirement
            if debuffId == 25225 and not activeData then --> 25225 = Sunder Armor
                local exposeName = GetSpellInfo(8647)
                if exposeName and activeDebuffs[string.lower(exposeName)] then
                    activeData = activeDebuffs[string.lower(exposeName)]
                end
            end
            
            -- Smart Overwrite: Demoralizing Shout (Guerrero) y Demoralizing Roar (Druida) se satisfacen mutuamente
            if debuffId == 25203 and not activeData then --> 25203 = Demoralizing Shout
                local roarName = GetSpellInfo(8983)
                if roarName and activeDebuffs[string.lower(roarName)] then
                    activeData = activeDebuffs[string.lower(roarName)]
                end
            elseif debuffId == 8983 and not activeData then --> 8983 = Demoralizing Roar
                local shoutName = GetSpellInfo(25203)
                if shoutName and activeDebuffs[string.lower(shoutName)] then
                    activeData = activeDebuffs[string.lower(shoutName)]
                end
            end

            -- Si no validamos playerName, se muestra todo (según filtro)
            -- Validar si el encargado tiene la clase correcta
            local talentOk = true
            if ns.SmartSelection and ns.SmartSelection.Validate then
                talentOk = ns.SmartSelection:Validate(assignedPlayer, debuffId)
            end
            
            -- Detectar si el encargado posee el talento de mejora
            local hasTalent = false
            if ns.TalentScanner and assignedPlayer and assignedPlayer ~= "" then
                local debuffInfo = nil
                for name, info in pairs(ns.Data.Debuffs) do
                    if info.id == debuffId then debuffInfo = info; break end
                end
                if debuffInfo and debuffInfo.talentId then
                    hasTalent = ns.TalentScanner:HasTalent(assignedPlayer, debuffInfo.talentId) == true
                end
            end

            -- Si no validamos playerName, se muestra todo (según filtro)
            if not self.db.profile.hud.filterMine or assignedPlayer == playerName or backupPlayer == playerName then
                
                -- Inicializar el estado de alertas de este debuff si no existe (usamos el ID como key ahora)
                alertStates[debuffId] = alertStates[debuffId] or { missing = false, expire = false }
            
                if not validTarget then
                    -- Mostrar HUD inactivo (IDLE) si no hay target pero está el override "alwaysShow"
                    ns.UI:SetStatus(debuffId, debuffName, "IDLE", 0, assignedPlayer, backupPlayer, icon, not talentOk, hasTalent)
                    alertStates[debuffId].missing = false
                    alertStates[debuffId].expire = false
                elseif activeData then
                    local timeLeft = activeData.expirationTime > 0 and (activeData.expirationTime - GetTime()) or 999
                    
                    if self.db.profile.hud.onlyMissing then
                        if ns.UI and ns.UI.HideRow then ns.UI:HideRow(debuffId) end
                    else
                        ns.UI:SetStatus(debuffId, debuffName, "ACTIVE", timeLeft, assignedPlayer, backupPlayer, activeData.icon or icon, not talentOk, hasTalent)
                    end
                    
                    -- Alerta de expiración
                    if (assignedPlayer == playerName or backupPlayer == playerName) and timeLeft < 5 then
                        if not alertStates[debuffId].expire then
                            UIErrorsFrame:AddMessage(string.format(L["ALERT_EXPIRE"], debuffName), 1.0, 1.0, 0.0)
                            alertStates[debuffId].expire = true
                        end
                    elseif timeLeft >= 5 then
                        alertStates[debuffId].expire = false
                    end
                    alertStates[debuffId].missing = false
                else
                    local inCombat = InCombatLockdown()
                    local delay = tonumber(assignment.combatDelay) or 3
                    local inGracePeriod = inCombat and (GetTime() - combatStartTime < delay)

                    if not inCombat or inGracePeriod then
                        ns.UI:SetStatus(debuffId, debuffName, "PENDING", 0, assignedPlayer, backupPlayer, icon, not talentOk, hasTalent)
                        alertStates[debuffId].missing = false
                    else
                        ns.UI:SetStatus(debuffId, debuffName, "MISSING", 0, assignedPlayer, backupPlayer, icon, not talentOk, hasTalent)
                        
                        -- Alerta de missing dura (solo a los encargados)
                        if (assignedPlayer == playerName or backupPlayer == playerName) and not alertStates[debuffId].missing then
                            UIErrorsFrame:AddMessage(string.format(L["ALERT_MISSING"], debuffName), 1.0, 0.0, 0.0)
                            
                            -- Chat Log Alert
                            if self.db.profile.alerts.chat then
                                self:Print(string.format(L["ALERT_MISSING"], debuffName))
                            end

                            if ns.UI and ns.UI.FlashScreen then
                                 ns.UI:FlashScreen()
                            end
                            
                            alertStates[debuffId].missing = true
                        end
                    end
                    alertStates[debuffId].expire = false
                end
            else
                if ns.UI and ns.UI.HideRow then ns.UI:HideRow(debuffId) end
            end
        end
    end
    
    if ns.UI and ns.UI.UpdateLayout then
        ns.UI:UpdateLayout()
    end
end

