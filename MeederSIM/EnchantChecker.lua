----------------------------------------------------------------------
-- MeederSIM - EnchantChecker
-- Prüft ob alle Slots verzaubert sind und ob die richtige Verzauberung drauf ist
-- Midnight Season 1
----------------------------------------------------------------------

-- Slots die in Midnight verzaubert werden MÜSSEN
-- Midnight: Kopf + Schulter NEU, Rücken + Handgelenke ENTFERNT
-- Beine: Leatherworking/Tailoring Patches (kein Enchanting, aber Enhancement)
local ENCHANTABLE_SLOTS = {
    [1]  = true,  -- Kopf (NEU in Midnight!)
    [3]  = true,  -- Schulter (NEU in Midnight!)
    [5]  = true,  -- Brust
    [7]  = true,  -- Beine (Leatherworking/Tailoring Patch)
    [8]  = true,  -- Füße
    [11] = true,  -- Ring 1
    [12] = true,  -- Ring 2
    [16] = true,  -- Haupthand (Weapon)
}

local SLOT_ENCHANT_TYPE = {
    [1]  = "Kopf-Enchant",
    [3]  = "Schulter-Enchant",
    [5]  = "Brust-Enchant",
    [7]  = "Beinverstärkung",
    [8]  = "Füße-Enchant",
    [11] = "Ring-Enchant",
    [12] = "Ring-Enchant",
    [16] = "Waffen-Enchant",
}

----------------------------------------------------------------------
-- Check if a slot should be enchanted
----------------------------------------------------------------------
function MeederSIM:ShouldBeEnchanted(slotId)
    return ENCHANTABLE_SLOTS[slotId] or false
end

----------------------------------------------------------------------
-- Check if an item in a slot IS enchanted (enchantId > 0)
----------------------------------------------------------------------
function MeederSIM:IsEnchanted(slotId)
    local gear = MeederSIMCharDB.gear or {}
    local g = gear[slotId]
    if not g then return false end
    return (g.enchantId or 0) > 0
end

----------------------------------------------------------------------
-- Get full enchant audit for all equipped gear
-- Returns: { missing = {slotId, ...}, enchanted = {slotId, ...}, total = n }
----------------------------------------------------------------------
function MeederSIM:GetEnchantAudit()
    local gear = MeederSIMCharDB.gear or {}
    local missing = {}
    local enchanted = {}
    local total = 0

    for slotId in pairs(ENCHANTABLE_SLOTS) do
        local g = gear[slotId]
        if g then  -- Only check slots that have an item
            total = total + 1
            if (g.enchantId or 0) > 0 then
                enchanted[#enchanted + 1] = slotId
            else
                missing[#missing + 1] = slotId
            end
        end
    end

    return {
        missing = missing,
        enchanted = enchanted,
        total = total,
        complete = #missing == 0,
    }
end

----------------------------------------------------------------------
-- Format enchant status for a single slot (tooltip)
----------------------------------------------------------------------
function MeederSIM:GetEnchantStatus(slotId)
    if not ENCHANTABLE_SLOTS[slotId] then return nil end

    local gear = MeederSIMCharDB.gear or {}
    local g = gear[slotId]
    if not g then return nil end

    if (g.enchantId or 0) > 0 then
        return "enchanted", g.enchantId
    else
        return "missing", SLOT_ENCHANT_TYPE[slotId] or "?"
    end
end

----------------------------------------------------------------------
-- Format enchant audit for chat/window
----------------------------------------------------------------------
function MeederSIM:PrintEnchantAudit()
    local audit = self:GetEnchantAudit()

    if audit.complete then
        self:Print("|cff00ff00Alle Items verzaubert!|r (" .. #audit.enchanted .. "/" .. audit.total .. ")")
    else
        self:Print("|cffff3333Verzauberungen fehlen:|r")
        for _, slotId in ipairs(audit.missing) do
            local slotName = SLOT_ENCHANT_TYPE[slotId] or "?"
            self:Print("  |cffff3333[!]|r " .. slotName .. " - Verzauberung fehlt!")
        end
        self:Print("|cffffff00" .. #audit.enchanted .. "/" .. audit.total .. " Slots verzaubert|r")
    end
end

----------------------------------------------------------------------
-- Check if an item has empty gem sockets
----------------------------------------------------------------------
function MeederSIM:HasEmptySocket(slotId)
    local gear = MeederSIMCharDB.gear or {}
    local g = gear[slotId]
    if not g or not g.link then return false end

    -- Check via C_TooltipInfo if available (safe, no SetHyperlink)
    if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
        local ok, data = pcall(C_TooltipInfo.GetInventoryItem, "player", slotId)
        if ok and data and data.lines then
            for _, line in ipairs(data.lines) do
                local text = line.leftText or ""
                -- Empty socket lines contain socket type text without a gem name
                if text:match("Empty Socket") or text:match("Leerer Sockel") or
                   text:match("Prismatic Socket") or text:match("Prismatischer Sockel") then
                    return true
                end
            end
        end
    end

    return false
end

----------------------------------------------------------------------
-- Character Frame Overlay: Show warnings on equipped items
----------------------------------------------------------------------
local charOverlays = {}

-- WoW Character Frame slot button names (Retail)
local CHAR_SLOT_BUTTONS = {
    [1]  = "CharacterHeadSlot",
    [2]  = "CharacterNeckSlot",
    [3]  = "CharacterShoulderSlot",
    [15] = "CharacterBackSlot",
    [5]  = "CharacterChestSlot",
    [9]  = "CharacterWristSlot",
    [10] = "CharacterHandsSlot",
    [6]  = "CharacterWaistSlot",
    [7]  = "CharacterLegsSlot",
    [8]  = "CharacterFeetSlot",
    [11] = "CharacterFinger0Slot",
    [12] = "CharacterFinger1Slot",
    [13] = "CharacterTrinket0Slot",
    [14] = "CharacterTrinket1Slot",
    [16] = "CharacterMainHandSlot",
    [17] = "CharacterSecondaryHandSlot",
}

function MeederSIM:InitCharOverlay()
    -- Hook character frame show
    if CharacterFrame then
        CharacterFrame:HookScript("OnShow", function()
            C_Timer.After(0.2, function() MeederSIM:UpdateCharOverlays() end)
        end)
    end

    -- Also update on gear change
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:SetScript("OnEvent", function()
        if CharacterFrame and CharacterFrame:IsShown() then
            C_Timer.After(0.3, function() MeederSIM:UpdateCharOverlays() end)
        end
    end)
end

function MeederSIM:UpdateCharOverlays()
    if not self.initialized then return end

    for slotId, btnName in pairs(CHAR_SLOT_BUTTONS) do
        local button = _G[btnName]
        if button then
            -- Get or create overlay
            if not charOverlays[slotId] then
                local ov = CreateFrame("Frame", nil, button)
                ov:SetAllPoints()
                ov:SetFrameLevel(button:GetFrameLevel() + 3)

                ov.enchant = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                ov.enchant:SetPoint("BOTTOMRIGHT", -1, 1)
                ov.enchant:SetText("")

                ov.socket = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                ov.socket:SetPoint("BOTTOMLEFT", 1, 1)
                ov.socket:SetText("")

                ov.bis = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                ov.bis:SetPoint("TOPRIGHT", -1, -1)
                ov.bis:SetText("")

                charOverlays[slotId] = ov
            end

            local ov = charOverlays[slotId]

            -- Enchant check
            if self:ShouldBeEnchanted(slotId) and not self:IsEnchanted(slotId) then
                ov.enchant:SetText("|cffff3333[!E]|r")
            else
                ov.enchant:SetText("")
            end

            -- Socket check
            if self:HasEmptySocket(slotId) then
                ov.socket:SetText("|cffff8800[S]|r")
            else
                ov.socket:SetText("")
            end

            -- BiS check
            local gear = MeederSIMCharDB.gear or {}
            local g = gear[slotId]
            if g and g.id and self:IsItemBiS(g.id, slotId) then
                ov.bis:SetText("|cff00ff00BiS|r")
            else
                ov.bis:SetText("")
            end
        end
    end
end
