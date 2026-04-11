----------------------------------------------------------------------
-- MeederSIM - Minimap Button + Hub (v1.2.0: 3 Buttons, clean)
----------------------------------------------------------------------

local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

----------------------------------------------------------------------
-- Minimap Button
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
        GameTooltip:AddLine(MeederSIM.L.SUPPORT, 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.minimapBtn = btn
end

----------------------------------------------------------------------
-- Hub-Fenster (3 Buttons: BiS, Quick Sim, Einstellungen)
----------------------------------------------------------------------
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
    local L = self.L
    local f = CreateFrame("Frame", "MeederSIMHubFrame", UIParent, "BackdropTemplate")
    f:SetSize(340, 360)
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

    -- Header
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("|cff00ccffMeederSIM|r")

    local subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText("|cff888888" .. L.BY .. "  v" .. self.version .. " | " .. L.SUPPORT .. "|r")

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

    f.statsBar = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.statsBar:SetPoint("TOPLEFT", 20, -84)

    -- Separator
    local sep1 = f:CreateTexture(nil, "ARTWORK")
    sep1:SetHeight(1)
    sep1:SetPoint("TOPLEFT", 12, -104)
    sep1:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    sep1:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- 3 Menu buttons
    local y = -114

    local function AddMenuButton(iconPath, label, desc, onClick)
        local row = CreateFrame("Button", nil, f)
        row:SetSize(316, 44)
        row:SetPoint("TOPLEFT", 12, y)

        local hl = row:CreateTexture(nil, "BACKGROUND")
        hl:SetAllPoints()
        hl:SetColorTexture(0.2, 0.3, 0.5, 0)
        row:SetScript("OnEnter", function() hl:SetColorTexture(0.2, 0.3, 0.5, 0.4) end)
        row:SetScript("OnLeave", function() hl:SetColorTexture(0.2, 0.3, 0.5, 0) end)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(30, 30)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(iconPath)

        local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)
        lbl:SetText(label)

        local dsc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        dsc:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -1)
        dsc:SetText("|cff888888" .. desc .. "|r")

        row:SetScript("OnClick", function()
            f:Hide()
            onClick()
        end)

        y = y - 50
    end

    AddMenuButton(
        "Interface\\Icons\\INV_Misc_Gem_Variety_02",
        "|cff00ff00" .. L.HUB_BIS .. "|r",
        L.HUB_BIS_DESC,
        function() MeederSIM:ShowBiSWindow() end
    )

    AddMenuButton(
        "Interface\\Icons\\Spell_Fire_FelFlameRing",
        "|cffff3333" .. L.HUB_QUICKSIM .. "|r",
        L.HUB_QUICKSIM_DESC,
        function() MeederSIM:QuickSim() end
    )

    AddMenuButton(
        "Interface\\Icons\\INV_Gizmo_01",
        "|cffffffff" .. L.HUB_SETTINGS .. "|r",
        L.HUB_SETTINGS_DESC,
        function() MeederSIM:OpenSettings() end
    )

    -- Separator
    local sep2 = f:CreateTexture(nil, "ARTWORK")
    sep2:SetHeight(1)
    sep2:SetPoint("TOPLEFT", 12, y - 4)
    sep2:SetPoint("RIGHT", f, "RIGHT", -12, 0)
    sep2:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- Quick stats
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

    f.charName:SetText("|cffffff00" .. (self.name or "?") .. "|r")
    f.charDetails:SetText((self.spec or "?") .. " " .. (self.class or "?"))

    local gear = MeederSIMCharDB.gear or {}
    local totalIlvl, count = 0, 0
    for _, g in pairs(gear) do
        if g.ilvl and g.ilvl > 0 then totalIlvl = totalIlvl + g.ilvl; count = count + 1 end
    end
    local avgIlvl = count > 0 and math.floor(totalIlvl / count) or 0
    f.statsBar:SetText("|cff00ccffiLvl " .. avgIlvl .. "|r  |  " .. count .. " " .. self.L.ITEMS_EQUIPPED)

    -- BiS progress
    self:InitBiS()
    local bis = self:GetActiveBiS()
    local bisHave, bisTotal = 0, 0
    for slotId, bisData in pairs(bis) do
        bisTotal = bisTotal + 1
        local g = gear[slotId]
        if g and self:IsItemBiS(g.id, slotId) then bisHave = bisHave + 1 end
    end

    local bisColor = bisHave == bisTotal and "|cff00ff00" or "|cffffff00"
    f.quickBis:SetText("BiS: " .. bisColor .. bisHave .. "/" .. bisTotal .. "|r " .. self.L.BIS_ITEMS)

    local enchAudit = self:GetEnchantAudit()
    local enchColor = enchAudit.complete and "|cff00ff00" or "|cffff3333"
    f.quickEnch:SetText("Enchants: " .. enchColor .. #enchAudit.enchanted .. "/" .. enchAudit.total .. "|r " .. self.L.ENCHANTED)

    local tierCount = self:CountTierPieces()
    local tierColor = tierCount >= 4 and "|cff00ff00" or (tierCount >= 2 and "|cffffff00" or "|cffff3333")
    f.quickTier:SetText("Tier-Set: " .. tierColor .. tierCount .. "pc|r")
end
