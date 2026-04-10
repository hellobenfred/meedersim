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
