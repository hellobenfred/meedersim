----------------------------------------------------------------------
-- MeederSIM - LootDetector
-- Detects equippable loot and shows comparison popup
-- No hidden tooltips, no SetHyperlink, crash-safe
----------------------------------------------------------------------

local recentItems = {}

local f = CreateFrame("Frame")
f:RegisterEvent("SHOW_LOOT_TOAST")
f:RegisterEvent("SHOW_LOOT_TOAST_UPGRADE")
f:RegisterEvent("CHAT_MSG_LOOT")

f:SetScript("OnEvent", function(_, event, ...)
    if not MeederSIMDB or not MeederSIMDB.settings or not MeederSIMDB.settings.showLootPopup then return end
    if not MeederSIM.initialized then return end

    if event == "SHOW_LOOT_TOAST" or event == "SHOW_LOOT_TOAST_UPGRADE" then
        local typeId, itemLink = ...
        if typeId == "item" and itemLink then
            MeederSIM:OnNewLoot(itemLink)
        end
    elseif event == "CHAT_MSG_LOOT" then
        local msg = ...
        if not msg then return end
        local itemLink = msg:match("|c%x+|Hitem:.-|h%[.-%]|h|r")
        if itemLink and msg:find(UnitName("player") or "", 1, true) then
            MeederSIM:OnNewLoot(itemLink)
        end
    end
end)

function MeederSIM:OnNewLoot(link)
    if not link then return end

    -- Deduplicate (5s window)
    local id = link:match("item:(%d+)")
    if not id then return end
    local now = GetTime()
    if recentItems[id] and now - recentItems[id] < 5 then return end
    recentItems[id] = now

    -- Must be equippable
    if not self:IsEquippable(link) then return end

    -- Ensure item data is available
    local name = GetItemInfo(link)
    if not name then
        -- Wait for cache
        C_Timer.After(1, function()
            if GetItemInfo(link) then
                self:ShowLootResult(link)
            end
        end)
        return
    end

    self:ShowLootResult(link)
end

function MeederSIM:ShowLootResult(link)
    local raidDiff, mplusDiff, details = self:CompareItem(link)
    if not raidDiff then return end

    local hasStats = details and details.hasStats
    local raidPct = raidDiff
    local mplusPct = mplusDiff
    local name = GetItemInfo(link) or "?"

    -- Zentrale Verdict-Funktion
    local verdictType, verdictText = self:GetVerdict(raidPct, mplusPct)

    -- Skip downgrades if setting is on
    if MeederSIMDB.settings.onlyUpgrades and verdictType ~= "upgrade" then return end

    local verdict = verdictText

    self:Print(verdict .. " " .. link)
    self:Print("  Raid: " .. self:FormatPercent(raidPct) .. "  M+: " .. self:FormatPercent(mplusPct))

    -- Check other specs
    local otherSpecs = self:CompareOtherSpecs(link, details)
    if otherSpecs then
        for _, os in ipairs(otherSpecs) do
            local osVerdict = self:GetVerdict(os.raidPct, os.mplusPct)
            if osVerdict == "upgrade" then
                self:Print("  |cff00ff00[+] Gut für " .. os.spec .. "|r")
            end
        end
    end

    -- Crest info
    if details.new then
        local crest = self:GetCrestInfo(link, details.new.ilvl)
        if crest and crest.canUpgrade then
            self:Print("  Aufwertbar: " .. (crest.currName or crest.trackName or "?") .. " (" ..
                crest.rank .. "/" .. crest.maxRank .. ", " .. crest.crestsNeeded .. " Crests)")
        end
    end

    -- BiS check
    if details.new and details.new.id then
        local slotId = details.slot or self:GetSlotForItem(link)
        if slotId then
            local isBiS = self:IsItemBiS(details.new.id, slotId, self.class, self.spec)
            if isBiS then
                self:Print("  |cffff8800>>> BEST IN SLOT für " .. self.spec .. "! <<<|r")
            end
        end
    end
end
