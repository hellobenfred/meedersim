----------------------------------------------------------------------
-- MeederSIM - StatReader
-- Safe stat reading using the Pawn/SimpleItemLevel fallback pattern
-- NEVER uses SetHyperlink or hidden GameTooltip frames
----------------------------------------------------------------------

-- The safe fallback pattern (from Pawn/SimpleItemLevel):
-- Try C_Item.GetItemStats first, fall back to global GetItemStats
local GetItemStatsSafe = (C_Item and C_Item.GetItemStats) or GetItemStats

-- Stat key normalization
local STAT_MAP = {
    ITEM_MOD_STRENGTH_SHORT = "strength",
    ITEM_MOD_AGILITY_SHORT = "agility",
    ITEM_MOD_INTELLECT_SHORT = "intellect",
    ITEM_MOD_STAMINA_SHORT = "stamina",
    ITEM_MOD_CRIT_RATING_SHORT = "crit",
    ITEM_MOD_HASTE_RATING_SHORT = "haste",
    ITEM_MOD_MASTERY_RATING_SHORT = "mastery",
    ITEM_MOD_VERSATILITY = "versatility",
    ITEM_MOD_CR_AVOIDANCE_SHORT = "avoidance",
    ITEM_MOD_CR_LIFESTEAL_SHORT = "leech",
    ITEM_MOD_CR_SPEED_SHORT = "speed",
    ITEM_MOD_AGILITY_STRENGTH_SHORT = "agility",
    ITEM_MOD_AGILITY_INTELLECT_SHORT = "agility",
    ITEM_MOD_STRENGTH_INTELLECT_SHORT = "strength",
}

----------------------------------------------------------------------
-- Read stats for an item link (safe, pcall-wrapped)
----------------------------------------------------------------------
function MeederSIM:ReadStats(itemLink)
    if not itemLink then return {} end
    if not GetItemStatsSafe then return {} end

    local ok, rawStats = pcall(GetItemStatsSafe, itemLink)
    if not ok or type(rawStats) ~= "table" then return {} end

    local stats = {}
    for rawKey, value in pairs(rawStats) do
        local normalized = STAT_MAP[rawKey]
        if normalized then
            stats[normalized] = (stats[normalized] or 0) + value
        end
    end
    return stats
end

----------------------------------------------------------------------
-- Check if stat reading is available at all
----------------------------------------------------------------------
function MeederSIM:CanReadStats()
    return GetItemStatsSafe ~= nil
end
