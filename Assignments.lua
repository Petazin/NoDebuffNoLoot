local addonName, ns = ...
local Assignments = {}
ns.Assignments = Assignments

-- Función para asignar un debuff a un jugador
function Assignments:Set(debuffName, playerName)
    NoDebuffNoLoot.db.profile.assignments[debuffName] = playerName
    NoDebuffNoLoot:Print(string.format("Asignado %s a %s", debuffName, playerName))
end

-- Función para limpiar una asignación
function Assignments:Clear(debuffName)
    NoDebuffNoLoot.db.profile.assignments[debuffName] = nil
end

-- TODO: Implementar sincronización vía AceComm
function Assignments:PushConfiguration()
    -- Serializar y enviar a RAID/BATTLEGROUND
end
