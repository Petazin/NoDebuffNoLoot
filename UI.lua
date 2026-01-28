local addonName, ns = ...
local UI = {}
ns.UI = UI

-- TODO: Implementar creación del marco (Frame) principal del HUD
function UI:Init()
    -- Crear frame
end

-- Actualizar el estado visual de un debuff en el HUD
function UI:SetStatus(debuffName, status, timeLeft)
    -- status: "ACTIVE", "EXPIRED", "MISSING"
    -- Lógica de cambio de color y texto
end
