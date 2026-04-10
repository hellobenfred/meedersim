----------------------------------------------------------------------
-- MeederSIM - Minimap Button + visuelles Hub-Fenster
----------------------------------------------------------------------

function MeederSIM:CreateMinimapButton()
    local btn = CreateFrame("Button", "MeederSIMMinimapBtn", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    btn:SetMovable(true)

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    icon:SetPoint("CENTER")

    local angle = (MeederSIMDB and MeederSIMDB.minimapAngle) or 220
    local radius = 80

    local function UpdatePos()
        btn:SetPoint("CENTER", Minimap, "CENTER",
            radius * math.cos(math.rad(angle)),
            radius * math.sin(math.rad(angle)))
    end
    UpdatePos()

    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function() btn.dragging = true end)
    btn:SetScript("OnDragStop", function()
        btn.dragging = false
        local mx, my = Minimap:GetCenter()
        local bx, by = btn:GetCenter()
        angle = math.deg(math.atan2(by - my, bx - mx))
        if MeederSIMDB then MeederSIMDB.minimapAngle = angle end
        UpdatePos()
    end)
    btn:SetScript("OnUpdate", function()
        if btn.dragging then
            local mx, my = Minimap:GetCenter()
            local s = UIParent:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            angle = math.deg(math.atan2(cy/s - my, cx/s - mx))
            UpdatePos()
        end
    end)

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function() MeederSIM:ToggleHub() end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cff00ccffMeederSIM|r by IT-Meeder.de")
        GameTooltip:AddLine("Klick: Übersicht öffnen", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.minimapBtn = btn
end

----------------------------------------------------------------------
-- Hub-Fenster (visuelles Hauptmenü)
----------------------------------------------------------------------
local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

function MeederSIM:ToggleHub()
    if self.hubFrame and self.hubFrame:IsShown() then
        self.hubFrame:Hide()
    else
        self:ShowHub()
    end
end

function MeederSIM:ShowHub()
    if not self.hubFrame then
        self:CreateHubFrame()
    end
    self:UpdateHubFrame()
    self.hubFrame:Show()
end

function MeederSIM:CreateHubFrame()
    local f = CreateFrame("Frame", "MeederSIMHubFrame", UIParent, "BackdropTemplate")
    f:SetSize(360, 480)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetBackdrop(BACKDROP)

    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -2, -2)

    -- Header with branding
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("|cff00ccffMeederSIM|r")

    local subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText("|cff888888by IT-Meeder.de  v" .. self.version .. " | Support: Littlepink-Arthas|r")

    -- Character info box
    local charBg = f:CreateTexture(nil, "ARTWORK")
    charBg:SetPoint("TOPLEFT", 12, -48)
    charBg:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    charBg:SetHeight(50)
    charBg:SetColorTexture(0.1, 0.1, 0.15, 0.8)

    f.charName = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.charName:SetPoint("TOPLEFT", 20, -52)

    f.charDetails = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.charDetails:SetPoint("TOPLEFT", 20, -70)

    -- Stats bar
    f.statsBar = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.statsBar:SetPoint("TOPLEFT", 20, -84)

    -- Separator
    local sep1 = f:CreateTexture(nil, "ARTWORK")
    sep1:SetHeight(1)
    sep1:SetPoint("TOPLEFT", 12, -104)
    sep1:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    sep1:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- Menu buttons with icons
    local y = -114

    local function AddMenuButton(iconPath, label, desc, onClick)
        local row = CreateFrame("Button", nil, f)
        row:SetSize(336, 40)
        row:SetPoint("TOPLEFT", 12, y)

        -- Hover highlight
        local hl = row:CreateTexture(nil, "BACKGROUND")
        hl:SetAllPoints()
        hl:SetColorTexture(0.2, 0.3, 0.5, 0)

        row:SetScript("OnEnter", function() hl:SetColorTexture(0.2, 0.3, 0.5, 0.4) end)
        row:SetScript("OnLeave", function() hl:SetColorTexture(0.2, 0.3, 0.5, 0) end)

        -- Icon
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(28, 28)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(iconPath)

        -- Label
        local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)
        lbl:SetText(label)

        -- Description
        local dsc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        dsc:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -1)
        dsc:SetText("|cff888888" .. desc .. "|r")

        row:SetScript("OnClick", function()
            f:Hide()
            onClick()
        end)

        y = y - 44
    end

    AddMenuButton(
        "Interface\\Icons\\INV_Misc_Gem_Variety_02",
        "|cff00ff00Best in Slot Übersicht|r",
        "BiS-Items für Overall, Raid, M+, Persönlich",
        function() MeederSIM:ShowBiSWindow() end
    )

    AddMenuButton(
        "Interface\\Icons\\INV_Misc_Gear_01",
        "|cffffff00Ausrüstung|r",
        "Alle angezogenen Items mit iLvl anzeigen",
        function() MeederSIM:ShowGearWindow() end
    )

    AddMenuButton(
        "Interface\\Icons\\Spell_Holy_MindSooth",
        "|cff00ccffStat-Gewichtungen|r",
        "Stat-Prioritäten für deinen Spec (Raid & M+)",
        function() MeederSIM:ShowWeightsWindow() end
    )

    AddMenuButton(
        "Interface\\Icons\\INV_Letter_02",
        "|cffff8800SimC Export|r",
        "Gear als SimC-String für Raidbots kopieren",
        function() MeederSIM:ShowExport() end
    )

    AddMenuButton(
        "Interface\\Icons\\INV_Gizmo_01",
        "|cffffffffEinstellungen|r",
        "Tooltip, Benachrichtigungen, BiS konfigurieren",
        function() MeederSIM:OpenSettings() end
    )

    -- Separator
    local sep2 = f:CreateTexture(nil, "ARTWORK")
    sep2:SetHeight(1)
    sep2:SetPoint("TOPLEFT", 12, y - 4)
    sep2:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    sep2:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- Quick stats at bottom
    f.quickBis = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.quickBis:SetPoint("TOPLEFT", 20, y - 18)

    f.quickEnch = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.quickEnch:SetPoint("TOPLEFT", 20, y - 32)

    f.quickTier = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.quickTier:SetPoint("TOPLEFT", 20, y - 46)

    table.insert(UISpecialFrames, "MeederSIMHubFrame")
    f:Hide()
    self.hubFrame = f
end

function MeederSIM:UpdateHubFrame()
    local f = self.hubFrame
    if not f then return end

    -- Character info
    f.charName:SetText("|cffffff00" .. (self.name or "?") .. "|r")
    f.charDetails:SetText((self.spec or "?") .. " " .. (self.class or "?"))

    -- Average iLvl
    local gear = MeederSIMCharDB.gear or {}
    local totalIlvl, count = 0, 0
    for _, g in pairs(gear) do
        if g.ilvl and g.ilvl > 0 then totalIlvl = totalIlvl + g.ilvl; count = count + 1 end
    end
    local avgIlvl = count > 0 and math.floor(totalIlvl / count) or 0
    f.statsBar:SetText("|cff00ccffiLvl " .. avgIlvl .. "|r  |  " .. count .. " Items ausgerüstet")

    -- BiS progress
    self:InitBiS()
    local bis = self:GetActiveBiS()
    local bisHave, bisTotal = 0, 0
    for slotId, bisData in pairs(bis) do
        bisTotal = bisTotal + 1
        local g = gear[slotId]
        local match = g and g.id == bisData.id
        -- Ring/Trinket cross-check
        if not match and g and (slotId == 11 or slotId == 12) then
            local b1, b2 = bis[11], bis[12]
            match = (b1 and g.id == b1.id) or (b2 and g.id == b2.id)
        end
        if not match and g and (slotId == 13 or slotId == 14) then
            local b1, b2 = bis[13], bis[14]
            match = (b1 and g.id == b1.id) or (b2 and g.id == b2.id)
        end
        if match then bisHave = bisHave + 1 end
    end

    local bisColor = bisHave == bisTotal and "|cff00ff00" or "|cffffff00"
    f.quickBis:SetText("BiS: " .. bisColor .. bisHave .. "/" .. bisTotal .. "|r Items ausgerüstet")

    -- Enchant progress
    local enchAudit = self:GetEnchantAudit()
    local enchColor = enchAudit.complete and "|cff00ff00" or "|cffff3333"
    f.quickEnch:SetText("Enchants: " .. enchColor .. #enchAudit.enchanted .. "/" .. enchAudit.total .. "|r Slots verzaubert")

    -- Tier set count
    local tierCount = self:CountTierPieces()
    local tierColor = tierCount >= 4 and "|cff00ff00" or (tierCount >= 2 and "|cffffff00" or "|cffff3333")
    f.quickTier:SetText("Tier-Set: " .. tierColor .. tierCount .. "pc|r ausgerüstet")
end

----------------------------------------------------------------------
-- Gear Window (visuell statt Chat)
----------------------------------------------------------------------
function MeederSIM:ShowGearWindow()
    if not self.gearFrame then
        self:CreateGearFrame()
    end
    self:UpdateGearFrame()
    self.gearFrame:Show()
end

function MeederSIM:CreateGearFrame()
    local f = CreateFrame("Frame", "MeederSIMGearFrame", UIParent, "BackdropTemplate")
    f:SetSize(400, 580)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetBackdrop(BACKDROP)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("|cff00ccffMeederSIM|r - Ausrüstung")

    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -2, -2)

    f.specInfo = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.specInfo:SetPoint("TOPLEFT", 16, -36)

    local SLOT_NAMES = {
        [1]="Kopf",[2]="Hals",[3]="Schulter",[15]="Rücken",[5]="Brust",
        [9]="Handgelenke",[10]="Hände",[6]="Taille",[7]="Beine",[8]="Füße",
        [11]="Ring 1",[12]="Ring 2",[13]="Schmuck 1",[14]="Schmuck 2",
        [16]="Haupthand",[17]="Nebenhand",
    }
    local SLOT_ORDER = {1,2,3,15,5,9,10,6,7,8,11,12,13,14,16,17}

    f.rows = {}
    for i, slotId in ipairs(SLOT_ORDER) do
        local y = -54 - (i - 1) * 28
        local row = {}

        -- Alternating bg
        row.bg = f:CreateTexture(nil, "BACKGROUND")
        row.bg:SetPoint("TOPLEFT", 8, y + 2)
        row.bg:SetPoint("RIGHT", f, "RIGHT", -8, 0)
        row.bg:SetHeight(28)
        row.bg:SetColorTexture(i % 2 == 0 and 0.12 or 0.07, i % 2 == 0 and 0.12 or 0.07, i % 2 == 0 and 0.14 or 0.09, i % 2 == 0 and 0.7 or 0.4)

        -- Icon
        row.icon = f:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(22, 22)
        row.icon:SetPoint("TOPLEFT", 14, y)

        -- Slot name
        row.slot = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.slot:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
        row.slot:SetWidth(80)
        row.slot:SetJustifyH("LEFT")
        row.slot:SetText(SLOT_NAMES[slotId] or slotId)

        -- Item name
        row.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.name:SetPoint("TOPLEFT", 130, y - 1)
        row.name:SetWidth(200)
        row.name:SetJustifyH("LEFT")

        -- iLvl
        row.ilvl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.ilvl:SetPoint("TOPLEFT", 340, y - 1)

        -- Hover for tooltip
        local btn = CreateFrame("Button", nil, f)
        btn:SetPoint("TOPLEFT", 8, y + 2)
        btn:SetPoint("RIGHT", f, "RIGHT", -8, 0)
        btn:SetHeight(28)
        btn.slotId = slotId
        btn:SetScript("OnEnter", function(self)
            local g = (MeederSIMCharDB.gear or {})[self.slotId]
            if g and g.link then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(g.link)
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row.slotId = slotId
        f.rows[i] = row
    end

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOMRIGHT", -12, 10)
    closeBtn:SetText("Schließen")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    table.insert(UISpecialFrames, "MeederSIMGearFrame")
    f:Hide()
    self.gearFrame = f
end

function MeederSIM:UpdateGearFrame()
    local f = self.gearFrame
    if not f then return end

    f.specInfo:SetText((self.spec or "?") .. " " .. (self.class or "?") .. " | " .. (self.name or "?"))

    local gear = MeederSIMCharDB.gear or {}
    for _, row in ipairs(f.rows) do
        local g = gear[row.slotId]
        if g then
            local icon = GetItemIcon and GetItemIcon(g.id)
            if icon then row.icon:SetTexture(icon) else row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end

            local qualityColor = "|cffffffff"
            if g.quality then
                local _, _, _, hex = GetItemQualityColor(g.quality)
                if hex then qualityColor = hex end
            end
            row.name:SetText(qualityColor .. (g.name or "?") .. "|r")
            row.ilvl:SetText("|cffffff00" .. (g.ilvl or 0) .. "|r")
        else
            row.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
            row.name:SetText("|cff555555Leer|r")
            row.ilvl:SetText("")
        end
    end
end

----------------------------------------------------------------------
-- Weights Window (visuell statt Chat)
----------------------------------------------------------------------
function MeederSIM:ShowWeightsWindow()
    if not self.weightsFrame then
        self:CreateWeightsFrame()
    end
    self:UpdateWeightsFrame()
    self.weightsFrame:Show()
end

function MeederSIM:CreateWeightsFrame()
    local f = CreateFrame("Frame", "MeederSIMWeightsFrame", UIParent, "BackdropTemplate")
    f:SetSize(340, 320)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:SetBackdrop(BACKDROP)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("|cff00ccffMeederSIM|r - Stat-Gewichtungen")

    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -2, -2)

    f.specInfo = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.specInfo:SetPoint("TOPLEFT", 16, -36)

    -- Headers
    local hdr = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr:SetPoint("TOPLEFT", 16, -58)
    hdr:SetText("|cff666666Stat|r")

    local hdr2 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr2:SetPoint("TOPLEFT", 140, -58)
    hdr2:SetText("|cff666666Raid|r")

    local hdr3 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr3:SetPoint("TOPLEFT", 230, -58)
    hdr3:SetText("|cff666666M+|r")

    f.statRows = {}

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOMRIGHT", -12, 10)
    closeBtn:SetText("Schließen")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    table.insert(UISpecialFrames, "MeederSIMWeightsFrame")
    f:Hide()
    self.weightsFrame = f
end

function MeederSIM:UpdateWeightsFrame()
    local f = self.weightsFrame
    if not f then return end

    f.specInfo:SetText("|cffffff00" .. (self.spec or "?") .. " " .. (self.class or "?") .. "|r")

    -- Clear old rows
    for _, row in ipairs(f.statRows) do
        row.name:Hide()
        row.raidVal:Hide()
        row.mplusVal:Hide()
        if row.bar then row.bar:Hide() end
    end
    f.statRows = {}

    local weights = self:GetWeights()
    if not weights then return end

    -- Sort stats by raid weight
    local stats = {}
    local raidW = weights.raid or {}
    local mplusW = weights.mythicplus or weights.raid or {}

    local DISPLAY = {
        crit="Crit", haste="Haste", mastery="Mastery", versatility="Vers",
        strength="Strength", agility="Agility", intellect="Intellect",
    }

    for stat, val in pairs(raidW) do
        if DISPLAY[stat] then
            stats[#stats + 1] = { stat = stat, display = DISPLAY[stat], raid = val, mplus = mplusW[stat] or 0 }
        end
    end
    table.sort(stats, function(a, b) return a.raid > b.raid end)

    local y = -72
    for i, s in ipairs(stats) do
        local row = {}

        -- Background bar (visual weight indicator)
        row.bar = f:CreateTexture(nil, "BACKGROUND")
        row.bar:SetPoint("TOPLEFT", 12, y + 1)
        row.bar:SetHeight(18)
        row.bar:SetWidth(math.max(1, s.raid * 300))
        local barR, barG = 0.1, 0.3
        if i == 1 then barR, barG = 0.0, 0.5
        elseif i == 2 then barR, barG = 0.0, 0.4 end
        row.bar:SetColorTexture(barR, barG, 0.6, 0.3)

        -- Stat name
        row.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.name:SetPoint("TOPLEFT", 16, y)
        row.name:SetWidth(120)
        row.name:SetJustifyH("LEFT")
        local color = i == 1 and "|cff00ff00" or (i == 2 and "|cffffff00" or "|cffffffff")
        row.name:SetText(color .. s.display .. (i == 1 and " (Bester!)" or "") .. "|r")

        -- Raid value
        row.raidVal = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.raidVal:SetPoint("TOPLEFT", 140, y)
        row.raidVal:SetText(string.format("%.2f", s.raid))

        -- M+ value
        row.mplusVal = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.mplusVal:SetPoint("TOPLEFT", 230, y)
        row.mplusVal:SetText(string.format("%.2f", s.mplus))

        f.statRows[i] = row
        y = y - 20
    end
end
