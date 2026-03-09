local addonName, ns = ...
ns.ConfigUI = {}

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")
local mainFrame

-- Helpers
local function DrawLine(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.2)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 10, yOffset)
    line:SetPoint("TOPRIGHT", -10, yOffset)
    return line
end

-- Function to build the row
local function CreateAssignmentRow(parent, index, data, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(parent:GetWidth() - 20, 30)
    
    -- Col 1: Spell ID/Name
    local spellEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    spellEdit:SetSize(120, 20)
    spellEdit:SetPoint("LEFT", 5, 0)
    spellEdit:SetAutoFocus(false)
    
    -- Icon preview
    local iconTx = row:CreateTexture(nil, "ARTWORK")
    iconTx:SetSize(20, 20)
    iconTx:SetPoint("LEFT", spellEdit, "RIGHT", 5, 0)
    
    -- Col 2: Primary
    local primaryEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    primaryEdit:SetSize(100, 20)
    primaryEdit:SetPoint("LEFT", iconTx, "RIGHT", 15, 0)
    primaryEdit:SetAutoFocus(false)
    
    -- Col 3: Backup
    local backupEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    backupEdit:SetSize(100, 20)
    backupEdit:SetPoint("LEFT", primaryEdit, "RIGHT", 10, 0)
    backupEdit:SetAutoFocus(false)
    
    -- Col 4: Delay
    local delayEdit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    delayEdit:SetSize(40, 20)
    delayEdit:SetPoint("LEFT", backupEdit, "RIGHT", 25, 0)
    delayEdit:SetAutoFocus(false)
    delayEdit:SetNumeric(true)
    delayEdit:SetMaxLetters(2)
    
    -- Priority Buttons
    local upBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    upBtn:SetSize(24, 24)
    upBtn:SetPoint("LEFT", delayEdit, "RIGHT", 20, 0)
    upBtn:SetText("^")
    
    local downBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    downBtn:SetSize(24, 24)
    downBtn:SetPoint("LEFT", upBtn, "RIGHT", 2, 0)
    downBtn:SetText("v")

    -- Delete Button
    local delBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
    delBtn:SetSize(24, 24)
    delBtn:SetPoint("LEFT", downBtn, "RIGHT", 10, 0)
    delBtn:SetText("X")
    
    -- Auto-save logic
    local function SaveData()
        if not row.data then return end
        local sId = tonumber(spellEdit:GetText())
        -- Fallback to search dictionary if text was used
        if not sId and spellEdit:GetText() ~= "" then
             sId = ns.Data.GetSpellID(spellEdit:GetText())
        end
        
        if sId then
            row.data.spellId = sId
            row.data.primary = primaryEdit:GetText()
            row.data.backup = backupEdit:GetText()
            
            local delayVal = tonumber(delayEdit:GetText())
            row.data.combatDelay = delayVal and delayVal or 3
            
            iconTx:SetTexture(GetSpellTexture(sId))
            NoDebuffNoLoot:UpdateTracker()
            if ns.Assignments and ns.Assignments.PushConfiguration then
                ns.Assignments:PushConfiguration()
            end
        else
            -- Si limpian la caja, permitimos guardarlo como un slot vacio
            if spellEdit:GetText() == "" then
                row.data.spellId = nil
                row.data.primary = primaryEdit:GetText()
                row.data.backup = backupEdit:GetText()
                row.data.combatDelay = tonumber(delayEdit:GetText()) or 3
                iconTx:SetTexture(nil)
            end
        end
    end
    
    spellEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus(); SaveData() end)
    primaryEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus(); SaveData() end)
    backupEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus(); SaveData() end)
    delayEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus(); SaveData() end)
    
    -- Trigger save on focus lost as well for better UX
    spellEdit:SetScript("OnEditFocusLost", SaveData)
    primaryEdit:SetScript("OnEditFocusLost", SaveData)
    backupEdit:SetScript("OnEditFocusLost", SaveData)
    delayEdit:SetScript("OnEditFocusLost", SaveData)
    
    -- Autocomplete logic for party/raid members
    local function AutoCompleteName(editBox, userInput)
        if not userInput then return end
        local text = editBox:GetText()
        if string.len(text) < 2 then return end
        
        local numGroup = GetNumGroupMembers()
        local prefix = string.lower(text)
        local match = nil
        
        if IsInRaid() then
            for i=1, numGroup do
                local name = GetRaidRosterInfo(i)
                if name and string.match(string.lower(name), "^" .. prefix) then
                    match = name
                    break
                end
            end
        elseif numGroup > 0 then
            -- Fallback to party
            for i=1, numGroup - 1 do
                local name = UnitName("party"..i)
                if name and string.match(string.lower(name), "^" .. prefix) then
                    match = name
                    break
                end
            end
            -- Don't forget the player
            local pName = UnitName("player")
            if string.match(string.lower(pName), "^" .. prefix) then match = pName end
        else
             -- Solo
            local pName = UnitName("player")
            if string.match(string.lower(pName), "^" .. prefix) then match = pName end
        end
        
        if match and match ~= text then
            editBox:SetText(match)
            editBox:HighlightText(string.len(text), string.len(match))
            editBox:SetCursorPosition(string.len(text))
        end
    end
    
    primaryEdit:SetScript("OnTextChanged", function(self, userInput) AutoCompleteName(self, userInput) end)
    backupEdit:SetScript("OnTextChanged", function(self, userInput) AutoCompleteName(self, userInput) end)

    function row:Update(newIndex, newData, newY)
        self.idx = newIndex
        self.data = newData
        self:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, newY)
        
        spellEdit:SetText(newData.spellId and tostring(newData.spellId) or "")
        if newData.spellId then
            iconTx:SetTexture(GetSpellTexture(newData.spellId))
        else
            iconTx:SetTexture(nil)
        end
        primaryEdit:SetText(newData.primary or "")
        backupEdit:SetText(newData.backup or "")
        delayEdit:SetText(tostring(newData.combatDelay or 3))
    end
    
    upBtn:SetScript("OnClick", function()
        if row.idx > 1 then
            local list = NoDebuffNoLoot.db.profile.assignments
            local i = row.idx
            list[i], list[i-1] = list[i-1], list[i]
            ns.ConfigUI:Refresh()
            NoDebuffNoLoot:UpdateTracker()
        end
    end)
    
    downBtn:SetScript("OnClick", function()
        local list = NoDebuffNoLoot.db.profile.assignments
        local i = row.idx
        if i < #list then
            list[i], list[i+1] = list[i+1], list[i]
            ns.ConfigUI:Refresh()
            NoDebuffNoLoot:UpdateTracker()
        end
    end)

    delBtn:SetScript("OnClick", function()
        table.remove(NoDebuffNoLoot.db.profile.assignments, row.idx)
        ns.ConfigUI:Refresh()
        NoDebuffNoLoot:UpdateTracker()
    end)

    row:Update(index, data, yOffset)
    return row
end

local function AnnounceAssignments()
    local list = NoDebuffNoLoot.db.profile.assignments
    if not list or #list == 0 then return end
    
    local chatType = "SAY"
    if IsInRaid() then
        if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
            chatType = "RAID_WARNING"
        else
            print("|cFFFF0000[NDNL]|r " .. (L["ANN_REQ_PRIVILEGE"] or "You must be Raid Leader or Assistant to announce."))
            return
        end
    elseif IsInGroup() then
        chatType = "PARTY"
    end
    
    for _, data in ipairs(list) do
        if data.spellId then
            local spellName = GetSpellInfo(data.spellId) or ("Spell " .. data.spellId)
            local primary = (data.primary and data.primary ~= "") and data.primary or "None"
            local backup = (data.backup and data.backup ~= "") and data.backup or "None"
            
            local rwMsg = string.format(L["ANN_RW_FORMAT"] or "%s - %s - %s", spellName, primary, backup)
            
            if chatType ~= "SAY" then
                SendChatMessage(rwMsg, chatType)
            else
                print("|cFFFF0000[NDNL]|r " .. rwMsg)
            end
            
            local myName = UnitName("player")
            if data.primary and data.primary ~= "" and data.primary ~= myName then
                SendChatMessage(string.format(L["ANN_WISP_PRIMARY"] or "You are PRIMARY for %s", spellName), "WHISPER", nil, data.primary)
            end
            if data.backup and data.backup ~= "" and data.backup ~= myName then
                SendChatMessage(string.format(L["ANN_WISP_BACKUP"] or "You are BACKUP for %s", spellName), "WHISPER", nil, data.backup)
            end
        end
    end
end

function ns.ConfigUI:Init()
    if mainFrame then return end
    
    mainFrame = CreateFrame("Frame", "NDNL_ConfigUI", UIParent, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(600, 400)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainFrame.title:SetPoint("CENTER", mainFrame.TitleBg, "CENTER", 0, 0)
    mainFrame.title:SetText(L["CONFIG_TITLE"])
    
    -- Headers
    local hTarget = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hTarget:SetPoint("TOPLEFT", 30, -35)
    hTarget:SetText(L["CONFIG_SPELL"])
    
    local hPrimary = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hPrimary:SetPoint("LEFT", hTarget, "RIGHT", 60, 0)
    hPrimary:SetText(L["CONFIG_PRIMARY"])
    
    local hBackup = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hBackup:SetPoint("LEFT", hPrimary, "RIGHT", 65, 0)
    hBackup:SetText(L["CONFIG_BACKUP"])
    
    local hDelay = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hDelay:SetPoint("LEFT", hBackup, "RIGHT", 70, 0)
    hDelay:SetText(L["CONFIG_DELAY"])
    
    local hPrio = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hPrio:SetPoint("LEFT", hDelay, "RIGHT", 35, 0)
    hPrio:SetText(L["CONFIG_PRIORITY"])
    
    DrawLine(mainFrame, -55)
    
    -- Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -60)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight())
    scrollFrame:SetScrollChild(content)
    
    mainFrame.content = content
    mainFrame.rows = {}
    
    -- Add Button
    local addBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    addBtn:SetSize(120, 25)
    addBtn:SetPoint("BOTTOM", -70, 10)
    addBtn:SetText(L["CONFIG_ADD_NEW"])
    addBtn:SetScript("OnClick", function()
        table.insert(NoDebuffNoLoot.db.profile.assignments, { spellId = nil, primary = "", backup = "" })
        ns.ConfigUI:Refresh()
    end)
    
    -- Announce Button
    local annBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    annBtn:SetSize(120, 25)
    annBtn:SetPoint("BOTTOM", 70, 10)
    annBtn:SetText(L["CONFIG_ANNOUNCE"])
    annBtn:SetScript("OnClick", function()
        AnnounceAssignments()
    end)
    
    self:Refresh()
    mainFrame:Hide()
end

function ns.ConfigUI:Refresh()
    if not mainFrame then self:Init() end
    
    for _, row in pairs(mainFrame.rows) do
        row:Hide()
    end
    
    local yOffset = -5
    local list = NoDebuffNoLoot.db.profile.assignments or {}
    
    for i, data in ipairs(list) do
        if not mainFrame.rows[i] then
            mainFrame.rows[i] = CreateAssignmentRow(mainFrame.content, i, data, yOffset)
        else
            mainFrame.rows[i]:Update(i, data, yOffset)
            mainFrame.rows[i]:Show()
        end
        yOffset = yOffset - 35
    end
    
    mainFrame.content:SetHeight(math.abs(yOffset))
end

function ns.ConfigUI:Show()
    if not mainFrame then self:Init() end
    self:Refresh()
    mainFrame:Show()
end
