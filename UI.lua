local addonName, ns = ...
local UI = {}
ns.UI = UI

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

local frame

-- Función de utilidad para obtener el color de clase del jugador
local function GetPlayerClassColor(playerName)
    if not playerName or playerName == "" then return 1, 1, 1 end
    
    if playerName == UnitName("player") then
        local _, classFile = UnitClass("player")
        if classFile and RAID_CLASS_COLORS[classFile] then 
            return RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b
        end
    end
    
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitName(unit) == playerName then
                local _, classFile = UnitClass(unit)
                if classFile and RAID_CLASS_COLORS[classFile] then 
                    return RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b
                end
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            local unit = "party" .. i
            if UnitName(unit) == playerName then
                local _, classFile = UnitClass(unit)
                if classFile and RAID_CLASS_COLORS[classFile] then 
                    return RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b
                end
            end
        end
    end
    
    -- Color gris claro/blanco por defecto para PJs desconocidos o desconectados
    return 0.8, 0.8, 0.8
end

function UI:Init()
    if frame then return end
    
    frame = CreateFrame("Frame", "NoDebuffNoLootHUD", UIParent)
    local width = (NoDebuffNoLoot and NoDebuffNoLoot.db and NoDebuffNoLoot.db.profile.hud.width) or 220
    frame:SetSize(width, 50)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Fondo semi-transparente sutil del HUD
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 0.3)
    
    frame.rows = {}
    frame:Hide()
    
    -- Aplicar estado inicial de bloqueo y escala
    if NoDebuffNoLoot and NoDebuffNoLoot.db then
        self:SetLocked(NoDebuffNoLoot.db.profile.hud.locked)
        if NoDebuffNoLoot.db.profile.hud.scale then
            frame:SetScale(NoDebuffNoLoot.db.profile.hud.scale)
        end
    end
end

function UI:SetLocked(locked)
    if not frame then return end
    frame:SetMovable(not locked)
    frame:EnableMouse(not locked)
    if locked then
        frame:SetScript("OnDragStart", nil)
        frame:SetScript("OnDragStop", nil)
    else
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    end
end

function UI:FlashScreen()
    if not NoDebuffNoLoot.db.profile.alerts.visual_flash then return end
    
    local f = _G["NDNL_FlashFrame"]
    if not f then
        f = CreateFrame("Frame", "NDNL_FlashFrame", UIParent)
        f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:SetAllPoints(UIParent)
        local thickness = 50 
        local alpha = 0.6
        
        local function CreateBorder(point1, point2, w, h)
            local t = f:CreateTexture(nil, "BACKGROUND")
            t:SetColorTexture(0, 1, 1, alpha)
            t:SetBlendMode("ADD")
            t:SetPoint(point1)
            t:SetPoint(point2)
            if w then t:SetWidth(w) end
            if h then t:SetHeight(h) end
            return t
        end
        
        f.top = CreateBorder("TOPLEFT", "TOPRIGHT", nil, thickness)
        f.bottom = CreateBorder("BOTTOMLEFT", "BOTTOMRIGHT", nil, thickness)
        f.left = CreateBorder("TOPLEFT", "BOTTOMLEFT", thickness, nil)
        f.right = CreateBorder("TOPRIGHT", "BOTTOMRIGHT", thickness, nil)
        
        f:SetAlpha(0)
    end
    
    UIFrameFlash(f, 0.5, 0.5, 2.0, false, 0, 0)
    
    if NoDebuffNoLoot.db.profile.alerts.sound then
        PlaySound(8959) -- RAID_WARNING
    end
end

function UI:Clear()
    if not frame then return end
    for _, row in pairs(frame.rows) do
        row:Hide()
    end
    frame:Hide()
end

function UI:SetStatus(debuffId, debuffName, status, timeLeft, assignedPlayer, backupPlayer, iconPath, talentError, hasTalent)
    if hasTalent then
        debuffName = debuffName .. " (" .. (L["IMPROVED"] or "Mejorado") .. ")"
    end
    
    if not frame then self:Init() end
    frame:Show()
    
    local row = frame.rows[debuffId]
    if not row then
        row = CreateFrame("Frame", nil, frame)
        row:SetSize(220, 20)
        
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", 3, 0)
        row.icon = icon
        
        -- Borde negro fino para el icono
        local iconBorder = row:CreateTexture(nil, "BACKGROUND")
        iconBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        iconBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        iconBorder:SetColorTexture(0, 0, 0, 1)
        row.iconBorder = iconBorder
        
        -- StatusBar que sirve de fondo y progreso visual
        local statusBar = CreateFrame("StatusBar", nil, row)
        statusBar:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        statusBar:SetPoint("RIGHT", row, "RIGHT", -3, 0)
        statusBar:SetHeight(16)
        statusBar:SetStatusBarTexture("Interface\\ChatFrame\\ChatFrameBackground")
        statusBar:GetStatusBarTexture():SetHorizTile(false)
        statusBar:GetStatusBarTexture():SetVertTile(false)
        
        local barBg = statusBar:CreateTexture(nil, "BACKGROUND")
        barBg:SetAllPoints(statusBar)
        barBg:SetColorTexture(0.05, 0.05, 0.05, 0.5)
        statusBar.bg = barBg
        row.statusBar = statusBar
        
        -- Textos sobre la barra
        local spellText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        spellText:SetPoint("LEFT", statusBar, "LEFT", 5, 0)
        row.spellText = spellText
        
        local playerText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.playerText = playerText
        
        local statusText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        statusText:SetPoint("RIGHT", statusBar, "RIGHT", -5, 0)
        row.statusText = statusText
        
        -- Textura de brillo/alerta (Glow)
        local glow = row:CreateTexture(nil, "OVERLAY")
        glow:SetColorTexture(1, 0.2, 0, 0.35) -- Rojo/Naranja transparente
        glow:SetBlendMode("ADD")
        glow:SetAllPoints(statusBar)
        glow:Hide()
        row.glow = glow
        
        -- Icono de error de talento
        local warnIcon = row:CreateTexture(nil, "OVERLAY")
        warnIcon:SetSize(12, 12)
        warnIcon:SetPoint("RIGHT", statusText, "LEFT", -4, 0)
        warnIcon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        warnIcon:Hide()
        row.warnIcon = warnIcon
        
        frame.rows[debuffId] = row
    end
    
    -- Manejar error de talento (icono de advertencia)
    if talentError then
        row.warnIcon:Show()
    else
        row.warnIcon:Hide()
    end
    
    row:Show()
    row.icon:SetTexture(iconPath)
    
    -- Configurar modo de visualización del nombre de hechizo
    local showSpell = true
    if NoDebuffNoLoot and NoDebuffNoLoot.db then
        showSpell = NoDebuffNoLoot.db.profile.hud.showSpellName ~= false
    end
    
    if showSpell then
        row.spellText:Show()
        row.spellText:SetText(debuffName)
        row.playerText:ClearAllPoints()
        row.playerText:SetPoint("LEFT", row.spellText, "RIGHT", 6, 0)
    else
        row.spellText:Hide()
        row.spellText:SetText("")
        row.playerText:ClearAllPoints()
        row.playerText:SetPoint("LEFT", row.statusBar, "LEFT", 5, 0)
    end
    
    -- Colorear el nombre de los jugadores con colores de clase
    local pr, pg, pb = GetPlayerClassColor(assignedPlayer)
    local classColorCode = string.format("|cFF%02x%02x%02x", pr*255, pg*255, pb*255)
    
    local backupStr = ""
    if backupPlayer and backupPlayer ~= "" then
        local br, bg, bb = GetPlayerClassColor(backupPlayer)
        backupStr = string.format(" | |cFF%02x%02x%02x%s|r", br*255, bg*255, bb*255, backupPlayer)
    end
    
    row.playerText:SetText(string.format("%s%s|r%s", classColorCode, assignedPlayer, backupStr))
    
    -- Configurar Barra de Estado según el estado
    if status == "MISSING" then
        row.statusBar:SetMinMaxValues(0, 1)
        row.statusBar:SetValue(1)
        row.statusBar:SetStatusBarColor(0.8, 0.1, 0.1, 0.6) -- Rojo sutil
        row.statusText:SetText("|cFFFF0000" .. (L["STATUS_MISSING"] or "Missing") .. "|r")
        
        if not row.glow:IsShown() then
            row.glow:Show()
            UIFrameFlash(row.glow, 0.5, 0.5, -1, true, 0, 0)
        end
    elseif status == "PENDING" then
        row.statusBar:SetMinMaxValues(0, 1)
        row.statusBar:SetValue(1)
        row.statusBar:SetStatusBarColor(0.8, 0.6, 0.1, 0.5) -- Amarillo/Naranja sutil
        row.statusText:SetText("|cFFFFFF00" .. (L["STATUS_MISSING"] or "Missing") .. "|r")
        
        row.glow:Hide()
        UIFrameFlashStop(row.glow)
    elseif status == "IDLE" then
        row.statusBar:SetMinMaxValues(0, 1)
        row.statusBar:SetValue(1)
        row.statusBar:SetStatusBarColor(0.2, 0.2, 0.2, 0.4) -- Gris oscuro
        row.statusText:SetText("|cFF888888" .. (L["STATUS_IDLE"] or "Waiting Target...") .. "|r")
        
        row.glow:Hide()
        UIFrameFlashStop(row.glow)
    else -- ACTIVE
        row.glow:Hide()
        UIFrameFlashStop(row.glow)
        
        local duration = 30
        if timeLeft > duration then duration = timeLeft end
        row.statusBar:SetMinMaxValues(0, duration)
        row.statusBar:SetValue(timeLeft)
        row.statusBar:SetStatusBarColor(pr, pg, pb, 0.4) -- Color de la clase del principal
        
        if timeLeft < 5 then
            row.statusText:SetText(string.format("|cFFFFFF00%.1fs|r", timeLeft))
        else
            row.statusText:SetText(string.format("|cFF00FF00%.1fs|r", timeLeft))
        end
    end
    
    self:UpdateLayout()
end

function UI:HideRow(debuffName)
    if not frame or not frame.rows[debuffName] then return end
    frame.rows[debuffName]:Hide()
    self:UpdateLayout()
end

function UI:UpdateLayout()
    if not frame then return end
    
    -- 1. Crear un set de IDs de hechizos asignados actualmente en la base de datos
    local activeIds = {}
    if NoDebuffNoLoot and NoDebuffNoLoot.db and NoDebuffNoLoot.db.profile.assignments then
        for _, assignment in ipairs(NoDebuffNoLoot.db.profile.assignments) do
            if assignment.spellId then
                activeIds[assignment.spellId] = true
            end
        end
    end
    
    -- 2. Ocultar cualquier fila en memoria cuyo ID ya no esté asignado
    for id, r in pairs(frame.rows) do
        if not activeIds[id] then
            r:Hide()
        end
    end
    
    -- Escala y Ancho desde la DB
    local scale = 1.0
    local width = 220
    if NoDebuffNoLoot and NoDebuffNoLoot.db then
        scale = NoDebuffNoLoot.db.profile.hud.scale or 1.0
        width = NoDebuffNoLoot.db.profile.hud.width or 220
    end
    
    frame:SetScale(scale)
    frame:SetWidth(width)
    
    -- 3. Reposicionar las filas activas y visibles
    local i = 0
    if NoDebuffNoLoot and NoDebuffNoLoot.db and NoDebuffNoLoot.db.profile.assignments then
        for _, assignment in ipairs(NoDebuffNoLoot.db.profile.assignments) do
            local debuffId = assignment.spellId
            if debuffId and frame.rows[debuffId] then
                local r = frame.rows[debuffId]
                if r:IsShown() then
                    r:ClearAllPoints()
                    r:SetPoint("TOP", frame, "TOP", 0, -i * 20)
                    r:SetWidth(width)
                    if r.statusBar then
                        r.statusBar:SetWidth(width - 25)
                    end
                    i = i + 1
                end
            end
        end
    end
    
    -- 4. Ajustar el tamaño del frame contenedor o esconderlo si no hay filas
    if i == 0 then
        frame:Hide()
    else
        frame:SetHeight(math.max(20, i * 20))
    end
end

