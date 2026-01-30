local addonName, ns = ...
local UI = {}
ns.UI = UI

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

local frame

function UI:Init()
    if frame then return end
    
    frame = CreateFrame("Frame", "NoDebuffNoLootHUD", UIParent)
    frame:SetSize(200, 50)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    -- Fondo semi-transparente
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 0.5)
    
    frame.rows = {}
    frame:Hide()
end

function UI:Clear()
    if not frame then return end
    for _, row in pairs(frame.rows) do
        row:Hide()
    end
    frame:Hide()
end

function UI:SetStatus(debuffName, status, timeLeft, assignedPlayer, iconPath)
    if not frame then self:Init() end
    frame:Show()
    
    local row = frame.rows[debuffName]
    if not row then
        row = CreateFrame("Frame", nil, frame)
        row:SetSize(200, 20)
        
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", 5, 0)
        row.icon = icon
        
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        row.text = text
        
        frame.rows[debuffName] = row
    end
    
    row:Show()
    row.icon:SetTexture(iconPath)
    
    if status == "MISSING" then
        color = "|cFFFF0000" -- Rojo
        statusText = L["STATUS_MISSING"]
    elseif timeLeft < 5 then
        color = "|cFFFFFF00" -- Amarillo
        statusText = string.format("%s: %.1fs", L["STATUS_ACTIVE"], timeLeft)
    else
        color = "|cFF00FF00" -- Verde
        statusText = string.format("%s: %.1fs", L["STATUS_ACTIVE"], timeLeft)
    end
    
    row.text:SetText(string.format("%s%s (%s)|r - %s", color, debuffName, assignedPlayer, statusText))
    
    -- Ajustar posiciones de filas
    local i = 0
    for _, r in pairs(frame.rows) do
        if r:IsShown() then
            r:SetPoint("TOP", frame, "TOP", 0, -i * 20)
            i = i + 1
        end
    end
    frame:SetHeight(math.max(20, i * 20))
end
