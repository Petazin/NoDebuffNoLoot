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
            local localizedName, _, spellIcon = GetSpellInfo(info.id)
            local displayName = localizedName or name
            
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

-- Obtener jugadores de la clase del debuff que posean el talento óptimo/mejorado
function ns.SmartSelection:GetOptimalPlayersForDebuff(spellId)
    local debuffInfo = nil
    for name, info in pairs(ns.Data.Debuffs) do
        if info.id == spellId then
            debuffInfo = info
            break
        end
    end
    
    if not debuffInfo or not debuffInfo.talentId then return {} end
    
    local players = self:GetPlayersByClass(debuffInfo.class)
    local optimal = {}
    
    if ns.TalentScanner then
        for _, playerName in ipairs(players) do
            if ns.TalentScanner:HasTalent(playerName, debuffInfo.talentId) then
                table.insert(optimal, playerName)
            end
        end
    end
    
    return optimal
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
        
        -- Fallback suave: El validador ya no arroja error de talento faltante (MISSING_TALENT).
        -- El talento ahora se valida dinámicamente en el HUD y en el recomendador de optimizaciones.
    end
    
    return true
end
