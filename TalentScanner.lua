local addonName, ns = ...
local TalentScanner = CreateFrame("Frame")
ns.TalentScanner = TalentScanner

local COMM_PREFIX = "NDNL_TALENTS"
local INSPECT_INTERVAL = 2.0 -- Segundos entre peticiones para evitar saturar el canal de inspección
local WATCHDOG_TIMEOUT = 3.5 -- Tiempo máximo de espera para INSPECT_READY antes de desbloquear la cola

local talentCache = {} -- [unitName] = { talents = { [tab_idx] = rank }, source = "LOCAL"|"P2P"|"AUTO" }
local inspectQueue = {}
local inspectSuccess = {} -- [guid] = true (para no re-inspeccionar en la misma sesión si ya tuvo éxito)
local isWaitingForInspect = false
local lastInspectTime = 0
local watchdogTimer = nil

-- Helper para limpiar nombre de reino
local function GetCleanName(name)
    if not name then return nil end
    return string.match(name, "([^%-]+)")
end

-- ============================================================================
-- CAPA 1: AUTO-ESCANEO LOCAL (0ms, sin peticiones de red ni NotifyInspect)
-- ============================================================================
function TalentScanner:GetMyTalents()
    local _, myClass = UnitClass("player")
    local myName = GetCleanName(UnitName("player"))
    if not myName or not myClass then return nil end

    local myTalents = {}
    for debuffName, info in pairs(ns.Data.Debuffs) do
        if info.talentId and info.class == myClass then
            local tab, index = tonumber(info.talentId[1]), tonumber(info.talentId[2])
            local nameTalent, _, _, _, rank = GetTalentInfo(tab, index, false)
            if rank then
                myTalents[tab .. "_" .. index] = rank
            end
        end
    end

    talentCache[myName] = {
        class = myClass,
        talents = myTalents,
        source = "LOCAL"
    }

    return myClass, myTalents
end

-- ============================================================================
-- CAPA 2: SINCRONIZACIÓN P2P POR ADDON COMMS (Zero NotifyInspect entre usuarios)
-- ============================================================================
function TalentScanner:SendMyTalents()
    if not IsInGroup() then return end

    local myClass, myTalents = self:GetMyTalents()
    if not myClass or not myTalents then return end

    local talentParts = {}
    for key, rank in pairs(myTalents) do
        table.insert(talentParts, key .. "=" .. rank)
    end

    local payload = string.format("TALENTS:%s:%s", myClass, table.concat(talentParts, ","))
    local channel = IsInRaid() and "RAID" or "PARTY"

    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(COMM_PREFIX, payload, channel)
    end
end

function TalentScanner:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX or not message then return end
    
    local cleanSender = GetCleanName(sender)
    local cleanPlayer = GetCleanName(UnitName("player"))
    if cleanSender == cleanPlayer then return end

    if string.match(message, "^TALENTS:") then
        local _, class, talentStr = strsplit(":", message, 3)
        if class and talentStr then
            local talents = {}
            for pair in string.gmatch(talentStr, "([^,]+)") do
                local k, v = strsplit("=", pair)
                if k and v then
                    talents[k] = tonumber(v) or 0
                end
            end

            talentCache[cleanSender] = {
                class = class,
                talents = talents,
                source = "P2P"
            }

            -- Si el jugador estaba en la cola de inspección física, lo removemos de inmediato
            for i = #inspectQueue, 1, -1 do
                local u = inspectQueue[i]
                if u and GetCleanName(UnitName(u)) == cleanSender then
                    table.remove(inspectQueue, i)
                end
            end
        end
    end
end

-- ============================================================================
-- CAPA 3: COLA DE INSPECCIÓN INTELIGENTE "LAZY" (Circular, Non-Dropping, Zero-Noise)
-- ============================================================================
local function ResolveUnitToGroupUnit(unit)
    if not unit or not UnitExists(unit) then return nil end
    if UnitIsUnit(unit, "player") then return "player" end

    local guid = UnitGUID(unit)
    if not guid then return nil end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local raidUnit = "raid" .. i
            if UnitGUID(raidUnit) == guid then return raidUnit end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            local partyUnit = "party" .. i
            if UnitGUID(partyUnit) == guid then return partyUnit end
        end
    end

    return nil
end

function TalentScanner:QueueInspect(unit)
    if not unit or unit == "player" then return end
    local finalUnit = ResolveUnitToGroupUnit(unit)
    if not finalUnit or finalUnit == "player" then return end

    local guid = UnitGUID(finalUnit)
    local name = GetCleanName(UnitName(finalUnit))
    
    -- Si ya fue resuelto por P2P o por inspección previa en esta sesión, no encolar
    if guid and inspectSuccess[guid] then return end
    if name and talentCache[name] and (talentCache[name].source == "P2P" or talentCache[name].source == "AUTO") then
        return
    end

    -- Evitar duplicados en la cola
    for _, queued in ipairs(inspectQueue) do
        if queued == finalUnit then return end
    end

    table.insert(inspectQueue, finalUnit)
end

local function ProcessInspectQueue()
    -- 1. Pausa absoluta en combate o si el usuario tiene abierta la ventana de inspeccionar
    if InCombatLockdown() or (InspectFrame and InspectFrame:IsShown()) then
        return
    end

    local now = GetTime()

    -- 2. Manejo de timeout de espera (si el servidor no respondió tras WATCHDOG_TIMEOUT segundos)
    if isWaitingForInspect then
        if (now - lastInspectTime) >= WATCHDOG_TIMEOUT then
            isWaitingForInspect = false
            if watchdogTimer then
                watchdogTimer:Cancel()
                watchdogTimer = nil
            end
        else
            return -- Esperando respuesta del servidor
        end
    end

    -- 3. Respetar el throttling de peticiones
    if (now - lastInspectTime) < INSPECT_INTERVAL then
        return
    end

    if #inspectQueue == 0 then return end

    local unit = inspectQueue[1]

    -- Validar existencia y conexión
    if not unit or not UnitExists(unit) or not UnitIsConnected(unit) or not CanInspect(unit) then
        table.remove(inspectQueue, 1)
        return
    end

    -- 4. Verificación de rango físico (~28 yardas nativas con CheckInteractDistance)
    local inRange = CheckInteractDistance(unit, 1)

    if not inRange then
        -- Si está fuera de rango, ROTAR AL FINAL DE LA COLA para reintentar cuando se acerque (Non-dropping)
        table.insert(inspectQueue, table.remove(inspectQueue, 1))
        return
    end

    -- 5. Ejecutar la inspección de forma 100% silenciosa
    table.remove(inspectQueue, 1)
    lastInspectTime = now
    isWaitingForInspect = true

    -- Desregistrar momentáneamente UIErrorsFrame para suprimir cualquier mensaje visual residual
    local errFrame = UIErrorsFrame
    if errFrame then
        errFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    end

    NotifyInspect(unit)

    -- Restaurar UIErrorsFrame tras 0.5s
    C_Timer.After(0.5, function()
        if errFrame then
            errFrame:RegisterEvent("UI_ERROR_MESSAGE")
        end
    end)

    -- Iniciar Watchdog Timer de seguridad
    if watchdogTimer then watchdogTimer:Cancel() end
    watchdogTimer = C_Timer.NewTimer(WATCHDOG_TIMEOUT, function()
        isWaitingForInspect = false
        watchdogTimer = nil
    end)
end

-- Ticker para procesar la cola en segundo plano cada 1 segundo
local queueProcessorFrame = CreateFrame("Frame")
queueProcessorFrame:SetScript("OnUpdate", function(self, elapsed)
    ProcessInspectQueue()
end)

-- ============================================================================
-- PROCESAMIENTO DE RESPUESTA DEL SERVIDOR (INSPECT_READY)
-- ============================================================================
function TalentScanner:ProcessInspect(guid)
    if not guid then return end

    isWaitingForInspect = false
    if watchdogTimer then
        watchdogTimer:Cancel()
        watchdogTimer = nil
    end

    local unit = nil
    if UnitGUID("player") == guid then 
        unit = "player" 
    elseif IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            if UnitGUID("raid" .. i) == guid then unit = "raid" .. i; break end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            if UnitGUID("party" .. i) == guid then unit = "party" .. i; break end
        end
    end

    if not unit then return end
    local name = GetCleanName(UnitName(unit))
    if not name then return end

    local _, uClass = UnitClass(unit)
    if not uClass then return end

    -- Si ya fue establecido por P2P, no sobreescribir salvo que sea local
    local existing = talentCache[name]
    if existing and existing.source == "P2P" then return end

    local talents = {}
    local isInspect = (unit ~= "player")

    for debuffName, info in pairs(ns.Data.Debuffs) do
        if info.talentId and info.class == uClass then
            local tab, index = tonumber(info.talentId[1]), tonumber(info.talentId[2])
            local nameTalent, _, _, _, rank = GetTalentInfo(tab, index, isInspect)
            if rank then
                talents[tab .. "_" .. index] = rank
            end
        end
    end

    talentCache[name] = {
        class = uClass,
        talents = talents,
        source = isInspect and "AUTO" or "LOCAL"
    }

    inspectSuccess[guid] = true
end

-- ============================================================================
-- CONSULTA PÚBLICA DE TALENTOS
-- ============================================================================
function TalentScanner:HasTalent(unitName, talentIdTable)
    if not unitName or not talentIdTable then return false end
    local cleanName = GetCleanName(unitName)
    local cache = talentCache[cleanName]
    if not cache or not cache.talents then return nil end -- Desconocido (aún no resuelto)

    local key = talentIdTable[1] .. "_" .. talentIdTable[2]
    return (cache.talents[key] or 0) > 0
end

-- ============================================================================
-- DISPARADORES DE ESCANEO
-- ============================================================================
function TalentScanner:ScanGroup(isReadyCheck)
    -- 1. Auto-escanearse a uno mismo siempre
    self:GetMyTalents()

    -- 2. Emitir nuestros talentos a los compañeros con el addon
    self:SendMyTalents()

    if not IsInGroup() then return end

    -- Validar opción de escaneo solo en instancia
    if NoDebuffNoLoot and NoDebuffNoLoot.db and NoDebuffNoLoot.db.profile and NoDebuffNoLoot.db.profile.scanOnlyInInstance then
        local inInstance, instanceType = IsInInstance()
        local inDungeonOrRaid = inInstance and (instanceType == "party" or instanceType == "raid")
        if not inDungeonOrRaid then return end
        if not isReadyCheck then return end
    end

    local members = GetNumGroupMembers()
    local unitPrefix = IsInRaid() and "raid" or "party"

    for i = 1, members do
        local unit = unitPrefix .. i
        if i == members and not IsInRaid() then unit = "player" end

        if unit ~= "player" and UnitExists(unit) and UnitIsConnected(unit) then
            self:QueueInspect(unit)
        end
    end
end

-- ============================================================================
-- EVENTOS DEL SISTEMA
-- ============================================================================
function TalentScanner:OnEvent(event, ...)
    if event == "INSPECT_READY" then
        local guid = ...
        self:ProcessInspect(guid)
    elseif event == "GROUP_ROSTER_UPDATE" then
        if IsInGroup() then
            self:GetMyTalents()
            self:SendMyTalents()
            self:ScanGroup(false)
        end
    elseif event == "READY_CHECK" then
        self:ScanGroup(true)
    elseif event == "ENCOUNTER_END" then
        self:ScanGroup(false)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellId = ...
        -- Detectar spells de cambio de spec / dual spec (63644, 63645) o reseteo
        if spellId == 63644 or spellId == 63645 then
            if unit == "player" then
                self:GetMyTalents()
                self:SendMyTalents()
            else
                local name = GetCleanName(UnitName(unit))
                local guid = UnitGUID(unit)
                if name then talentCache[name] = nil end
                if guid then inspectSuccess[guid] = nil end
                self:QueueInspect(unit)
            end
        end
    end
end

TalentScanner:RegisterEvent("INSPECT_READY")
TalentScanner:RegisterEvent("GROUP_ROSTER_UPDATE")
TalentScanner:RegisterEvent("READY_CHECK")
TalentScanner:RegisterEvent("ENCOUNTER_END")
TalentScanner:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
TalentScanner:SetScript("OnEvent", TalentScanner.OnEvent)

-- Registrar receptor de AceComm para el canal P2P de talentos de NDNL
local commFrame = CreateFrame("Frame")
commFrame:RegisterEvent("PLAYER_LOGIN")
commFrame:SetScript("OnEvent", function()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)
    end
    if NoDebuffNoLoot and NoDebuffNoLoot.RegisterComm then
        NoDebuffNoLoot:RegisterComm(COMM_PREFIX, function(...) TalentScanner:OnCommReceived(...) end)
    end
    TalentScanner:GetMyTalents()
end)
