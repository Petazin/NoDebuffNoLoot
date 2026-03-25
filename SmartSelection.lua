local addonName, ns = ...
ns.SmartSelection = {}

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

-- Obtener las clases presentes en el grupo actual
function ns.SmartSelection:GetActiveClasses()
    local classes = {}
    local numGroup = GetNumGroupMembers()
    
    if numGroup > 0 then
        for i = 1, numGroup do
            local unit = IsInRaid() and "raid"..i or "party"..i
            if i == numGroup and not IsInRaid() then unit = "player" end
            
            local _, class = UnitClass(unit)
            if class then classes[class] = true end
        end
    else
        local _, class = UnitClass("player")
        classes[class] = true
    end
    
    return classes
end

-- Filtrar la lista de debuffs base según la composición y talentos
function ns.SmartSelection:GetAvailableDebuffs()
    local activeClasses = self:GetActiveClasses()
    local available = {}
    
    for name, info in pairs(ns.Data.Debuffs) do
        if activeClasses[info.class] then
            -- Verificación opcional de talentos (si al menos alguien de esa clase lo tiene)
            -- Por ahora, si la clase existe, mostramos el debuff como sugerencia
            local localizedName, _, spellIcon = GetSpellInfo(info.id)
            local displayName = localizedName or name
            if info.talentId then
                displayName = displayName .. " (" .. L["IMPROVED"] .. ")"
            end
            
            table.insert(available, {
                name = displayName,
                id = info.id,
                class = info.class,
                priority = info.priority,
                talentId = info.talentId,
                icon = spellIcon or info.icon
            })
        end
    end
    
    -- Ordenar por prioridad (S > A > B)
    table.sort(available, function(a, b)
        return a.priority < b.priority
    end)
    
    return available
end

-- Obtener jugadores de una clase específica en el grupo
function ns.SmartSelection:GetPlayersByClass(targetClass)
    local players = {}
    local numGroup = GetNumGroupMembers()
    
    local function CheckUnit(unit)
        local name = UnitName(unit)
        local _, class = UnitClass(unit)
        if class == targetClass then
            table.insert(players, name)
        end
    end

    if numGroup > 0 then
        for i = 1, numGroup do
            local unit = IsInRaid() and "raid"..i or "party"..i
            if i == numGroup and not IsInRaid() then unit = "player" end
            CheckUnit(unit)
        end
    else
        CheckUnit("player")
    end
    
    return players
end

-- Validar una asignación específica
function ns.SmartSelection:Validate(playerName, spellId)
    local debuffInfo = nil
    for name, info in pairs(ns.Data.Debuffs) do
        if info.id == spellId then
            debuffInfo = info
            break
        end
    end
    
    if not debuffInfo then return true end -- Spell desconocido, no validamos
    
    -- Verificar clase
    -- Nota: GetPlayerClass es costoso o requiere que el PJ esté en el grupo
    local unit = nil
    if IsInRaid() then
        for i=1, GetNumGroupMembers() do
            if UnitName("raid"..i) == playerName then unit = "raid"..i; break end
        end
    else
        for i=1, GetNumGroupMembers() do
            local u = (i == GetNumGroupMembers()) and "player" or "party"..i
            if UnitName(u) == playerName then unit = u; break end
        end
    end
    
    if unit then
        local _, class = UnitClass(unit)
        if class ~= debuffInfo.class then
            return false, "WRONG_CLASS"
        end
        
        -- Verificar talento si aplica
        if debuffInfo.talentId and ns.TalentScanner then
            local hasTalent = ns.TalentScanner:HasTalent(playerName, debuffInfo.talentId)
            if hasTalent == false then
                return false, "MISSING_TALENT"
            end
        end
    end
    
    return true
end
