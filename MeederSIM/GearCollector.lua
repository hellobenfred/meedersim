----------------------------------------------------------------------
-- MeederSIM - GearCollector
-- Reads equipped gear using GetInventoryItemLink (proven stable)
----------------------------------------------------------------------

local SLOTS = { 1, 2, 3, 15, 5, 9, 10, 6, 7, 8, 11, 12, 13, 14, 16, 17 }

local SLOT_SIMC = {
    [1]="head",[2]="neck",[3]="shoulder",[15]="back",[5]="chest",
    [9]="wrist",[10]="hands",[6]="waist",[7]="legs",[8]="feet",
    [11]="finger1",[12]="finger2",[13]="trinket1",[14]="trinket2",
    [16]="main_hand",[17]="off_hand",
}

MeederSIM.SLOTS = SLOTS
MeederSIM.SLOT_SIMC = SLOT_SIMC

----------------------------------------------------------------------
-- Collect all equipped gear
----------------------------------------------------------------------
function MeederSIM:CollectGear()
    local gear = {}
    local count = 0

    for _, sid in ipairs(SLOTS) do
        local link = GetInventoryItemLink("player", sid)
        if link then
            local item = self:ParseItem(link, sid)
            if item then
                gear[sid] = item
                count = count + 1
            end
        end
    end

    MeederSIMCharDB.gear = gear
    self:Debug("Gear: " .. count .. "/" .. #SLOTS)
    return gear, count
end

----------------------------------------------------------------------
-- Parse one item link into a data table
-- Uses only GetItemInfo (deprecated but crash-safe) and string parsing
----------------------------------------------------------------------
function MeederSIM:ParseItem(link, slotId)
    if not link then return nil end

    -- Parse item string from hyperlink
    local iStr = link:match("item:([%-?%d:]+)")
    if not iStr then return nil end

    local parts = {}
    for p in (iStr .. ":"):gmatch("(%-?%d*):") do
        parts[#parts + 1] = tonumber(p) or 0
    end

    local itemId = parts[1] or 0
    if itemId == 0 then return nil end

    -- Basic item info (GetItemInfo is deprecated but does NOT crash)
    local name, _, quality, ilvl, _, iType, iSubType, _, equipLoc, tex = GetItemInfo(link)

    -- Effective item level
    local effIlvl = ilvl
    if GetDetailedItemLevelInfo then
        local ok, detail = pcall(GetDetailedItemLevelInfo, link)
        if ok and detail then effIlvl = detail end
    end

    -- Bonus IDs
    local bonusIds = {}
    local nBonus = parts[13] or 0
    for i = 1, nBonus do
        local b = parts[13 + i]
        if b and b ~= 0 then bonusIds[#bonusIds + 1] = b end
    end

    -- Gems
    local gems = {}
    for i = 3, 6 do
        if (parts[i] or 0) > 0 then gems[#gems + 1] = parts[i] end
    end

    -- Stats (via safe StatReader)
    local stats = self:ReadStats(link)

    return {
        id = itemId,
        name = name or "?",
        quality = quality or 1,
        ilvl = effIlvl or ilvl or 0,
        link = link,
        slotId = slotId,
        equipLoc = equipLoc or "",
        texture = tex,
        bonusIds = bonusIds,
        enchantId = parts[2] or 0,
        gems = gems,
        stats = stats,
    }
end

----------------------------------------------------------------------
-- Get slot ID for an arbitrary item link
----------------------------------------------------------------------
function MeederSIM:GetSlotForItem(link)
    if not link then return nil end

    local equipLoc
    -- GetItemInfoInstant is fast and doesn't need cache
    if C_Item and C_Item.GetItemInfoInstant then
        local ok, id, _, _, loc = pcall(C_Item.GetItemInfoInstant, link)
        if ok and id then equipLoc = loc end
    end

    -- Fallback
    if not equipLoc or equipLoc == "" then
        local _, _, _, _, _, _, _, _, loc = GetItemInfo(link)
        equipLoc = loc
    end

    if not equipLoc or equipLoc == "" then return nil end

    local map = {
        INVTYPE_HEAD=1, INVTYPE_NECK=2, INVTYPE_SHOULDER=3,
        INVTYPE_CLOAK=15, INVTYPE_CHEST=5, INVTYPE_ROBE=5,
        INVTYPE_WRIST=9, INVTYPE_HAND=10, INVTYPE_WAIST=6,
        INVTYPE_LEGS=7, INVTYPE_FEET=8,
        INVTYPE_FINGER=11, INVTYPE_TRINKET=13,
        INVTYPE_WEAPON=16, INVTYPE_2HWEAPON=16,
        INVTYPE_WEAPONMAINHAND=16, INVTYPE_WEAPONOFFHAND=17,
        INVTYPE_HOLDABLE=17, INVTYPE_SHIELD=17,
        INVTYPE_RANGED=16, INVTYPE_RANGEDRIGHT=16,
    }
    return map[equipLoc]
end

----------------------------------------------------------------------
-- Check if item is equippable
----------------------------------------------------------------------
function MeederSIM:IsEquippable(link)
    if not link then return false end
    if C_Item and C_Item.GetItemInfoInstant then
        local ok, id, _, _, loc = pcall(C_Item.GetItemInfoInstant, link)
        if ok and id and loc and loc ~= "" and loc ~= "INVTYPE_NON_EQUIP" then
            return true
        end
    end
    return self:GetSlotForItem(link) ~= nil
end

----------------------------------------------------------------------
-- Test gear collection (debug command)
----------------------------------------------------------------------
----------------------------------------------------------------------
-- Dump all item links to SavedVariables (readable after /reload)
----------------------------------------------------------------------
function MeederSIM:DumpItemLinks()
    local dump = {}
    for _, sid in ipairs({1,2,3,15,5,9,10,6,7,8,11,12,13,14,16,17}) do
        local link = GetInventoryItemLink("player", sid)
        if link then
            local iStr = link:match("item:([%-?%d:]+)")
            local name = GetItemInfo(link) or "?"
            local ilvl = 0
            if GetDetailedItemLevelInfo then
                local ok, v = pcall(GetDetailedItemLevelInfo, link)
                if ok and v then ilvl = v end
            end
            dump[sid] = { link = iStr, name = name, ilvl = ilvl }
            self:Print("Slot " .. sid .. ": " .. name .. " (iLvl " .. ilvl .. ")")
        end
    end
    MeederSIMCharDB.linkDump = dump
    self:Print("|cff00ff00Links gespeichert! Bitte /reload machen.|r")
end

function MeederSIM:TestGear()
    self:Print("|cffffff00=== MeederSIM Gear Test ===|r")
    self:Print("Player: " .. tostring(self.name) .. " | " .. tostring(self.spec) .. " " .. tostring(self.class))
    self:Print("StatReader available: " .. tostring(self:CanReadStats()))

    for _, sid in ipairs({1, 5, 16, 13}) do
        local link = GetInventoryItemLink("player", sid)
        self:Print("Slot " .. sid .. ": " .. (link or "|cffff3333nil|r"))
        if link then
            local ok, item = pcall(self.ParseItem, self, link, sid)
            if ok and item then
                self:Print("  |cff00ff00" .. item.name .. " iLvl " .. item.ilvl .. "|r")
                -- Show actual stat values
                local sc = 0
                for stat, val in pairs(item.stats or {}) do
                    self:Print("    " .. stat .. " = |cffffff00" .. val .. "|r")
                    sc = sc + 1
                end
                if sc == 0 then
                    self:Print("    |cffff3333KEINE STATS gelesen! (Stats-API gibt leere Tabelle)|r")
                end
            elseif not ok then
                self:Print("  |cffff3333FEHLER: " .. tostring(item) .. "|r")
            else
                self:Print("  |cffff3333Parse gab nil|r")
            end
        end
    end

    self:Print("")
    local gear, count = self:CollectGear()
    self:Print("CollectGear: |cffffff00" .. count .. " Items|r")
    self:Print("Weights: " .. (self:GetWeights() and "|cff00ff00OK|r" or "|cffff3333FEHLT|r"))

    -- Show total stats across all gear
    local totalStats = {}
    for _, g in pairs(gear) do
        for stat, val in pairs(g.stats or {}) do
            totalStats[stat] = (totalStats[stat] or 0) + val
        end
    end
    local anyStats = false
    for stat, val in pairs(totalStats) do
        self:Print("  Total " .. stat .. " = |cffffff00" .. val .. "|r")
        anyStats = true
    end
    if not anyStats then
        self:Print("  |cffff3333KEINE STATS auf irgendeinem Item!|r")
        self:Print("  GetItemStatsSafe = " .. tostring(type((C_Item and C_Item.GetItemStats) or GetItemStats)))
    end

    -- Show what ScoreToPercent would calculate
    local totalScore = self:GetTotalEquippedScore()
    self:Print("TotalEquippedScore: |cffffff00" .. string.format("%.1f", totalScore) .. "|r")

    self:Print("|cffffff00=== Ende ===|r")
end
