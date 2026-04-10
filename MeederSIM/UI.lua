----------------------------------------------------------------------
-- MeederSIM - UI
-- Export Dialog, BiS-Fenster (Icons + Tabs), Settings Panel
----------------------------------------------------------------------

local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local SLOT_NAMES = {
    [1]="Kopf",[2]="Hals",[3]="Schulter",[15]="Rücken",[5]="Brust",
    [9]="Handgelenke",[10]="Hände",[6]="Taille",[7]="Beine",[8]="Füße",
    [11]="Ring 1",[12]="Ring 2",[13]="Schmuck 1",[14]="Schmuck 2",
    [16]="Haupthand",[17]="Nebenhand",
}
local SLOT_ORDER = {1,2,3,15,5,9,10,6,7,8,11,12,13,14,16,17}

local ICON_SIZE = 26
local ROW_HEIGHT = 30

----------------------------------------------------------------------
-- Helper
----------------------------------------------------------------------
local function MakeFrame(name, w, h, titleText)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(w, h)
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
    title:SetText(titleText)

    local closeX = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeX:SetPoint("TOPRIGHT", -2, -2)

    table.insert(UISpecialFrames, name)
    f:Hide()
    return f
end

local function SafeGetIcon(itemId)
    if not itemId or itemId == 0 then return nil end
    if GetItemIcon then
        local ok, icon = pcall(GetItemIcon, itemId)
        if ok and icon then return icon end
    end
    return nil
end

----------------------------------------------------------------------
-- Export Frame
----------------------------------------------------------------------
function MeederSIM:CreateExportFrame()
    local f = MakeFrame("MeederSIMExportFrame", 520, 420, "|cff00ccffMeederSIM|r - SimC Export")

    local info = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    info:SetPoint("TOPLEFT", 16, -36)
    info:SetText("|cffaaaaaaCTRL+A markieren | CTRL+C kopieren | auf Raidbots einfügen|r")

    local scroll = CreateFrame("ScrollFrame", "MeederSIMExportScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -56)
    scroll:SetPoint("BOTTOMRIGHT", -30, 45)

    local edit = CreateFrame("EditBox", "MeederSIMExportEditBox", scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(scroll:GetWidth() - 10)
    edit:SetScript("OnEscapePressed", function(s) s:ClearFocus(); f:Hide() end)
    scroll:SetScrollChild(edit)

    local selBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    selBtn:SetSize(130, 24)
    selBtn:SetPoint("BOTTOMLEFT", 12, 10)
    selBtn:SetText("Alles markieren")
    selBtn:SetScript("OnClick", function() edit:HighlightText(0); edit:SetFocus() end)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(90, 24)
    closeBtn:SetPoint("BOTTOMRIGHT", -12, 10)
    closeBtn:SetText("Schließen")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    f.editBox = edit
    self.exportFrame = f
end

----------------------------------------------------------------------
-- BiS Fenster
----------------------------------------------------------------------
function MeederSIM:ShowBiSWindow()
    if not self.bisFrame then
        self:CreateBiSFrame()
    end
    self:UpdateBiSFrame()
    self.bisFrame:Show()
end

function MeederSIM:CreateBiSFrame()
    local f = MakeFrame("MeederSIMBiSFrame", 680, 680, "|cff00ccffMeederSIM|r - Best in Slot")

    -- Spec info
    f.specInfo = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.specInfo:SetPoint("TOPLEFT", 16, -36)

    -- TABS: Overall | Raid | M+ | Persönlich
    f.activeTab = "overall"
    f.tabs = {}

    local tabNames = {
        { key = "overall", label = "Overall" },
        { key = "raid",    label = "Raid" },
        { key = "mplus",   label = "M+" },
        { key = "personal", label = "Persönlich" },
    }

    for i, t in ipairs(tabNames) do
        local tab = CreateFrame("Button", nil, f)
        tab:SetSize(82, 24)
        tab:SetPoint("TOPLEFT", 16 + (i - 1) * 88, -52)

        tab.bg = tab:CreateTexture(nil, "BACKGROUND")
        tab.bg:SetAllPoints()

        tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.text:SetPoint("CENTER")
        tab.text:SetText(t.label)

        tab.key = t.key
        tab:SetScript("OnClick", function()
            f.activeTab = t.key
            MeederSIM:UpdateBiSTabs()
            MeederSIM:UpdateBiSFrame()
        end)

        f.tabs[i] = tab
    end

    -- Progress bar
    f.progressBg = f:CreateTexture(nil, "ARTWORK")
    f.progressBg:SetHeight(14)
    f.progressBg:SetPoint("TOPLEFT", 16, -80)
    f.progressBg:SetPoint("RIGHT", f, "RIGHT", -16, 0)
    f.progressBg:SetColorTexture(0.15, 0.15, 0.15, 1)

    f.progressBar = f:CreateTexture(nil, "OVERLAY")
    f.progressBar:SetHeight(14)
    f.progressBar:SetPoint("TOPLEFT", f.progressBg, "TOPLEFT")
    f.progressBar:SetColorTexture(0, 0.8, 0, 1)

    f.progressText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.progressText:SetPoint("CENTER", f.progressBg, "CENTER")

    -- Column headers
    local hdrY = -98
    local hdr1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr1:SetPoint("TOPLEFT", 16, hdrY)
    hdr1:SetText("|cff666666Slot|r")

    local hdr2 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr2:SetPoint("TOPLEFT", 120, hdrY)
    hdr2:SetText("|cff666666Ausgerüstet|r")

    local hdr3 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr3:SetPoint("TOPLEFT", 400, hdrY)
    hdr3:SetText("|cff666666Best in Slot|r")

    -- Rows
    f.rows = {}
    local yStart = -112

    for i, slotId in ipairs(SLOT_ORDER) do
        local row = {}
        local y = yStart - (i - 1) * ROW_HEIGHT

        -- Row background (alternating)
        row.bg = f:CreateTexture(nil, "BACKGROUND")
        row.bg:SetPoint("TOPLEFT", 8, y + 2)
        row.bg:SetPoint("RIGHT", f, "RIGHT", -8, 0)
        row.bg:SetHeight(ROW_HEIGHT)
        row.bg:SetColorTexture(i % 2 == 0 and 0.13 or 0.07, i % 2 == 0 and 0.13 or 0.07, i % 2 == 0 and 0.15 or 0.09, i % 2 == 0 and 0.7 or 0.4)

        -- Slot name (left column)
        row.label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.label:SetPoint("TOPLEFT", 16, y - 2)
        row.label:SetWidth(95)
        row.label:SetJustifyH("LEFT")
        row.label:SetText(SLOT_NAMES[slotId] or slotId)

        -- EQUIPPED: Icon + Name
        row.eqIcon = f:CreateTexture(nil, "ARTWORK")
        row.eqIcon:SetPoint("TOPLEFT", 120, y)
        row.eqIcon:SetSize(ICON_SIZE, ICON_SIZE)

        -- Green/Red border around equipped icon
        row.eqBorder = f:CreateTexture(nil, "OVERLAY")
        row.eqBorder:SetPoint("CENTER", row.eqIcon, "CENTER")
        row.eqBorder:SetSize(ICON_SIZE + 4, ICON_SIZE + 4)
        row.eqBorder:SetColorTexture(0, 0, 0, 0) -- Hidden by default

        row.eqName = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.eqName:SetPoint("LEFT", row.eqIcon, "RIGHT", 6, 0)
        row.eqName:SetWidth(230)
        row.eqName:SetJustifyH("LEFT")
        row.eqName:SetWordWrap(false)

        -- Equipped hover
        row.eqBtn = CreateFrame("Button", nil, f)
        row.eqBtn:SetPoint("TOPLEFT", 120, y)
        row.eqBtn:SetSize(270, ICON_SIZE)
        row.eqBtn.slotId = slotId
        row.eqBtn:SetScript("OnEnter", function(self)
            local g = (MeederSIMCharDB.gear or {})[self.slotId]
            if g and g.link then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(g.link)
                GameTooltip:Show()
            end
        end)
        row.eqBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Arrow separator
        row.arrow = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.arrow:SetPoint("TOPLEFT", 390, y - 1)
        row.arrow:SetText("|cff444444>|r")

        -- BIS: Icon + Name
        row.bisIcon = f:CreateTexture(nil, "ARTWORK")
        row.bisIcon:SetPoint("TOPLEFT", 405, y)
        row.bisIcon:SetSize(ICON_SIZE, ICON_SIZE)

        row.bisName = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.bisName:SetPoint("LEFT", row.bisIcon, "RIGHT", 6, 0)
        row.bisName:SetWidth(230)
        row.bisName:SetJustifyH("LEFT")
        row.bisName:SetWordWrap(false)

        -- BiS hover (exakt wie eqBtn aufgebaut - der funktioniert)
        row.bisHover = CreateFrame("Button", nil, f)
        row.bisHover:SetPoint("TOPLEFT", 405, y)
        row.bisHover:SetSize(260, ICON_SIZE)
        row.bisHover.slotId = slotId
        row.bisHover:SetScript("OnEnter", function(self)
            local bis = MeederSIM:GetActiveBiS()
            local b = bis and bis[self.slotId]
            if not b or not b.id then return end

            MeederSIM._bisTooltipActive = true

            -- SCHRITT 1: SetOwner + SetHyperlink + Show (exakt wie eqBtn)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

            -- Myth 6/6 Link: enchantID=0, Position 2 MUSS gesetzt sein!
            local lvl = MeederSIM.level or 90
            local sid = MeederSIM.specID or 0
            local myth = "item:" .. b.id .. ":0:::::::" .. lvl .. ":" .. sid .. "::16:6:6652:12667:13440:13338:13575:12806"

            if not pcall(GameTooltip.SetHyperlink, GameTooltip, myth) then
                GameTooltip:SetHyperlink("item:" .. b.id)
            end

            -- SCHRITT 2: Show SOFORT nach SetHyperlink
            GameTooltip:Show()

            -- SCHRITT 3: Zusatzinfos NACH Show hinzufügen
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ccff-- MeederSIM BiS (Myth 6/6 = iLvl 289) --|r")

            -- Vergleich mit aktuell ausgerüstetem Item
            local gear = MeederSIMCharDB.gear or {}
            local currentItem = gear[self.slotId]
            local hasIt, pIlvl = false, 0
            for _, g in pairs(gear) do
                if g.id == b.id then hasIt = true; pIlvl = g.ilvl or 0; break end
            end

            -- Verbesserung anzeigen wenn aktuelles Item schlechter ist
            if currentItem and currentItem.ilvl then
                local ilvlDiff = 289 - currentItem.ilvl
                if ilvlDiff > 0 then
                    GameTooltip:AddLine("|cff00ff00+" .. ilvlDiff .. " iLvl Verbesserung|r (" .. currentItem.ilvl .. " > 289)", 0, 1, 0)
                end
                -- Stat-Vergleich wenn möglich
                if currentItem.stats and next(currentItem.stats) then
                    local weights = MeederSIM:GetWeights()
                    if weights and weights.raid then
                        local curScore = MeederSIM:ItemScore(currentItem.stats, weights.raid)
                        if curScore > 0 then
                            GameTooltip:AddLine("|cff888888Aktuell: " .. (currentItem.name or "?") .. " (iLvl " .. currentItem.ilvl .. ")|r")
                        end
                    end
                end
            end

            if hasIt then
                if pIlvl >= 289 then
                    GameTooltip:AddLine("|cff00ff00Myth 6/6 erreicht!|r", 0, 1, 0)
                else
                    GameTooltip:AddLine("|cffffff00Besitzt auf iLvl " .. pIlvl .. "|r")
                    local ci = MeederSIM:GetCrestInfo("item:" .. b.id, pIlvl)
                    if ci and ci.canUpgrade then
                        GameTooltip:AddLine("|cff00ccffNoch " .. ci.crestsNeeded .. " " .. ci.currName .. " bis 289|r")
                        GameTooltip:AddLine("|cff888888Stufe " .. ci.rank .. "/" .. ci.maxRank .. " | Du hast: " .. ci.playerCrests .. " Crests|r")
                    end
                end
            else
                local src = MeederSIM:GetItemSource(b.id)
                if src then
                    if src.type == "raid" then
                        GameTooltip:AddLine("|cffff8800" .. src.source .. " (" .. src.instance .. ")|r")
                        GameTooltip:AddLine("|cff888888Mythic Raid / Great Vault|r")
                    elseif src.type == "mplus" then
                        GameTooltip:AddLine("|cff00ccff" .. src.instance .. " (M+)|r")
                        GameTooltip:AddLine("|cff888888M+ Dungeon / Great Vault|r")
                    elseif src.type == "crafted" then
                        GameTooltip:AddLine("|cff00ff00" .. src.source .. " (Hergestellt)|r")
                        GameTooltip:AddLine("|cff888888Crafting-Auftrag|r")
                    end
                end
                if MeederSIM:IsItemInBags(b.id) then
                    GameTooltip:AddLine("|cff00ff00In deiner Tasche!|r")
                end
            end

            -- SCHRITT 4: Nochmal Show um AddLines sichtbar zu machen
            GameTooltip:Show()
        end)
        row.bisHover:SetScript("OnLeave", function()
            MeederSIM._bisTooltipActive = false
            GameTooltip:Hide()
        end)
        row.bisHover:SetScript("OnMouseUp", function(self, button)
            if button == "RightButton" then
                MeederSIM:ShowBiSEditForSlot(self.slotId, self)
            end
        end)

        -- Drag & Drop: Item auf BiS-Slot ziehen
        row.bisHover:SetScript("OnReceiveDrag", function(self)
            local infoType, itemId, itemLink = GetCursorInfo()
            if infoType == "item" and itemLink then
                local name = GetItemInfo(itemLink)
                local id = tonumber(itemLink:match("item:(%d+)"))
                if id then
                    MeederSIM:GetActiveBiS()[self.slotId] = { id = id, name = name or "?", ilvl = 0 }
                    MeederSIM:Print("|cff00ff00BiS gesetzt:|r " .. (name or "?"))
                    MeederSIM:UpdateBiSFrame()
                    ClearCursor()
                end
            end
        end)
        row.bisHover:SetScript("OnMouseDown", function(self)
            -- Auch OnMouseDown für Drag-Empfang nötig
            if GetCursorInfo() then
                self:GetScript("OnReceiveDrag")(self)
            end
        end)

        -- Klick auf Slot-Name = editieren
        local slotBtn = CreateFrame("Button", nil, f)
        slotBtn:SetPoint("TOPLEFT", 16, y)
        slotBtn:SetSize(100, ICON_SIZE)
        slotBtn.slotId = slotId
        slotBtn:SetScript("OnClick", function(self)
            MeederSIM:ShowBiSEditForSlot(self.slotId, self)
        end)

        row.slotId = slotId
        f.rows[i] = row
    end

    -- Help text (replaces old input area)
    local helpY = yStart - #SLOT_ORDER * ROW_HEIGHT - 6
    local helpText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    helpText:SetPoint("TOPLEFT", 16, helpY)
    helpText:SetText("|cff888888Rechtsklick oder Klick auf Slot-Name = BiS-Item ändern (Wowhead ID eingeben)|r")

    -- Bottom buttons
    local clearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    clearBtn:SetSize(100, 22)
    clearBtn:SetPoint("BOTTOMLEFT", 12, 10)
    clearBtn:SetText("Zurücksetzen")
    clearBtn:SetScript("OnClick", function()
        MeederSIM:ClearBiS()
        MeederSIM:UpdateBiSFrame()
    end)

    local exportBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    exportBtn:SetSize(100, 22)
    exportBtn:SetPoint("LEFT", clearBtn, "RIGHT", 6, 0)
    exportBtn:SetText("Exportieren")
    exportBtn:SetScript("OnClick", function() MeederSIM:ExportBiS() end)

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOMRIGHT", -12, 10)
    closeBtn:SetText("Schließen")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    self.bisFrame = f
end

----------------------------------------------------------------------
-- Tab visual update
----------------------------------------------------------------------
function MeederSIM:UpdateBiSTabs()
    local f = self.bisFrame
    if not f or not f.tabs then return end
    for _, tab in ipairs(f.tabs) do
        if tab.key == f.activeTab then
            tab.bg:SetColorTexture(0, 0.5, 0.8, 0.8)
            tab.text:SetTextColor(1, 1, 1)
        else
            tab.bg:SetColorTexture(0.2, 0.2, 0.2, 0.6)
            tab.text:SetTextColor(0.6, 0.6, 0.6)
        end
    end
end

----------------------------------------------------------------------
-- Shared BiS Edit Popup (ein Frame für alle Slots)
----------------------------------------------------------------------
function MeederSIM:ShowBiSEditForSlot(slotId, anchorFrame)
    if not self.bisEditPopup then
        local p = CreateFrame("Frame", "MeederSIMBiSEdit", UIParent, "BackdropTemplate")
        p:SetSize(240, 80)
        p:SetFrameStrata("FULLSCREEN_DIALOG")
        p:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })

        local lbl = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lbl:SetPoint("TOPLEFT", 10, -8)
        p.label = lbl

        local edit = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
        edit:SetSize(140, 20)
        edit:SetPoint("TOPLEFT", 10, -28)
        edit:SetAutoFocus(true)
        edit:SetFontObject(ChatFontSmall)
        edit:SetNumeric(true)
        p.editBox = edit

        local setBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        setBtn:SetSize(60, 20)
        setBtn:SetPoint("LEFT", edit, "RIGHT", 4, 0)
        setBtn:SetText("Setzen")
        setBtn:SetScript("OnClick", function()
            local id = edit:GetText():trim()
            if id ~= "" then
                MeederSIM:SetBiSFromId(tonumber(id), p.activeSlot)
                MeederSIM:UpdateBiSFrame()
            end
            p:Hide()
        end)

        -- X = Delete BiS for this slot
        local delBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        delBtn:SetSize(70, 20)
        delBtn:SetPoint("TOPLEFT", 10, -54)
        delBtn:SetText("|cffff3333Löschen|r")
        delBtn:SetScript("OnClick", function()
            local bis = MeederSIM:GetActiveBiS()
            bis[p.activeSlot] = nil
            MeederSIM:Print("BiS für Slot gelöscht.")
            MeederSIM:UpdateBiSFrame()
            p:Hide()
        end)

        local cancelBtn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        cancelBtn:SetSize(70, 20)
        cancelBtn:SetPoint("LEFT", delBtn, "RIGHT", 4, 0)
        cancelBtn:SetText("Abbrechen")
        cancelBtn:SetScript("OnClick", function() p:Hide() end)

        edit:SetScript("OnEnterPressed", function() setBtn:Click() end)
        edit:SetScript("OnEscapePressed", function() p:Hide() end)

        p:Hide()
        self.bisEditPopup = p
    end

    local p = self.bisEditPopup
    local SLOT_NAMES = {
        [1]="Kopf",[2]="Hals",[3]="Schulter",[15]="Rücken",[5]="Brust",
        [9]="Handgelenke",[10]="Hände",[6]="Taille",[7]="Beine",[8]="Füße",
        [11]="Ring 1",[12]="Ring 2",[13]="Schmuck 1",[14]="Schmuck 2",
        [16]="Haupthand",[17]="Nebenhand",
    }

    p.activeSlot = slotId
    p.label:SetText("|cffffff00BiS für " .. (SLOT_NAMES[slotId] or "Slot " .. slotId) .. ":|r  Wowhead Item-ID eingeben")
    p.editBox:SetText("")
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -2)
    p:Show()
    p.editBox:SetFocus()
end

----------------------------------------------------------------------
-- Check if player has an item in bags (not equipped)
----------------------------------------------------------------------
function MeederSIM:IsItemInBags(itemId)
    if not itemId then return false end
    for bag = 0, 4 do
        local slots = C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, slots do
            local info = C_Container and C_Container.GetContainerItemID and C_Container.GetContainerItemID(bag, slot)
            if info == itemId then return true end
        end
    end
    return false
end

----------------------------------------------------------------------
-- Update BiS Frame
----------------------------------------------------------------------
function MeederSIM:UpdateBiSFrame()
    local f = self.bisFrame
    if not f then return end

    self:InitBiS()
    local rawBis = self:GetActiveBiS()
    local gear = MeederSIMCharDB.gear or {}

    -- Dynamische Zuordnung für Ringe/Trinkets:
    -- Wenn BiS Slot 13 in Gear Slot 14 steckt, tausche die Anzeige
    local bis = {}
    for k, v in pairs(rawBis) do bis[k] = v end

    -- Trinkets: Optimale Zuordnung finden
    local b13, b14 = bis[13], bis[14]
    local g13, g14 = gear[13], gear[14]
    if b13 and b14 and g13 and g14 then
        -- Wenn Gear 13 = BiS 14 und Gear 14 = BiS 13 → tausche Anzeige
        if g13.id == b14.id and g14.id == b13.id then
            bis[13], bis[14] = b14, b13
        -- Wenn Gear 14 = BiS 13 → tausche damit es grün wird
        elseif g14.id == b13.id and g13.id ~= b13.id then
            bis[13], bis[14] = b14, b13
        elseif g13.id == b14.id and g14.id ~= b14.id then
            bis[13], bis[14] = b14, b13
        end
    end

    -- Ringe: Gleiche Logik
    local b11, b12 = bis[11], bis[12]
    local g11, g12 = gear[11], gear[12]
    if b11 and b12 and g11 and g12 then
        if g11.id == b12.id and g12.id == b11.id then
            bis[11], bis[12] = b12, b11
        elseif g12.id == b11.id and g11.id ~= b11.id then
            bis[11], bis[12] = b12, b11
        elseif g11.id == b12.id and g12.id ~= b12.id then
            bis[11], bis[12] = b12, b11
        end
    end

    self:UpdateBiSTabs()

    f.specInfo:SetText((self.spec or "?") .. " " .. (self.class or "?") ..
        " | " .. (self.name or "?"))

    local have, total = 0, 0

    for i, row in ipairs(f.rows) do
        local slotId = row.slotId
        local bisData = bis[slotId]
        local eq = gear[slotId]

        -- Equipped icon + name
        if eq and eq.id then
            local icon = SafeGetIcon(eq.id)
            if icon then row.eqIcon:SetTexture(icon) else row.eqIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end
            row.eqIcon:Show()

            local enchMissing = MeederSIM:ShouldBeEnchanted(slotId) and (eq.enchantId or 0) == 0
            local enchTag = enchMissing and " |cffff3333[!E]|r" or ""
            row.eqName:SetText((eq.name or "?") .. " (" .. (eq.ilvl or 0) .. ")" .. enchTag)
        else
            row.eqIcon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
            row.eqName:SetText("|cff555555Leer|r")
        end

        -- (slot icon removed from new layout)

        -- BiS check
        if bisData then
            total = total + 1

            -- BiS-Check: Slots sind oben schon dynamisch zugeordnet
            local hasBiS = eq and eq.id == bisData.id

            -- BiS-Spalte zeigt IMMER das Ziel-Item für DIESEN Slot
            local bisIcon = SafeGetIcon(bisData.id)
            if bisIcon then row.bisIcon:SetTexture(bisIcon) else row.bisIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end
            row.bisIcon:Show()

            if hasBiS then
                have = have + 1
                row.eqBorder:SetColorTexture(0, 0.8, 0, 0.7)
                row.eqName:SetTextColor(0.4, 1, 0.4)
                row.arrow:SetText("|cff00ff00=|r")
                -- Zeige was das ausgerüstete Item ist (grün = ist ein BiS)
                row.bisName:SetText("|cff00ff00" .. (eq.name or "?") .. " = BiS|r")
            else
                row.eqBorder:SetColorTexture(0.8, 0, 0, 0.5)
                row.eqName:SetTextColor(1, 0.5, 0.5)
                row.arrow:SetText("|cffff3333>|r")
                local bisText = (bisData.name or "Item #" .. (bisData.id or "?"))

                -- Check if BiS item is in bags!
                local inBags = self:IsItemInBags(bisData.id)
                if inBags then
                    bisText = "|cff00ff00[Tasche]|r " .. bisText
                    row.arrow:SetText("|cff00ff00>>|r")
                    row.eqBorder:SetColorTexture(0, 0.5, 0.8, 0.5) -- Blau = hast du in Tasche
                end

                local src = MeederSIM:GetItemSource(bisData.id)
                if src and not inBags then
                    bisText = bisText .. " |cff888888(" .. src.source .. ")|r"
                end
                row.bisName:SetText("|cffffff00" .. bisText .. "|r")
            end
        else
            row.bisIcon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
            row.eqBorder:SetColorTexture(0, 0, 0, 0)
            row.arrow:SetText("")
            row.eqName:SetTextColor(0.5, 0.5, 0.5)
            row.bisName:SetText("|cff444444-|r")
        end
    end

    -- Progress
    local pct = total > 0 and (have / total) or 0
    f.progressBar:SetWidth(math.max(1, f.progressBg:GetWidth() * pct))
    if pct >= 1 then f.progressBar:SetColorTexture(0, 1, 0, 1)
    elseif pct >= 0.5 then f.progressBar:SetColorTexture(1, 0.8, 0, 1)
    else f.progressBar:SetColorTexture(1, 0.3, 0, 1) end
    f.progressText:SetText(have .. "/" .. total .. " BiS-Items ausgerüstet")
end

----------------------------------------------------------------------
-- Settings Panel
----------------------------------------------------------------------
function MeederSIM:CreateSettingsPanel()
    local panel = CreateFrame("Frame", "MeederSIMSettingsPanel")
    panel.name = "MeederSIM"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff00ccffMeederSIM|r by IT-Meeder.de v" .. self.version)

    local support = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    support:SetPoint("TOPLEFT", 16, -34)
    support:SetText("|cff888888BiS-Daten: Icy Veins (Stand: 10.04.2026, Patch 12.0.4) | Support: Littlepink-Arthas|r")

    local y = -50

    local function AddCategory(text)
        y = y - 8
        local cat = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        cat:SetPoint("TOPLEFT", 16, y)
        cat:SetText("|cffffff00" .. text .. "|r")
        y = y - 22
    end

    local function AddCheckbox(key, label)
        local cb = CreateFrame("CheckButton", "MeederSIMCB_" .. key, panel)
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", 20, y)
        cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
        cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
        cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

        local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        text:SetText(label)

        cb:SetChecked(MeederSIMDB.settings[key])
        cb:SetScript("OnClick", function(s) MeederSIMDB.settings[key] = s:GetChecked() end)
        y = y - 26
    end

    AddCategory("Anzeige")
    AddCheckbox("showTooltip", "Tooltip-Vergleich anzeigen")
    AddCheckbox("showRaid", "Raid-Bewertung anzeigen")
    AddCheckbox("showMPlus", "M+-Bewertung anzeigen")
    AddCheckbox("showStatChanges", "Stat-Änderungen anzeigen")
    AddCheckbox("showStatPriority", "Stat-Priorität anzeigen")
    AddCheckbox("showIlvlDiff", "Item-Level Differenz anzeigen")

    AddCategory("Benachrichtigungen")
    AddCheckbox("showLootPopup", "Loot-Benachrichtigung im Chat")
    AddCheckbox("onlyUpgrades", "Nur Upgrades melden")

    AddCategory("BiS & Gear")
    AddCheckbox("showBisOnEquipped", "BiS-Status auf ausgerüsteten Items")
    AddCheckbox("showEnchantWarning", "Enchant-Warnung auf ausgerüsteten Items")
    AddCheckbox("showDropSource", "Drop-Quelle im Tooltip anzeigen")

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(panel, "MeederSIM")
        Settings.RegisterAddOnCategory(cat)
        self.settingsCategory = cat
    end
    self.settingsPanel = panel
end

function MeederSIM:OpenSettings()
    if self.settingsCategory then
        Settings.OpenToCategory(self.settingsCategory:GetID())
    else
        self:Print("Einstellungen: Escape > Optionen > Addons > MeederSIM")
    end
end
