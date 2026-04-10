----------------------------------------------------------------------
-- MeederSIM - Item Drop Sources
-- Wo droppen die wichtigsten Items?
-- Midnight Season 1: Voidspire, Dreamrift, Quel'Danas, M+ Dungeons
----------------------------------------------------------------------

MeederSIM.ItemSources = {
    -- The Voidspire (Raid, 6 Bosse)
    [249296] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- Alah'endal, the Dawnsong
    [249277] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- Bellamy's Final Judgement
    [249295] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- 1H Sword
    [249344] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- Light Company Guidon (Trinket)
    [249335] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- Cloak
    [249341] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Volatile Void Suffuser
    [249340] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Wraps of Cosmic Madness
    [249337] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Ribbon of Coiled Malice (Neck)
    [249368] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Eternal Voidsong Chain (Neck)
    [250247] = { source = "Vaelgor & Ezzorak", instance = "The Voidspire", type = "raid" }, -- Amulet of the Abyssal Hymn
    [249342] = { source = "Vaelgor & Ezzorak", instance = "The Voidspire", type = "raid" }, -- Heart of Ancient Hunger (Trinket)
    [249920] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Eye of Midnight (Ring)
    [249919] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Ring
    [249370] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Cloak
    [260235] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Umbral Plume (Trinket)
    [249346] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Trinket
    [249381] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Greaves (Feet)
    [249380] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Belt
    [249382] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Feet
    [249374] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Belt
    [249376] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Belt
    [249369] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Ring
    [249336] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Ring

    -- The Dreamrift (1 Boss)
    [249343] = { source = "Chimaerus", instance = "The Dreamrift", type = "raid" }, -- Gaze of the Alnseer

    -- March on Quel'Danas (2 Bosse)
    [249809] = { source = "Midnight Falls", instance = "Quel'Danas", type = "raid" }, -- Locus-Walker's Ribbon
    [249808] = { source = "Midnight Falls", instance = "Quel'Danas", type = "raid" }, -- Litany of Lightblind Wrath
    [249810] = { source = "Midnight Falls", instance = "Quel'Danas", type = "raid" }, -- Trinket
    [249811] = { source = "Midnight Falls", instance = "Quel'Danas", type = "raid" }, -- Light of Cosmic Crescendo
    [249806] = { source = "Midnight Falls", instance = "Quel'Danas", type = "raid" }, -- Trinket

    -- Tier-Set Tokens (Boss-Zuordnung)
    [249952] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Warrior Head
    [249950] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Warrior Shoulder
    [249955] = { source = "Chimaerus", instance = "The Dreamrift", type = "raid" }, -- Warrior Chest
    [249953] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Warrior Hands
    [249951] = { source = "Vaelgor & Ezzorak", instance = "The Voidspire", type = "raid" }, -- Warrior Legs

    -- DH Tier
    [250033] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" },
    [250031] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" },
    [250036] = { source = "Chimaerus", instance = "The Dreamrift", type = "raid" },
    [250034] = { source = "Vorasius", instance = "The Voidspire", type = "raid" },
    [250032] = { source = "Vaelgor & Ezzorak", instance = "The Voidspire", type = "raid" },

    -- Waffen
    [260408] = { source = "Vaelgor & Ezzorak", instance = "The Voidspire", type = "raid" }, -- Lightless Lament
    [249286] = { source = "Fallen-King Salhadaar", instance = "The Voidspire", type = "raid" }, -- Brazier
    [249283] = { source = "Vorasius", instance = "The Voidspire", type = "raid" }, -- Belo'melorn
    [249279] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- Gun
    [249288] = { source = "Imperator Averzian", instance = "The Voidspire", type = "raid" }, -- Bow
    [249302] = { source = "Lightblinded Vanguard", instance = "The Voidspire", type = "raid" }, -- Polearm

    -- M+ Dungeon Items
    [193701] = { source = "Overgrown Ancient", instance = "Algeth'ar Academy", type = "mplus" }, -- Algeth'ar Puzzle Box
    [193708] = { source = "Crawth", instance = "Algeth'ar Academy", type = "mplus" }, -- Platinum Star Band
    [250144] = { source = "Kael'thas Sunstrider", instance = "Windrunner Spire", type = "mplus" }, -- Emberwing Feather
    [251217] = { source = "Endboss", instance = "Void Caverns", type = "mplus" }, -- Occlusion of Void
    [251093] = { source = "Endboss", instance = "Void Caverns", type = "mplus" }, -- Omission of Light
    [251513] = { source = "Endboss", instance = "Quel'Danas Dungeon", type = "mplus" }, -- Loa Worshiper's Band
    [250256] = { source = "Endboss", instance = "Windrunner Spire", type = "mplus" }, -- Heart of Wind
    [260312] = { source = "Endboss", instance = "M+ Dungeon", type = "mplus" }, -- Cloak
    [258575] = { source = "Endboss", instance = "M+ Dungeon", type = "mplus" }, -- Cloak

    -- Crafted Items
    [237834] = { source = "Schmiedekunst", instance = "Crafted", type = "crafted" }, -- Spellbreaker's Bracers
    [237840] = { source = "Schmiedekunst", instance = "Crafted", type = "crafted" }, -- Spellbreaker's Warglaive
    [237850] = { source = "Schmiedekunst", instance = "Crafted", type = "crafted" }, -- Crafted weapon
    [239656] = { source = "Schneiderei", instance = "Crafted", type = "crafted" }, -- Adherent's Silken Shroud
    [239648] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted bracers
    [239660] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted bracers
    [239664] = { source = "Schneiderei", instance = "Crafted", type = "crafted" }, -- Crafted belt
    [244576] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted bracers
    [244573] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted belt
    [244569] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted boots
    [244575] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted gloves
    [244584] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted bracers
    [244611] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted belt
    [244610] = { source = "Lederverarbeitung", instance = "Crafted", type = "crafted" }, -- Crafted boots
}

----------------------------------------------------------------------
-- Get source info for an item
----------------------------------------------------------------------
function MeederSIM:GetItemSource(itemId)
    if not itemId then return nil end
    return self.ItemSources[itemId]
end

----------------------------------------------------------------------
-- Format source for display
----------------------------------------------------------------------
function MeederSIM:FormatItemSource(itemId)
    local src = self:GetItemSource(itemId)
    if not src then return nil end

    local typeColors = {
        raid = "|cffff8800",
        mplus = "|cff00ccff",
        crafted = "|cff00ff00",
        world = "|cffffff00",
    }

    local color = typeColors[src.type] or "|cffffffff"
    return color .. src.source .. " (" .. src.instance .. ")|r"
end
