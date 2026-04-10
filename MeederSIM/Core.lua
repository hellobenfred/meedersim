----------------------------------------------------------------------
-- MeederSIM by IT-Meeder.de
-- Sofortiger Item-Vergleich für Raid & M+
----------------------------------------------------------------------

MeederSIM = MeederSIM or {}
MeederSIM.version = "1.1.1"
MeederSIM.initialized = false

-- Spec ID → English name (locale-independent)
local SPEC_ID_TO_NAME = {
    [71]="Arms",[72]="Fury",[73]="Protection",
    [65]="Holy",[66]="Protection",[70]="Retribution",
    [253]="Beast Mastery",[254]="Marksmanship",[255]="Survival",
    [259]="Assassination",[260]="Outlaw",[261]="Subtlety",
    [256]="Discipline",[257]="Holy",[258]="Shadow",
    [262]="Elemental",[263]="Enhancement",[264]="Restoration",
    [62]="Arcane",[63]="Fire",[64]="Frost",
    [265]="Affliction",[266]="Demonology",[267]="Destruction",
    [268]="Brewmaster",[270]="Mistweaver",[269]="Windwalker",
    [102]="Balance",[103]="Feral",[104]="Guardian",[105]="Restoration",
    [577]="Havoc",[581]="Vengeance",[1502]="Devourer",
    [250]="Blood",[251]="Frost",[252]="Unholy",
    [1467]="Devastation",[1468]="Preservation",[1473]="Augmentation",
}

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MeederSIM" then
        MeederSIM:Init()
    elseif event == "PLAYER_LOGIN" then
        MeederSIM:OnLogin()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        MeederSIM:UpdatePlayerInfo()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        MeederSIM:DebouncedGearCollect()
    end
end)

----------------------------------------------------------------------
-- Init
----------------------------------------------------------------------
function MeederSIM:Init()
    if not MeederSIMDB then
        MeederSIMDB = { settings = {} }
    end
    -- Defaults
    local defaults = {
        showTooltip=true, showRaid=true, showMPlus=true,
        showStatChanges=true, showStatPriority=true, showIlvlDiff=true,
        showLootPopup=true, onlyUpgrades=false,
        showBisOnEquipped=true, showEnchantWarning=true, showDropSource=true,
        debug=false,
    }
    for k, v in pairs(defaults) do
        if MeederSIMDB.settings[k] == nil then MeederSIMDB.settings[k] = v end
    end
    if not MeederSIMCharDB then
        MeederSIMCharDB = { gear = {}, charInfo = {} }
    end
    -- Settings panel
    self:CreateSettingsPanel()
    self.initialized = true
end

function MeederSIM:OnLogin()
    self:UpdatePlayerInfo()
    C_Timer.After(1, function()
        self:CollectGear()
        self:InitBiS()
        self:CreateMinimapButton()

        -- Willkommen beim ersten Start
        if not MeederSIMDB.welcomed then
            self:Print("|cff00ccff=== Willkommen bei MeederSIM! ===|r")
            self:Print("Klicke auf den |cffffff00Minimap-Button|r für alle Funktionen:")
            self:Print("  - |cff00ff00Best in Slot|r Übersicht (4 Profile)")
            self:Print("  - |cffffff00Ausrüstung|r visuell anzeigen")
            self:Print("  - |cff00ccffStat-Gewichtungen|r für deinen Spec")
            self:Print("  - |cffff8800SimC Export|r für Raidbots")
            self:Print("Hover über Items für sofortigen Vergleich!")
            MeederSIMDB.welcomed = true
        else
            self:Print(self.version .. " " .. self.L.ADDON_LOADED ..
                " | " .. (self.spec or "?") .. " " .. (self.class or "?"))
        end
    end)
    C_Timer.After(2, function()
        self:InitTooltips()
    end)
end

----------------------------------------------------------------------
-- Player Info
----------------------------------------------------------------------
function MeederSIM:UpdatePlayerInfo()
    local _, cls = UnitClass("player")
    self.class = cls

    local idx = GetSpecialization()
    if idx then
        local specID, localName = GetSpecializationInfo(idx)
        -- Try ID mapping first (locale-safe)
        self.spec = SPEC_ID_TO_NAME[specID]
        -- Fallback: check if localized name matches any known spec in our weights
        if not self.spec and self.class and self.Weights and self.Weights[self.class] then
            -- Try direct match (works on enUS clients)
            if self.Weights[self.class][localName] then
                self.spec = localName
            else
                -- Unknown spec ID - use localized name and log it
                self.spec = localName
                self:Debug("Unbekannte SpecID " .. tostring(specID) .. " (" .. tostring(localName) ..
                    ") - bitte an IT-Meeder.de melden!")
            end
        end
        if not self.spec then self.spec = localName end
        self.specID = specID
    end

    self.name = UnitName("player")
    self.level = UnitLevel("player")

    local _, race = UnitRace("player")
    self.race = race

    MeederSIMCharDB.charInfo = {
        class = self.class, spec = self.spec, specID = self.specID,
        name = self.name, level = self.level, race = self.race,
    }
end

----------------------------------------------------------------------
-- Debounced gear collection
----------------------------------------------------------------------
function MeederSIM:DebouncedGearCollect()
    if self._gearTimer then self._gearTimer:Cancel() end
    self._gearTimer = C_Timer.NewTimer(0.5, function()
        self:CollectGear()
        self._gearTimer = nil
    end)
end

----------------------------------------------------------------------
-- Slash Commands
----------------------------------------------------------------------
SLASH_MEEDERSIM1 = "/msim"
SLASH_MEEDERSIM2 = "/meedersim"

SlashCmdList["MEEDERSIM"] = function(msg)
    local cmd, args = (msg or ""):match("^(%S+)%s*(.*)")
    cmd = cmd or (msg or ""):trim()
    args = args or ""

    if cmd == "" or cmd == "export" then
        MeederSIM:ShowExport()
    elseif cmd == "help" then
        MeederSIM:ShowHelp()
    elseif cmd == "gear" then
        MeederSIM:PrintGear()
    elseif cmd == "weights" then
        MeederSIM:PrintWeights()
    elseif cmd == "testgear" then
        MeederSIM:TestGear()
    elseif cmd == "config" or cmd == "settings" then
        MeederSIM:OpenSettings()
    elseif cmd == "bis" then
        MeederSIM:ShowBiSWindow()
    elseif cmd == "setbis" then
        MeederSIM:SetBiSCmd(args)
    elseif cmd == "clearbis" then
        MeederSIM:ClearBiS()
    elseif cmd == "exportbis" then
        MeederSIM:ExportBiS()
    elseif cmd == "importbis" then
        MeederSIM:ImportBiS(args)
    elseif cmd == "dumplinks" then
        MeederSIM:DumpItemLinks()
    elseif cmd == "debug" then
        MeederSIMDB.settings.debug = not MeederSIMDB.settings.debug
        MeederSIM:Print("Debug: " .. (MeederSIMDB.settings.debug and "ON" or "OFF"))
    else
        MeederSIM:Print("Unbekannt: " .. cmd .. " | /msim help")
    end
end

function MeederSIM:ShowHelp()
    self:Print("|cff00ccffMeederSIM|r by IT-Meeder.de v" .. self.version)
    self:Print("|cffffff00/msim|r - SimC Export")
    self:Print("|cffffff00/msim gear|r - Ausrüstung anzeigen")
    self:Print("|cffffff00/msim weights|r - Stat-Gewichtungen")
    self:Print("|cffffff00/msim bis|r - BiS Übersicht (fehlende Teile)")
    self:Print("|cffffff00/msim setbis|r - Hover über Item + tippen = BiS setzen")
    self:Print("|cffffff00/msim clearbis|r - Alle BiS-Einträge löschen")
    self:Print("|cffffff00/msim exportbis|r - BiS-Liste als String exportieren")
    self:Print("|cffffff00/msim importbis <string>|r - BiS-Liste importieren")
    self:Print("|cffffff00/msim config|r - Einstellungen")
end

----------------------------------------------------------------------
-- Print gear summary
----------------------------------------------------------------------
function MeederSIM:PrintGear()
    local gear = MeederSIMCharDB.gear
    if not gear or not next(gear) then
        self:Print(self.L.GEAR_EMPTY)
        return
    end
    local names = {
        [1]="Head",[2]="Neck",[3]="Shoulder",[15]="Back",[5]="Chest",
        [9]="Wrist",[10]="Hands",[6]="Waist",[7]="Legs",[8]="Feet",
        [11]="Ring 1",[12]="Ring 2",[13]="Trinket 1",[14]="Trinket 2",
        [16]="Main Hand",[17]="Off Hand",
    }
    for _, slotId in ipairs({1,2,3,15,5,9,10,6,7,8,11,12,13,14,16,17}) do
        local g = gear[slotId]
        if g then
            self:Print("  " .. (names[slotId] or slotId) .. ": " .. g.name .. " (iLvl " .. g.ilvl .. ")")
        end
    end
end

----------------------------------------------------------------------
-- Print weights
----------------------------------------------------------------------
function MeederSIM:PrintWeights()
    local w = self:GetWeights()
    if not w then
        self:Print(self.L.NO_WEIGHTS .. " (" .. tostring(self.class) .. "/" .. tostring(self.spec) .. ")")
        return
    end
    self:Print("Raid weights for " .. self.spec .. " " .. self.class .. ":")
    if w.raid then
        for stat, val in pairs(w.raid) do
            self:Print("  " .. stat .. ": " .. string.format("%.2f", val))
        end
    end
end

----------------------------------------------------------------------
-- Get weights for current spec
----------------------------------------------------------------------
function MeederSIM:GetWeights()
    if not self.Weights then return nil end
    local cw = self.Weights[self.class]
    if not cw then return nil end
    return cw[self.spec]
end

----------------------------------------------------------------------
-- Util
----------------------------------------------------------------------
function MeederSIM:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[MeederSIM]|r " .. tostring(msg))
end

function MeederSIM:Debug(msg)
    if MeederSIMDB and MeederSIMDB.settings and MeederSIMDB.settings.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cff888888[MeederSIM]|r " .. tostring(msg))
    end
end
