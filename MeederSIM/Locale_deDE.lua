if GetLocale() == "deDE" then
    MeederSIM = MeederSIM or {}
    MeederSIM.L = MeederSIM.L or {}
    local L = MeederSIM.L
    L.ADDON_LOADED = "geladen"
    L.HELP_CMD = "Befehle"
    L.RAID = "Raid"
    L.MPLUS = "M+"
    L.UPGRADE = "Verbesserung"
    L.DOWNGRADE = "Verschlechterung"
    L.SIDEGRADE = "Seitwärts"
    L.ILVL_DIFF = "iLvl"
    L.STATS = "Stats"
    L.GEAR_COLLECTED = "Gear gesammelt"
    L.GEAR_EMPTY = "Keine Gear-Daten. Versuche /reload."
    L.SLOT_NOT_FOUND = "Slot nicht erkannt"
    L.NO_WEIGHTS = "Keine Stat-Gewichtungen für deinen Spec"
    L.TOOLTIP_HEADER = "-- MeederSIM --"
    L.HELP_TITLE = "MeederSIM by IT-Meeder.de"
    L.CMD_HELP = "/msim help - Diese Hilfe anzeigen"
    L.CMD_EXPORT = "/msim - Gear als SimC-String exportieren"
    L.CMD_WEIGHTS = "/msim weights - Stat-Gewichtungen anzeigen"
    L.CMD_GEAR = "/msim gear - Ausrüstung anzeigen"
    L.CMD_CONFIG = "/msim config - Einstellungen öffnen"
    L.CMD_TESTGEAR = "/msim testgear - Gear-Erkennung testen"
end
