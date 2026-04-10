----------------------------------------------------------------------
-- MeederSIM - ExportString
-- Generates SimC-compatible export string
----------------------------------------------------------------------

local CLASS_SIMC = {
    WARRIOR="warrior",PALADIN="paladin",HUNTER="hunter",ROGUE="rogue",
    PRIEST="priest",SHAMAN="shaman",MAGE="mage",WARLOCK="warlock",
    MONK="monk",DRUID="druid",DEMONHUNTER="demonhunter",
    DEATHKNIGHT="deathknight",EVOKER="evoker",
}

local RACE_SIMC = {
    Human="human",Dwarf="dwarf",NightElf="night_elf",Gnome="gnome",
    Draenei="draenei",Worgen="worgen",Pandaren="pandaren",
    Orc="orc",Scourge="undead",Tauren="tauren",Troll="troll",
    BloodElf="blood_elf",Goblin="goblin",VoidElf="void_elf",
    LightforgedDraenei="lightforged_draenei",HighmountainTauren="highmountain_tauren",
    Nightborne="nightborne",MagharOrc="maghar_orc",DarkIronDwarf="dark_iron_dwarf",
    ZandalariTroll="zandalari_troll",KulTiran="kul_tiran",
    Mechagnome="mechagnome",Vulpera="vulpera",Dracthyr="dracthyr",
    EarthenDwarf="earthen_dwarf",
}

function MeederSIM:GenerateExport()
    self:UpdatePlayerInfo()
    self:CollectGear()

    local lines = {}
    lines[#lines + 1] = "# MeederSIM by IT-Meeder.de"
    lines[#lines + 1] = "# " .. date("%Y-%m-%d %H:%M:%S")
    lines[#lines + 1] = ""

    local cls = CLASS_SIMC[self.class] or (self.class or "warrior"):lower()
    local spec = (self.spec or "unknown"):lower():gsub(" ", "_")
    local race = RACE_SIMC[self.race] or (self.race or "human"):lower():gsub(" ", "_")

    lines[#lines + 1] = cls .. '="' .. (self.name or "Unknown") .. '"'
    lines[#lines + 1] = "level=" .. (self.level or 80)
    lines[#lines + 1] = "race=" .. race
    lines[#lines + 1] = "spec=" .. spec

    -- Talents
    if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
        local configID = C_ClassTalents.GetActiveConfigID()
        if configID and C_Traits and C_Traits.GenerateImportString then
            local ok, talentStr = pcall(C_Traits.GenerateImportString, configID)
            if ok and talentStr and talentStr ~= "" then
                lines[#lines + 1] = "talents=" .. talentStr
            end
        end
    end

    lines[#lines + 1] = ""

    -- Gear
    local gear = MeederSIMCharDB.gear or {}
    for _, sid in ipairs(self.SLOTS) do
        local g = gear[sid]
        if g and g.link then
            local simcLine = self:ItemToSimC(g.link, self.SLOT_SIMC[sid])
            if simcLine then
                lines[#lines + 1] = simcLine
            end
        end
    end

    local export = table.concat(lines, "\n")
    MeederSIMCharDB.lastExport = export
    return export
end

function MeederSIM:ItemToSimC(link, slotName)
    if not link or not slotName then return nil end

    local iStr = link:match("item:([%-?%d:]+)")
    if not iStr then return nil end

    local parts = {}
    for p in (iStr .. ":"):gmatch("(%-?%d*):") do
        parts[#parts + 1] = tonumber(p) or 0
    end

    local itemId = parts[1] or 0
    if itemId == 0 then return nil end

    local result = { slotName .. "=,id=" .. itemId }

    -- Bonus IDs
    local nBonus = parts[13] or 0
    local bonus = {}
    for i = 1, nBonus do
        local b = parts[13 + i]
        if b and b ~= 0 then bonus[#bonus + 1] = b end
    end
    if #bonus > 0 then result[#result + 1] = "bonus_id=" .. table.concat(bonus, "/") end

    -- Enchant
    if (parts[2] or 0) > 0 then result[#result + 1] = "enchant_id=" .. parts[2] end

    -- Gems
    local gems = {}
    for i = 3, 6 do
        if (parts[i] or 0) > 0 then gems[#gems + 1] = parts[i] end
    end
    if #gems > 0 then result[#result + 1] = "gem_id=" .. table.concat(gems, "/") end

    -- Effective ilvl
    local ilvl
    if GetDetailedItemLevelInfo then
        local ok, v = pcall(GetDetailedItemLevelInfo, link)
        if ok and v then ilvl = v end
    end
    if ilvl then result[#result + 1] = "ilevel=" .. ilvl end

    return table.concat(result, ",")
end

----------------------------------------------------------------------
-- Show export dialog
----------------------------------------------------------------------
function MeederSIM:ShowExport()
    local export = self:GenerateExport()
    if not export then
        self:Print("Export fehlgeschlagen.")
        return
    end

    if not self.exportFrame then
        self:CreateExportFrame()
    end

    self.exportFrame.editBox:SetText(export)
    self.exportFrame:Show()
    C_Timer.After(0.05, function()
        if self.exportFrame:IsShown() then
            self.exportFrame.editBox:HighlightText(0)
            self.exportFrame.editBox:SetFocus()
        end
    end)
end
