local addonName, ns = ...
local Assignments = {}
ns.Assignments = Assignments

local AceSerializer = LibStub("AceSerializer-3.0")

-- Prefijo para AceComm
local COMM_PREFIX = "NDNL_SYNC"

-- Función para asignar un debuff a un jugador
function Assignments:Set(debuffName, playerName)
    NoDebuffNoLoot.db.profile.assignments[debuffName] = playerName
    NoDebuffNoLoot:Print(string.format("Asignado %s a %s", debuffName, playerName))
    -- Auto-push al cambiar algo si estamos en raid
    if IsInRaid() or IsInGroup() then
        self:PushConfiguration()
    end
end

-- Función para limpiar una asignación
function Assignments:Clear(debuffName)
    NoDebuffNoLoot.db.profile.assignments[debuffName] = nil
end

-- Sincronización vía AceComm
function Assignments:PushConfiguration()
    if not (IsInRaid() or IsInGroup()) then return end
    
    local data = NoDebuffNoLoot.db.profile.assignments
    local serialized = AceSerializer:Serialize(data)
    
    NoDebuffNoLoot:SendCommMessage(COMM_PREFIX, serialized, "RAID")
    NoDebuffNoLoot:Print("Configuración enviada a la raid.")
end

function Assignments:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= COMM_PREFIX or sender == UnitName("player") then return end
    
    local success, data = AceSerializer:Deserialize(message)
    if success then
        NoDebuffNoLoot.db.profile.assignments = data
        NoDebuffNoLoot:Print(string.format("Configuración recibida de %s.", sender))
        NoDebuffNoLoot:UpdateTracker()
    end
end
