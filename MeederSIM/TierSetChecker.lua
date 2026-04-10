----------------------------------------------------------------------
-- MeederSIM - TierSetChecker
-- Midnight Season 1 Tier Set detection via Item IDs
-- No hidden tooltips, no SetHyperlink
----------------------------------------------------------------------

-- ALL tier set piece IDs for every class (Midnight S1)
local TIER_ITEM_IDS = {
    -- Warrior: Rage of the Night Ender
    [249955]=true,[249950]=true,[249953]=true,[249951]=true,[249952]=true,
    -- Paladin: Luminant Verdict's Vestments
    [249961]=true,[249959]=true,[249964]=true,[249962]=true,[249960]=true,
    -- Hunter: Primal Sentry's Camouflage
    [249988]=true,[249986]=true,[249991]=true,[249989]=true,[249987]=true,
    -- Rogue: Motley of the Grim Jest
    [250006]=true,[250004]=true,[250009]=true,[250007]=true,[250005]=true,
    -- Priest: Blind Oath's Burden
    [250051]=true,[250049]=true,[250054]=true,[250052]=true,[250050]=true,
    -- Shaman: Mantle of the Primal Core
    [249979]=true,[249977]=true,[249982]=true,[249980]=true,[249978]=true,
    -- Mage: Voidbreaker's Accordance
    [250060]=true,[250058]=true,[250063]=true,[250061]=true,[250059]=true,
    -- Warlock: Reign of the Abyssal Immolator
    [250042]=true,[250040]=true,[250045]=true,[250043]=true,[250041]=true,
    -- Monk: Way of Ra-den's Chosen
    [250015]=true,[250013]=true,[250018]=true,[250016]=true,[250014]=true,
    -- Druid: Sprouts of the Luminous Bloom
    [250024]=true,[250022]=true,[250027]=true,[250025]=true,[250023]=true,
    -- Demon Hunter: Devouring Reaver's Sheathe
    [250033]=true,[250031]=true,[250036]=true,[250034]=true,[250032]=true,
    -- Death Knight: Relentless Rider's Lament
    [249970]=true,[249968]=true,[249973]=true,[249971]=true,[249969]=true,
    -- Evoker: Livery of the Black Talon
    [249997]=true,[249995]=true,[250000]=true,[249998]=true,[249996]=true,
    -- Tier tokens (shared across armor types)
    [249355]=true,[249356]=true,[249357]=true,[249358]=true, -- Helm
    [249363]=true,[249364]=true,[249365]=true,[249366]=true, -- Shoulder
    [249351]=true,[249352]=true,[249353]=true,[249354]=true, -- Hands
    [249359]=true,[249360]=true,[249361]=true,[249362]=true, -- Legs
}

local TIER_SLOTS = { [1]=true, [3]=true, [5]=true, [10]=true, [7]=true }

local SET_BONUS_VALUE = {
    twoPc  = { raid = 2.5, mythicplus = 2.2 },
    fourPc = { raid = 5.0, mythicplus = 4.5 },
}

function MeederSIM:IsTierPiece(link)
    if not link then return false end
    local id = link:match("item:(%d+)")
    if id and TIER_ITEM_IDS[tonumber(id)] then return true end
    return false
end

function MeederSIM:CountTierPieces()
    local count = 0
    local tierSlots = {}
    local gear = MeederSIMCharDB.gear or {}
    for slotId in pairs(TIER_SLOTS) do
        local g = gear[slotId]
        if g and g.link and self:IsTierPiece(g.link) then
            count = count + 1
            tierSlots[slotId] = true
        end
    end
    return count, tierSlots
end

function MeederSIM:EvalTierImpact(newLink, slotId)
    if not TIER_SLOTS[slotId] then return nil end

    local curCount, curTierSlots = self:CountTierPieces()
    local newIsTier = self:IsTierPiece(newLink)
    local curIsTier = curTierSlots[slotId] or false

    local newCount = curCount
    if curIsTier and not newIsTier then newCount = curCount - 1 end
    if not curIsTier and newIsTier then newCount = curCount + 1 end
    if newCount == curCount then return nil end

    local r = { raidMod = 0, mplusMod = 0 }

    if curCount >= 4 and newCount < 4 then
        r.raidMod = -SET_BONUS_VALUE.fourPc.raid
        r.mplusMod = -SET_BONUS_VALUE.fourPc.mythicplus
        r.message = "[-] Bricht 4pc Tier-Set! (-" .. string.format("%.1f", SET_BONUS_VALUE.fourPc.raid) .. "% DPS)"
        r.breaking = true
    elseif curCount >= 2 and curCount < 4 and newCount < 2 then
        r.raidMod = -SET_BONUS_VALUE.twoPc.raid
        r.mplusMod = -SET_BONUS_VALUE.twoPc.mythicplus
        r.message = "[-] Bricht 2pc Tier-Set! (-" .. string.format("%.1f", SET_BONUS_VALUE.twoPc.raid) .. "% DPS)"
        r.breaking = true
    elseif curCount >= 3 and curCount < 4 and newCount >= 4 then
        r.raidMod = SET_BONUS_VALUE.fourPc.raid
        r.mplusMod = SET_BONUS_VALUE.fourPc.mythicplus
        r.message = "[+] Aktiviert 4pc Tier-Set! (+" .. string.format("%.1f", SET_BONUS_VALUE.fourPc.raid) .. "% DPS)"
        r.gaining = true
    elseif curCount < 2 and newCount >= 2 then
        r.raidMod = SET_BONUS_VALUE.twoPc.raid
        r.mplusMod = SET_BONUS_VALUE.twoPc.mythicplus
        r.message = "[+] Aktiviert 2pc Tier-Set! (+" .. string.format("%.1f", SET_BONUS_VALUE.twoPc.raid) .. "% DPS)"
        r.gaining = true
    else
        return nil
    end

    return r
end
