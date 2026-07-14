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
