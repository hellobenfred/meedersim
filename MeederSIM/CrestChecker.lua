----------------------------------------------------------------------
-- MeederSIM - CrestChecker
-- Zeigt ob ein Item mit Crests aufwertbar ist
-- Icon wird direkt aus der Currency-API gelesen (kein hardcoded Pfad)
----------------------------------------------------------------------

local CREST_TRACKS = {
    { name = "Adventurer", min = 220, max = 237, currId = 3383 },
    { name = "Veteran",    min = 233, max = 250, currId = 3341 },
    { name = "Champion",   min = 246, max = 263, currId = 3343 },
    { name = "Hero",       min = 259, max = 276, currId = 3345 },
    { name = "Myth",       min = 272, max = 289, currId = 3348 },
}

local CRESTS_PER_RANK = 20
local MAX_RANKS = 6

----------------------------------------------------------------------
-- Get crest info for an item
----------------------------------------------------------------------
function MeederSIM:GetCrestInfo(itemLink, ilvl)
    if not ilvl or ilvl < 220 then return nil end

    local track
    for _, t in ipairs(CREST_TRACKS) do
        if ilvl >= t.min and ilvl <= t.max then
            track = t
            break
        end
    end
    if not track then return nil end

    -- Current rank
    local range = track.max - track.min
    local step = range > 0 and (range / (MAX_RANKS - 1)) or 1
    local rank = math.min(MAX_RANKS, math.floor((ilvl - track.min) / step) + 1)
    local remaining = MAX_RANKS - rank
    local canUpgrade = remaining > 0
    local crestsNeeded = remaining * CRESTS_PER_RANK

    -- Player crests + icon from Currency API
    local playerCrests = 0
    local iconFileID = nil
    local currName = track.name .. " Dawncrest"

    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, track.currId)
        if ok and info then
            playerCrests = info.quantity or 0
            iconFileID = info.iconFileID
            if info.name and info.name ~= "" then
                currName = info.name  -- Lokalisierter Name aus der API
            end
        end
    end

    return {
        canUpgrade = canUpgrade,
        trackName = track.name,
        currName = currName,
        iconFileID = iconFileID,
        rank = rank,
        maxRank = MAX_RANKS,
        remaining = remaining,
        crestsNeeded = crestsNeeded,
        playerCrests = playerCrests,
        hasEnough = playerCrests >= CRESTS_PER_RANK,
        maxIlvl = track.max,
    }
end

----------------------------------------------------------------------
-- Format for tooltip
----------------------------------------------------------------------
function MeederSIM:FormatCrestInfo(c)
    if not c then return nil end
    local lines = {}

    -- Icon: |T<fileID>:h:w|t oder |T<path>:h:w|t
    local iconTag = ""
    if c.iconFileID then
        iconTag = "|T" .. c.iconFileID .. ":14:14|t "
    end

    if c.canUpgrade then
        local color = c.hasEnough and "|cff00ff00" or "|cffff8800"
        local status = c.hasEnough and "[Genug Crests]" or "[Crests fehlen]"

        lines[#lines + 1] = iconTag .. color .. "Aufwertbar mit " .. c.currName .. "|r"
        lines[#lines + 1] = "  " .. color .. "Stufe " .. c.rank .. "/" .. c.maxRank ..
            " | " .. c.crestsNeeded .. " Crests bis Max | Du hast: " ..
            c.playerCrests .. " " .. status .. "|r"
    else
        lines[#lines + 1] = iconTag .. "|cff888888Bereits auf Maximum|r"
    end

    return lines
end
