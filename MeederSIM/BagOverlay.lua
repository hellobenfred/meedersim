----------------------------------------------------------------------
-- MeederSIM - BagOverlay
-- Shows upgrade/BiS indicators directly on bag item slots
-- Green arrow = upgrade, Gold star = BiS, Red arrow = downgrade
----------------------------------------------------------------------

local overlayFrames = {}

function MeederSIM:InitBagOverlay()
    -- Hook into bag updates
    local f = CreateFrame("Frame")
    f:RegisterEvent("BAG_UPDATE_DELAYED")
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:SetScript("OnEvent", function()
        if MeederSIM.initialized then
            C_Timer.After(0.3, function() MeederSIM:UpdateBagOverlays() end)
        end
    end)

    -- Initial scan after login
    C_Timer.After(3, function()
        if MeederSIM.initialized then
            MeederSIM:UpdateBagOverlays()
        end
    end)
end

----------------------------------------------------------------------
-- Get or create overlay for a bag slot button
----------------------------------------------------------------------
local function GetOverlay(button)
    if not button then return nil end

    local name = button:GetName()
    if not name then return nil end

    if overlayFrames[name] then return overlayFrames[name] end

    local ov = CreateFrame("Frame", nil, button)
    ov:SetAllPoints()
    ov:SetFrameLevel(button:GetFrameLevel() + 2)

    -- Upgrade arrow (green, top-right)
    ov.arrow = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    ov.arrow:SetPoint("TOPRIGHT", -1, -1)
    ov.arrow:SetText("")

    -- BiS star (gold, bottom-left)
    ov.bis = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ov.bis:SetPoint("BOTTOMLEFT", 1, 1)
    ov.bis:SetText("")

    -- Percentage (bottom-right)
    ov.pct = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ov.pct:SetPoint("BOTTOMRIGHT", -1, 1)
    ov.pct:SetText("")

    ov:Hide()
    overlayFrames[name] = ov
    return ov
end

----------------------------------------------------------------------
-- Update all bag slot overlays
----------------------------------------------------------------------
function MeederSIM:UpdateBagOverlays()
    if not self.initialized then return end
    if not self.class or not self.spec then return end

    -- Clear all existing overlays
    for _, ov in pairs(overlayFrames) do
        ov.arrow:SetText("")
        ov.bis:SetText("")
        ov.pct:SetText("")
        ov:Hide()
    end

    -- Scan all bags
    for bag = 0, 4 do
        local numSlots = C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, numSlots do
            local itemLink = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                self:ProcessBagSlot(bag, slot, itemLink)
            end
        end
    end
end

----------------------------------------------------------------------
-- Process a single bag slot
----------------------------------------------------------------------
function MeederSIM:ProcessBagSlot(bag, slot, itemLink)
    if not itemLink then return end
    if not self:IsEquippable(itemLink) then return end

    -- Get the bag slot button
    local button = nil
    -- Try ContainerFrame button naming (Retail)
    for i = 1, 13 do
        local frameName = "ContainerFrame" .. i
        local frame = _G[frameName]
        if frame and frame:IsShown() then
            local bagID = frame:GetID()
            if bagID == bag then
                local btnName = frameName .. "Item" .. slot
                button = _G[btnName]
                if not button then
                    -- New naming in recent WoW
                    local items = frame.Items or {}
                    button = items[slot]
                end
                break
            end
        end
    end

    if not button then return end

    -- Compare item
    local raidDiff, mplusDiff, details = self:CompareItem(itemLink)
    if not raidDiff then return end

    local verdict = self:GetVerdict(raidDiff, mplusDiff)
    local ov = GetOverlay(button)
    if not ov then return end

    -- Check BiS
    local slotId = self:GetSlotForItem(itemLink)
    local itemId = tonumber(itemLink:match("item:(%d+)"))
    local isBiS = slotId and itemId and self:IsItemBiS(itemId, slotId)

    -- Show overlay
    ov:Show()

    if verdict == "upgrade" then
        ov.arrow:SetText("|cff00ff00+|r")
        local pct = math.max(raidDiff, mplusDiff)
        if pct > 5 then
            ov.pct:SetText("|cff00ff00" .. string.format("%.0f", pct) .. "%|r")
        end
    elseif verdict == "downgrade" then
        ov.arrow:SetText("|cffff3333-|r")
    end

    if isBiS then
        ov.bis:SetText("|cffff8800BiS|r")
    end
end
