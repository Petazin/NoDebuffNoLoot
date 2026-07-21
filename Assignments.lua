local addonName, ns = ...
local Assignments = {}
ns.Assignments = Assignments

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")
local AceSerializer = LibStub("AceSerializer-3.0")

local COMM_PREFIX = "NDNL_SYNC"

function Assignments:Set(debuffId, primaryPlayer, backupPlayer)
    -- This function is kept for backwards compatibility or programmatic use
    table.insert(NoDebuffNoLoot.db.profile.assignments, {
        spellId = debuffId,
        primary = primaryPlayer,
        backup = backupPlayer
    })
    
    NoDebuffNoLoot:Print(string.format("Asignado %s a %s (Backup: %s)", GetSpellInfo(debuffId) or debuffId, primaryPlayer, backupPlayer or "N/A"))
    if IsInRaid() or IsInGroup() then
        self:PushConfiguration()
    end
end

function Assignments:Clear(debuffId)
    local list = NoDebuffNoLoot.db.profile.assignments
    for i = #list, 1, -1 do
        if list[i].spellId == debuffId then
            table.remove(list, i)
        end
    end
end

function Assignments:PushConfiguration()
    if NoDebuffNoLoot.db.profile.disableSync then return end
    if not (IsInRaid() or IsInGroup()) then return end
    
    local myName = UnitName("player")
    local delegate = NoDebuffNoLoot.db.profile.delegate or ""
    
    local cleanMyName = string.match(myName, "([^%-]+)")
    local cleanDelegate = string.match(delegate, "([^%-]+)")
    
    -- Solo el líder, asistentes o el delegado pueden enviar la configuración
    local isLeader = UnitIsGroupLeader("player")
    local isAssistant = UnitIsGroupAssistant("player")
    local isDelegate = (cleanDelegate ~= "" and cleanMyName == cleanDelegate)
    
    if not (isLeader or isAssistant or isDelegate) then return end

    local data = {
        assignments = NoDebuffNoLoot.db.profile.assignments,
        delegate = NoDebuffNoLoot.db.profile.delegate or ""
    }
    local serialized = AceSerializer:Serialize(data)
    
    NoDebuffNoLoot:SendCommMessage(COMM_PREFIX, serialized, "RAID")
    NoDebuffNoLoot:Print(L["SYNC_SENT"])
end

function Assignments:OnCommReceived(prefix, message, distribution, sender)
    if NoDebuffNoLoot.db.profile.disableSync then return end
    if prefix ~= COMM_PREFIX or sender == UnitName("player") then return end
    
    -- Validar que el remitente es Líder, Ayudante o el Delegado antes de aceptar cambios
    local senderIsAuthorized = false
    local numGroup = GetNumGroupMembers()
    
    local delegate = NoDebuffNoLoot.db.profile.delegate or ""
    local cleanSender = string.match(sender, "([^%-]+)")
    local cleanDelegate = string.match(delegate, "([^%-]+)")
    
    -- 1. Verificar si es el delegado autorizado
    if cleanDelegate ~= "" and cleanSender == cleanDelegate then
        senderIsAuthorized = true
    end
    
    -- 2. Si no es el delegado, verificar si es Líder o Asistente
    if not senderIsAuthorized then
        if IsInRaid() then
            for i = 1, numGroup do
                local name, rank = GetRaidRosterInfo(i)
                if name then
                    local cleanName = string.match(name, "([^%-]+)")
                    if cleanName == cleanSender then
                        if rank > 0 then senderIsAuthorized = true end -- 1 = Assistant, 2 = Leader
                        break
                    end
                end
            end
        else
            -- En Party, el líder es el único con autoridad
            if UnitIsGroupLeader(sender) then
                senderIsAuthorized = true
            end
        end
    end

    if not senderIsAuthorized then 
        return 
    end
    
    local success, data = AceSerializer:Deserialize(message)
    if success then
        if type(data) == "table" and data.assignments then
            NoDebuffNoLoot.db.profile.assignments = data.assignments
            NoDebuffNoLoot.db.profile.delegate = data.delegate or ""
        else
            -- Compatibilidad con versiones antiguas
            NoDebuffNoLoot.db.profile.assignments = data
        end
        NoDebuffNoLoot:Print(string.format(L["SYNC_RECEIVED"], sender))
        NoDebuffNoLoot:UpdateTracker()
        if ns.ConfigUI and ns.ConfigUI.Refresh then
            ns.ConfigUI:Refresh()
        end
    end
end

local function GetPresetCandidate(debuff)
    local players = ns.SmartSelection:GetPlayersByClass(debuff.class)
    if #players == 0 then return "" end
    
    if not debuff.talentId or not ns.TalentScanner then
        -- Si no requiere talento, asignamos al primero si hay exactamente 1.
        -- Si hay más de 1, es mejor dejar que el usuario asigne para no tomar decisiones arbitrarias
        if #players == 1 then
            return players[1]
        else
            return ""
        end
    end
    
    local playersWithTalent = {}
    local playersWithoutTalent = {}
    local playersUnknownTalent = {}
    
    for _, pName in ipairs(players) do
        local hasTalent = ns.TalentScanner:HasTalent(pName, debuff.talentId)
        if hasTalent == true then
            table.insert(playersWithTalent, pName)
        elseif hasTalent == false then
            table.insert(playersWithoutTalent, pName)
        else
            table.insert(playersUnknownTalent, pName)
        end
    end
    
    -- 1. Si hay jugadores que sabemos que tienen el talento (óptimo)
    if #playersWithTalent > 0 then
        -- Si hay exactamente 1 jugador con el talento, se lo asignamos
        if #playersWithTalent == 1 then
            return playersWithTalent[1]
        else
            -- Si hay varios con el talento, no decidimos al azar, dejamos vacío para asignación manual
            return ""
        end
    end
    
    -- 2. Si no hay nadie con el talento confirmado pero hay desconocidos (cargando caché)
    if #playersUnknownTalent > 0 then
        -- Si hay exactamente 1 jugador de esa clase, lo asignamos como fallback
        if #players == 1 then
            return players[1]
        end
        return ""
    end
    
    -- 3. Si todos los jugadores no tienen el talento
    if debuff.talentMandatory then
        -- Si es obligatorio, nadie puede tirarlo
        return ""
    else
        -- Si no es obligatorio (ej. FF), cualquiera puede tirarlo. 
        -- Si hay exactamente 1, lo asignamos. Si hay más de uno, dejamos vacío para no elegir al azar.
        if #players == 1 then
            return players[1]
        else
            return ""
        end
    end
end

function Assignments:LoadPreset()
    -- Solo el líder, asistentes, delegado, o si está desactivada la sincronización (Modo Local)
    local canEdit = false
    if NoDebuffNoLoot.db.profile.disableSync then
        canEdit = true
    else
        local myName = UnitName("player")
        local delegate = NoDebuffNoLoot.db.profile.delegate or ""
        local cleanMyName = string.match(myName, "([^%-]+)")
        local cleanDelegate = string.match(delegate, "([^%-]+)")
        
        local isLeader = UnitIsGroupLeader("player")
        local isAssistant = UnitIsGroupAssistant("player")
        local isDelegate = (cleanDelegate ~= "" and cleanMyName == cleanDelegate)
        
        if not (IsInRaid() or IsInGroup()) or isLeader or isAssistant or isDelegate then
            canEdit = true
        end
    end
    
    if not canEdit then
        NoDebuffNoLoot:Print(L["LOAD_PRESET_NO_PERMS"] or "No tienes permisos para modificar las asignaciones.")
        return
    end

    -- Limpiar asignaciones actuales
    NoDebuffNoLoot.db.profile.assignments = {}
    
    -- Obtener debuffs recomendados para la composición de la banda actual
    local available = ns.SmartSelection:GetAvailableDebuffs()
    for _, debuff in ipairs(available) do
        local primaryPlayer = GetPresetCandidate(debuff)
        
        table.insert(NoDebuffNoLoot.db.profile.assignments, {
            spellId = debuff.id,
            primary = primaryPlayer,
            backup = "",
            combatDelay = 3
        })
    end
    
    NoDebuffNoLoot:Print(L["LOAD_PRESET_SUCCESS"] or "Cargado preset por defecto para la composición actual.")
    NoDebuffNoLoot:UpdateTracker()
    
    if not NoDebuffNoLoot.db.profile.disableSync then
        self:PushConfiguration()
    end
    
    if ns.ConfigUI and ns.ConfigUI.Refresh then
        ns.ConfigUI:Refresh()
    end
end
