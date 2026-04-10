----------------------------------------------------------------------
-- MeederSIM - ItemComparator
-- Pawn-style comparison: Shows % item improvement, not DPS guess
----------------------------------------------------------------------

function MeederSIM:CompareItem(newLink)
    if not newLink then return nil end

    local slotId = self:GetSlotForItem(newLink)
    if not slotId then return nil end

    local weights = self:GetWeights()
    if not weights then return nil end

    local newItem = self:ParseItem(newLink, slotId)
    if not newItem then return nil end

    -- For rings/trinkets: compare against worse slot
    local compareSlot = slotId
    if slotId == 11 then compareSlot = self:WorseSlot(11, 12) end
    if slotId == 13 then compareSlot = self:WorseSlot(13, 14) end

    local gear = MeederSIMCharDB.gear or {}
    local current = gear[compareSlot]
    if not current then
        return 100, 100, { slot = compareSlot, current = nil, new = newItem,
            ilvlDiff = newItem.ilvl, hasStats = false }
    end

    local hasStats = self:HasMeaningfulStats(newItem.stats) and self:HasMeaningfulStats(current.stats)

    local raidPct, mplusPct

    if hasStats and weights.raid then
        -- Pawn-style: % Verbesserung nur über Sekundärstats
        local oldRaidScore = self:ItemScore(current.stats, weights.raid)
        local newRaidScore = self:ItemScore(newItem.stats, weights.raid)
        local oldMplusScore = self:ItemScore(current.stats, weights.mythicplus or weights.raid)
        local newMplusScore = self:ItemScore(newItem.stats, weights.mythicplus or weights.raid)

        if oldRaidScore > 0 then
            raidPct = ((newRaidScore - oldRaidScore) / oldRaidScore) * 100
        else
            raidPct = newRaidScore > 0 and 100 or 0
        end

        if oldMplusScore > 0 then
            mplusPct = ((newMplusScore - oldMplusScore) / oldMplusScore) * 100
        else
            mplusPct = newMplusScore > 0 and 100 or 0
        end

        -- Waffen: iLvl-Differenz als Bonus/Malus einrechnen
        -- Höheres iLvl = mehr Waffen-DPS + mehr Primärstat
        local ilvlDiff = (newItem.ilvl or 0) - (current.ilvl or 0)
        if (slotId == 16 or slotId == 17) and ilvlDiff ~= 0 then
            -- 1 iLvl auf Waffe ≈ 1% mehr DPS durch Waffen-DPS + Primärstat
            local ilvlBonus = ilvlDiff * 1.0
            raidPct = raidPct + ilvlBonus
            mplusPct = mplusPct + ilvlBonus
        elseif ilvlDiff ~= 0 then
            -- Andere Slots: iLvl-Diff als leichter Bonus (mehr Primärstat)
            local ilvlBonus = ilvlDiff * 0.3
            raidPct = raidPct + ilvlBonus
            mplusPct = mplusPct + ilvlBonus
        end
    else
        -- iLvl-Fallback
        local d = (newItem.ilvl or 0) - (current.ilvl or 0)
        local base = current.ilvl or 1
        raidPct = (d / base) * 100 * self:SlotWeight(slotId)
        mplusPct = raidPct
    end

    -- GESAMTBETRACHTUNG: Tier-Set Impact einrechnen
    local tierImpact = nil
    if self.EvalTierImpact then
        tierImpact = self:EvalTierImpact(newLink, compareSlot)
    end

    local tierRaidMod = 0
    local tierMplusMod = 0
    if tierImpact then
        tierRaidMod = tierImpact.raidMod or 0
        tierMplusMod = tierImpact.mplusMod or 0
        -- Tier-Set Bonus/Verlust direkt in die Prozente einrechnen
        raidPct = raidPct + tierRaidMod
        mplusPct = mplusPct + tierMplusMod
    end

    return raidPct, mplusPct, {
        slot = compareSlot,
        current = current,
        new = newItem,
        ilvlDiff = (newItem.ilvl or 0) - (current.ilvl or 0),
        hasStats = hasStats,
        tierImpact = tierImpact,
        tierRaidMod = tierRaidMod,
        tierMplusMod = tierMplusMod,
    }
end

----------------------------------------------------------------------
-- Weighted score of a single item (SECONDARY STATS ONLY)
-- Primary stats (Str/Agi/Int) are excluded because at equal iLvl
-- items have the same primary stat budget - only secondaries differ
----------------------------------------------------------------------
local PRIMARY_STATS = { strength=true, agility=true, intellect=true, stamina=true }

function MeederSIM:ItemScore(stats, weightTable)
    if not stats or not weightTable then return 0 end
    local score = 0
    for stat, value in pairs(stats) do
        if not PRIMARY_STATS[stat] then
            score = score + value * (weightTable[stat] or 0)
        end
    end
    return score
end

----------------------------------------------------------------------
-- Check if stats table has real secondary stat values
----------------------------------------------------------------------
function MeederSIM:HasMeaningfulStats(stats)
    if not stats then return false end
    for stat, val in pairs(stats) do
        if not PRIMARY_STATS[stat] and val and val > 0 then return true end
    end
    return false
end

----------------------------------------------------------------------
-- Slot weight (for iLvl fallback only)
----------------------------------------------------------------------
function MeederSIM:SlotWeight(slotId)
    if slotId == 16 or slotId == 17 then return 1.5 end
    if slotId == 13 or slotId == 14 then return 1.2 end
    if slotId == 2 or slotId == 11 or slotId == 12 or slotId == 15 then return 0.7 end
    return 1.0
end

function MeederSIM:WorseSlot(s1, s2)
    local gear = MeederSIMCharDB.gear or {}
    local g1, g2 = gear[s1], gear[s2]
    if not g1 then return s1 end
    if not g2 then return s2 end
    return (g1.ilvl or 0) <= (g2.ilvl or 0) and s1 or s2
end

----------------------------------------------------------------------
-- Formatting (no more ScoreToPercent - values ARE already percentages)
----------------------------------------------------------------------
function MeederSIM:FormatPercent(pct)
    if pct > 0 then return string.format("|cff00ff00+%.1f|r", pct) .. "%"
    elseif pct < 0 then return string.format("|cffff3333%.1f|r", pct) .. "%"
    else return "|cffffff000.0|r%" end
end

function MeederSIM:DiffColor(pct)
    if pct > 1 then return 0, 1, 0
    elseif pct < -1 then return 1, 0.2, 0.2
    else return 1, 1, 0 end
end
