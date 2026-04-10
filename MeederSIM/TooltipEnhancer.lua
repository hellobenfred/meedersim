----------------------------------------------------------------------
-- MeederSIM - TooltipEnhancer
-- Shows WHY an item is better/worse based on stat priorities
-- Multi-spec comparison for all specs of your class
----------------------------------------------------------------------

local HEADER = "-- MeederSIM --"

function MeederSIM:InitTooltips()
    if not TooltipDataProcessor or not TooltipDataProcessor.AddTooltipPostCall then return end
    if not Enum or not Enum.TooltipDataType or not Enum.TooltipDataType.Item then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
        local ok, err = pcall(MeederSIM.OnTooltip, MeederSIM, tooltip)
        if not ok then MeederSIM:Debug("Tooltip: " .. tostring(err)) end
    end)
end

function MeederSIM:OnTooltip(tooltip)
    if not tooltip or not self.initialized then return end
    if not MeederSIMDB.settings.showTooltip then return end
    if not self.class or not self.spec then return end
    -- Nicht bewerten wenn Tooltip aus dem BiS-Fenster kommt
    if self._bisTooltipActive then return end

    if not tooltip.GetItem then return end
    local ok, _, link = pcall(tooltip.GetItem, tooltip)
    if not ok or not link then return end
    if not self:IsEquippable(link) then return end

    -- Prevent duplicates
    for i = 1, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        if line and line:GetText() == HEADER then return end
    end

    if not MeederSIMCharDB.gear or not next(MeederSIMCharDB.gear) then return end

    -- Check if this is an equipped item
    local isEquipped = false
    local equippedSlotId = nil
    for sid, g in pairs(MeederSIMCharDB.gear) do
        if g.link == link then
            isEquipped = true
            equippedSlotId = sid
            break
        end
    end

    -- For equipped items: show BiS status across ALL profiles
    if isEquipped then
        self:InitBiS()
        -- Prevent duplicates
        for i = 1, tooltip:NumLines() do
            local line = _G[tooltip:GetName() .. "TextLeft" .. i]
            if line and line:GetText() == HEADER then return end
        end

        local showHeader = false

        if MeederSIMDB.settings.showBisOnEquipped and MeederSIMCharDB.bisProfiles then
            local eq = MeederSIMCharDB.gear and MeederSIMCharDB.gear[equippedSlotId]
            if eq then
                -- Check this item against ALL 3 profiles
                local bisFor = {}
                for _, pName in ipairs({"overall", "raid", "mplus"}) do
                    local profile = MeederSIMCharDB.bisProfiles[pName]
                    if profile then
                        local bisItem = profile[equippedSlotId]
                        -- Direct match
                        local match = bisItem and bisItem.id == eq.id
                        -- Ring/Trinket: check both slots
                        if not match and (equippedSlotId == 11 or equippedSlotId == 12) then
                            local b1, b2 = profile[11], profile[12]
                            match = (b1 and b1.id == eq.id) or (b2 and b2.id == eq.id)
                        end
                        if not match and (equippedSlotId == 13 or equippedSlotId == 14) then
                            local b1, b2 = profile[13], profile[14]
                            match = (b1 and b1.id == eq.id) or (b2 and b2.id == eq.id)
                        end
                        if match then bisFor[#bisFor + 1] = pName end
                    end
                end

                if not showHeader then tooltip:AddLine(" "); tooltip:AddLine(HEADER, 0, 0.8, 1); showHeader = true end

                if #bisFor > 0 then
                    local labels = { overall = "Overall", raid = "Raid", mplus = "M+" }
                    local names = {}
                    for _, p in ipairs(bisFor) do names[#names + 1] = labels[p] or p end
                    tooltip:AddLine("|cff00ff00[BiS] Best in Slot für: " .. table.concat(names, ", ") .. "|r", 0, 1, 0)
                else
                    tooltip:AddLine("|cffff8800Nicht Best in Slot|r", 1, 0.5, 0)
                    -- Show the CORRECT BiS for this slot
                    -- For rings/trinkets: show the BiS that ISN'T already equipped elsewhere
                    local oBis = MeederSIMCharDB.bisProfiles.overall
                    if oBis then
                        local targetBis = oBis[equippedSlotId]

                        -- Ring/Trinket: if the BiS for this slot is already in the other slot,
                        -- show the OTHER BiS instead
                        if (equippedSlotId == 13 or equippedSlotId == 14) then
                            local otherSlot = equippedSlotId == 13 and 14 or 13
                            local otherGear = MeederSIMCharDB.gear and MeederSIMCharDB.gear[otherSlot]
                            if targetBis and otherGear and otherGear.id == targetBis.id then
                                -- The BiS for this slot is already worn in the other slot
                                -- Show the other BiS trinket instead
                                targetBis = oBis[otherSlot]
                            end
                        end
                        if (equippedSlotId == 11 or equippedSlotId == 12) then
                            local otherSlot = equippedSlotId == 11 and 12 or 11
                            local otherGear = MeederSIMCharDB.gear and MeederSIMCharDB.gear[otherSlot]
                            if targetBis and otherGear and otherGear.id == targetBis.id then
                                targetBis = oBis[otherSlot]
                            end
                        end

                        if targetBis then
                            tooltip:AddLine("  BiS: |cffffff00" .. (targetBis.name or "?") .. "|r", 0.7, 0.7, 0.7)
                        end
                    end
                end
            end
        end

        -- Enchant check (respects setting)
        local enchStatus, enchInfo = self:GetEnchantStatus(equippedSlotId)
        if enchStatus == "missing" and MeederSIMDB.settings.showEnchantWarning then
            if not showHeader then tooltip:AddLine(" "); tooltip:AddLine(HEADER, 0, 0.8, 1); showHeader = true end
            tooltip:AddLine("|cffff3333[!] Verzauberung fehlt! (" .. enchInfo .. ")|r", 1, 0.2, 0.2)
        end

        if showHeader then tooltip:Show() end
        return
    end

    -- Compare for active spec
    local raidDiff, mplusDiff, details = self:CompareItem(link)
    if not raidDiff then return end

    local hasStats = details and details.hasStats
    -- CompareItem already returns percentages directly
    local raidPct = raidDiff
    local mplusPct = mplusDiff
    local ilvlDiff = details and details.ilvlDiff or 0

    -- === Build tooltip ===
    tooltip:AddLine(" ")
    tooltip:AddLine(HEADER, 0, 0.8, 1)

    -- VERDICT (threshold 1% for meaningful difference)
    local isUp = raidPct > 1 or mplusPct > 1
    local isDown = raidPct < -1 and mplusPct < -1
    local isMixed = (raidPct > 1 and mplusPct < -1) or (raidPct < -1 and mplusPct > 1)

    if isUp and not isMixed then
        tooltip:AddLine("[+] UPGRADE für " .. self.spec, 0, 1, 0)
    elseif isDown then
        tooltip:AddLine("[-] DOWNGRADE für " .. self.spec, 1, 0.2, 0.2)
    elseif isMixed then
        tooltip:AddLine("[~] Gemischt für " .. self.spec, 1, 1, 0)
    else
        tooltip:AddLine("[=] Kein Unterschied für " .. self.spec, 0.6, 0.6, 0.6)
    end

    -- Raid + M+
    tooltip:AddDoubleLine(
        "  Raid: " .. self:FormatPercent(raidPct),
        "M+: " .. self:FormatPercent(mplusPct),
        1, 1, 1, 1, 1, 1
    )

    -- iLvl
    if ilvlDiff ~= 0 and details.current and details.new then
        local sign = ilvlDiff > 0 and "|cff00ff00+" or "|cffff3333"
        tooltip:AddLine("  iLvl: " .. details.current.ilvl .. " > " .. details.new.ilvl ..
            " (" .. sign .. ilvlDiff .. "|r)", 0.7, 0.7, 0.7)
    end

    -- GESAMTBETRACHTUNG: Tier-Set Impact wenn relevant
    if details.tierImpact then
        local ti = details.tierImpact
        if ti.breaking then
            tooltip:AddLine("|cffff3333" .. ti.message .. "|r", 1, 0.2, 0.2)
            tooltip:AddLine("|cff888888(Bereits in Raid/M+ Wertung eingerechnet)|r", 0.5, 0.5, 0.5)
        elseif ti.gaining then
            tooltip:AddLine("|cff00ff00" .. ti.message .. "|r", 0, 1, 0)
            tooltip:AddLine("|cff888888(Bereits in Raid/M+ Wertung eingerechnet)|r", 0.5, 0.5, 0.5)
        end
    end

    -- STAT DETAILS with priority context
    if hasStats and details.current and details.new then
        local weights = self:GetWeights()
        if weights and weights.raid then
            self:AddStatContext(tooltip, details.current.stats, details.new.stats, weights.raid)
        end
    end

    -- OTHER SPECS
    local otherSpecs = self:CompareOtherSpecs(link, details)
    if otherSpecs and #otherSpecs > 0 then
        tooltip:AddLine(" ")
        tooltip:AddLine("Andere Specs deiner Klasse:", 0.5, 0.7, 1)
        for _, os in ipairs(otherSpecs) do
            local tag = os.raidPct > 0.3 and "|cff00ff00[+]|r" or
                        (os.raidPct < -0.3 and "|cffff3333[-]|r" or "|cffffff00[=]|r")
            tooltip:AddDoubleLine(
                "  " .. os.spec,
                tag .. " Raid: " .. self:FormatPercent(os.raidPct) .. "  M+: " .. self:FormatPercent(os.mplusPct),
                0.7, 0.7, 0.7, 1, 1, 1
            )
        end
    end

    -- TIER SET IMPACT
    if details.slot and details.new then
        local tierImpact = self:EvalTierImpact(link, details.slot)
        if tierImpact then
            tooltip:AddLine(" ")
            if tierImpact.breaking then
                tooltip:AddLine("  |cffff3333" .. tierImpact.message .. "|r", 1, 0.2, 0.2)
            elseif tierImpact.gaining then
                tooltip:AddLine("  |cff00ff00" .. tierImpact.message .. "|r", 0, 1, 0)
            end
            -- Show current set count
            local curCount = self:CountTierPieces()
            tooltip:AddLine("  Aktuell: " .. curCount .. "pc Tier-Set", 0.6, 0.6, 0.6)
        end
    end

    -- BIS CHECK
    if details.new and details.new.id then
        local slotId = details.slot or self:GetSlotForItem(link)
        if slotId then
            -- Check active spec
            local isBiS = self:IsItemBiS(details.new.id, slotId, self.class, self.spec)
            -- Check all specs
            local bisSpecs = self:CheckBiSAllSpecs(details.new.id, slotId)

            if isBiS then
                tooltip:AddLine(" ")
                tooltip:AddLine("|cffff8800>>> BEST IN SLOT für " .. self.spec .. " <<<|r", 1, 0.5, 0)
                -- Drop-Quelle für BiS
                local src = self:FormatItemSource(details.new.id)
                if src then tooltip:AddLine("  Droppt: " .. src, 0.7, 0.7, 0.7) end
            elseif isAnyUpgrade then
                -- Temporäres Upgrade: besser als aktuell aber nicht BiS
                tooltip:AddLine(" ")
                tooltip:AddLine("|cffffff00Temporäres Upgrade (nicht BiS)|r", 1, 1, 0)
                -- Zeige was das BiS für diesen Slot wäre
                self:InitBiS()
                local oBis = MeederSIMCharDB.bisProfiles and MeederSIMCharDB.bisProfiles.overall
                local bisForSlot = oBis and oBis[slotId]
                if bisForSlot then
                    tooltip:AddLine("  BiS: |cffffff00" .. (bisForSlot.name or "?") .. "|r", 0.7, 0.7, 0.7)
                    local src = self:FormatItemSource(bisForSlot.id)
                    if src then tooltip:AddLine("  Droppt: " .. src, 0.6, 0.6, 0.6) end
                end
            elseif bisSpecs then
                tooltip:AddLine(" ")
                local specList = {}
                for specName in pairs(bisSpecs) do specList[#specList + 1] = specName end
                tooltip:AddLine("|cffff8800BiS für: " .. table.concat(specList, ", ") .. "|r", 1, 0.5, 0)
            end
        end
    end

    -- CREST INFO (nur bei Upgrades - bei Downgrades irrelevant)
    local isAnyUpgrade = raidPct > 1 or mplusPct > 1
    if isAnyUpgrade and details.new then
        local crestInfo = self:GetCrestInfo(link, details.new.ilvl)
        if crestInfo and crestInfo.canUpgrade then
            tooltip:AddLine(" ")
            local crestLines = self:FormatCrestInfo(crestInfo)
            if crestLines then
                for _, line in ipairs(crestLines) do
                    tooltip:AddLine("  " .. line)
                end
            end
        end
    end

    -- Source hint
    if not hasStats then
        tooltip:AddLine("  |cff555555Ohne Stats - nur iLvl-Vergleich|r", 0.3, 0.3, 0.3)
    end

    tooltip:Show()
end

----------------------------------------------------------------------
-- Add stat context: show each stat change with priority ranking
-- "Haste: +42 (Dein bester Sekundaerstat!)"
----------------------------------------------------------------------
function MeederSIM:AddStatContext(tooltip, oldStats, newStats, raidWeights)
    if not oldStats or not newStats or not raidWeights then return end

    -- Build sorted stat priority list
    local priorities = {}
    for stat, weight in pairs(raidWeights) do
        -- Skip primary stats for priority ranking
        if stat ~= "strength" and stat ~= "agility" and stat ~= "intellect" and stat ~= "stamina" then
            priorities[#priorities + 1] = { stat = stat, weight = weight }
        end
    end
    table.sort(priorities, function(a, b) return a.weight > b.weight end)

    -- Build rank lookup: stat → "#1", "#2" etc.
    local rank = {}
    for i, p in ipairs(priorities) do
        rank[p.stat] = i
    end

    local SHORT = {
        strength="Str", agility="Agi", intellect="Int", stamina="Sta",
        crit="Crit", haste="Haste", mastery="Mastery", versatility="Vers",
        leech="Leech", speed="Speed",
    }

    -- Collect all stat diffs
    local allStats = {}
    for k in pairs(oldStats) do allStats[k] = true end
    for k in pairs(newStats) do allStats[k] = true end

    local changes = {}
    for stat in pairs(allStats) do
        local old = oldStats[stat] or 0
        local new = newStats[stat] or 0
        local diff = new - old
        if diff ~= 0 and SHORT[stat] then
            changes[#changes + 1] = {
                stat = stat, name = SHORT[stat], diff = diff,
                rank = rank[stat], weight = raidWeights[stat] or 0,
                absDiff = math.abs(diff),
            }
        end
    end

    if #changes == 0 then return end

    -- Sort by impact (diff * weight)
    table.sort(changes, function(a, b)
        return math.abs(a.diff * a.weight) > math.abs(b.diff * b.weight)
    end)

    tooltip:AddLine(" ")
    tooltip:AddLine("Stat-Änderungen:", 0.5, 0.7, 1)

    for i, c in ipairs(changes) do
        if i > 5 then break end

        local color = c.diff > 0 and "|cff00ff00+" or "|cffff3333"
        local context = ""

        -- Add priority context for secondary stats
        if c.rank then
            if c.rank == 1 then
                context = c.diff > 0 and " (Dein bester Stat!)" or " (Verlierst besten Stat!)"
            elseif c.rank == 2 then
                context = c.diff > 0 and " (Prio #2)" or " (Prio #2 Verlust)"
            elseif c.rank >= 4 then
                context = c.diff > 0 and " (niedriger Prio)" or ""
            end
        end

        local contextColor = c.diff > 0 and "|cff88ff88" or "|cffff8888"
        tooltip:AddLine(
            "  " .. c.name .. ": " .. color .. c.diff .. "|r" .. contextColor .. context .. "|r",
            0.8, 0.8, 0.8
        )
    end
end

----------------------------------------------------------------------
-- Compare item against all OTHER specs of the player's class
----------------------------------------------------------------------
function MeederSIM:CompareOtherSpecs(link, details)
    if not self.Weights or not self.class then return nil end
    local classWeights = self.Weights[self.class]
    if not classWeights then return nil end

    local newItem = details and details.new
    local currentGear = details and details.current
    if not newItem then return nil end

    local results = {}
    for specName, specWeights in pairs(classWeights) do
        if specName ~= self.spec then
            local raidPct, mplusPct
            local hasStats = self:HasMeaningfulStats(newItem.stats) and currentGear and self:HasMeaningfulStats(currentGear.stats)

            if hasStats and specWeights.raid then
                local oldR = self:ItemScore(currentGear.stats, specWeights.raid)
                local newR = self:ItemScore(newItem.stats, specWeights.raid)
                local oldM = self:ItemScore(currentGear.stats, specWeights.mythicplus or specWeights.raid)
                local newM = self:ItemScore(newItem.stats, specWeights.mythicplus or specWeights.raid)
                raidPct = oldR > 0 and ((newR - oldR) / oldR * 100) or 0
                mplusPct = oldM > 0 and ((newM - oldM) / oldM * 100) or 0
            else
                local d = (newItem.ilvl or 0) - (currentGear and currentGear.ilvl or 0)
                local base = currentGear and currentGear.ilvl or 1
                raidPct = (d / base) * 100
                mplusPct = raidPct
            end

            results[#results + 1] = {
                spec = specName,
                raidPct = raidPct,
                mplusPct = mplusPct,
            }
        end
    end

    table.sort(results, function(a, b) return a.raidPct > b.raidPct end)
    return results
end

----------------------------------------------------------------------
-- Format stat differences as compact text (used elsewhere)
----------------------------------------------------------------------
function MeederSIM:GetStatDiffText(oldStats, newStats)
    if not oldStats or not newStats then return nil end
    local allStats = {}
    for k in pairs(oldStats) do allStats[k] = true end
    for k in pairs(newStats) do allStats[k] = true end

    local SHORT = {
        strength="Str",agility="Agi",intellect="Int",stamina="Sta",
        crit="Crit",haste="Haste",mastery="Mast",versatility="Vers",
    }

    local parts = {}
    for stat in pairs(allStats) do
        local diff = (newStats[stat] or 0) - (oldStats[stat] or 0)
        if diff ~= 0 and SHORT[stat] then
            local color = diff > 0 and "|cff00ff00+" or "|cffff3333"
            parts[#parts+1] = { txt = SHORT[stat]..": "..color..diff.."|r", abs = math.abs(diff) }
        end
    end
    if #parts == 0 then return nil end
    table.sort(parts, function(a,b) return a.abs > b.abs end)
    local t = {}
    for i = 1, math.min(4, #parts) do t[#t+1] = parts[i].txt end
    return table.concat(t, "  ")
end
