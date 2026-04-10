if GetLocale() == "deDE" then
    MeederSIM = MeederSIM or {}
    local L = MeederSIM.L
    if not L then return end

    -- General
    L.ADDON_LOADED = "geladen"
    L.BY = "by IT-Meeder.de"
    L.SUPPORT = "Support: Littlepink-Arthas"
    L.BIS_SOURCE = "BiS-Daten: Icy Veins (10.04.2026, Patch 12.0.4)"

    -- Verdicts
    L.UPGRADE = "[+] UPGRADE für"
    L.DOWNGRADE = "[-] DOWNGRADE für"
    L.MIXED = "[~] Gemischt für"
    L.NO_CHANGE = "[=] Kein Unterschied für"
    L.TEMPORARY = "Temporäres Upgrade (nicht BiS)"

    -- Tooltip
    L.BEST_STAT = "(Dein bester Stat!)"
    L.PRIO = "Prio"
    L.LOSS = "Verlust"
    L.LOW_PRIO = "(niedriger Prio)"
    L.STAT_CHANGES = "Stat-Änderungen:"
    L.BASED_ON_ILVL = "Basiert auf iLvl. /msim für genaue Sim."
    L.TIER_INCLUDED = "(Bereits in Raid/M+ Wertung eingerechnet)"

    -- BiS
    L.BIS_TITLE = "Best in Slot"
    L.BIS_PERSONAL = "Persönlich"
    L.BIS_EQUIPPED = "Ausgerüstet"
    L.BIS_ITEM = "BiS Item"
    L.BIS_FOR = "Best in Slot für:"
    L.NOT_BIS = "Nicht Best in Slot"
    L.BIS_SET = "BiS gesetzt:"
    L.BIS_DELETED = "BiS gelöscht."
    L.BIS_CLEARED = "BiS gelöscht. /reload für neue Defaults."
    L.BIS_TARGET = "MeederSIM BiS (Myth 6/6 = iLvl 289)"
    L.MYTH_REACHED = "Myth 6/6 erreicht!"
    L.OWNS_AT_ILVL = "Besitzt auf iLvl"
    L.CRESTS_REMAINING = "bis 289"
    L.RANK = "Stufe"
    L.YOU_HAVE = "Du hast"
    L.CRESTS = "Crests"
    L.IN_BAG = "In deiner Tasche!"
    L.ILVL_IMPROVEMENT = "iLvl Verbesserung"

    -- Sources
    L.SOURCE = "Quelle:"
    L.MYTHIC_RAID_VAULT = "Mythic Raid / Great Vault"
    L.MPLUS_DUNGEON_VAULT = "M+ Dungeon / Great Vault"
    L.CRAFTED = "Crafting-Auftrag"
    L.SOURCE_UNKNOWN = "Quelle: Nicht in Datenbank"

    -- Enchant
    L.ENCHANT_MISSING = "Verzauberung fehlt!"
    L.HEAD_ENCHANT = "Kopf-Enchant"
    L.SHOULDER_ENCHANT = "Schulter-Enchant"
    L.CHEST_ENCHANT = "Brust-Enchant"
    L.LEG_ENCHANT = "Beinverstärkung"
    L.FEET_ENCHANT = "Füße-Enchant"
    L.RING_ENCHANT = "Ring-Enchant"
    L.WEAPON_ENCHANT = "Waffen-Enchant"

    -- Crest
    L.UPGRADEABLE = "Aufwertbar mit"
    L.ALREADY_MAX = "Bereits auf Maximum"

    -- Hub
    L.HUB_BIS = "Best in Slot Übersicht"
    L.HUB_BIS_DESC = "BiS-Items für Overall, Raid, M+, Persönlich"
    L.HUB_GEAR = "Ausrüstung"
    L.HUB_GEAR_DESC = "Alle angezogenen Items mit iLvl anzeigen"
    L.HUB_WEIGHTS = "Stat-Gewichtungen"
    L.HUB_WEIGHTS_DESC = "Stat-Prioritäten für deinen Spec (Raid & M+)"
    L.HUB_EXPORT = "SimC Export"
    L.HUB_EXPORT_DESC = "Gear als SimC-String für Raidbots kopieren"
    L.HUB_QUICKSIM = "Quick Sim"
    L.HUB_QUICKSIM_DESC = "Raidbots öffnen mit deinem Gear zum Einfügen"
    L.HUB_SETTINGS = "Einstellungen"
    L.HUB_SETTINGS_DESC = "Tooltip, Benachrichtigungen, BiS konfigurieren"
    L.ITEMS_EQUIPPED = "Items ausgerüstet"
    L.ENCHANTED = "Slots verzaubert"
    L.BIS_ITEMS = "BiS-Items ausgerüstet"

    -- Settings
    L.SETTINGS_DISPLAY = "Anzeige"
    L.SETTINGS_SHOW_TOOLTIP = "Tooltip-Vergleich anzeigen"
    L.SETTINGS_SHOW_RAID = "Raid-Bewertung anzeigen"
    L.SETTINGS_SHOW_MPLUS = "M+-Bewertung anzeigen"
    L.SETTINGS_SHOW_STATS = "Stat-Änderungen anzeigen"
    L.SETTINGS_SHOW_PRIO = "Stat-Priorität anzeigen"
    L.SETTINGS_SHOW_ILVL = "Item-Level Differenz anzeigen"
    L.SETTINGS_NOTIFICATIONS = "Benachrichtigungen"
    L.SETTINGS_LOOT_POPUP = "Loot-Benachrichtigung im Chat"
    L.SETTINGS_ONLY_UPGRADES = "Nur Upgrades melden"
    L.SETTINGS_BIS_GEAR = "BiS & Gear"
    L.SETTINGS_BIS_EQUIPPED = "BiS-Status auf ausgerüsteten Items"
    L.SETTINGS_ENCHANT_WARN = "Enchant-Warnung auf ausgerüsteten Items"
    L.SETTINGS_DROP_SOURCE = "Drop-Quelle im Tooltip anzeigen"

    -- Quick Sim
    L.QUICKSIM_COPIED = "SimC-String in Zwischenablage kopiert!"
    L.QUICKSIM_OPEN = "Öffne Raidbots..."
    L.QUICKSIM_HINT = "Auf Raidbots mit Strg+V einfügen und Sim klicken!"

    -- Slots
    L.SLOT_HEAD = "Kopf"
    L.SLOT_NECK = "Hals"
    L.SLOT_SHOULDER = "Schulter"
    L.SLOT_BACK = "Rücken"
    L.SLOT_CHEST = "Brust"
    L.SLOT_WRIST = "Handgelenke"
    L.SLOT_HANDS = "Hände"
    L.SLOT_WAIST = "Taille"
    L.SLOT_LEGS = "Beine"
    L.SLOT_FEET = "Füße"
    L.SLOT_RING1 = "Ring 1"
    L.SLOT_RING2 = "Ring 2"
    L.SLOT_TRINKET1 = "Schmuck 1"
    L.SLOT_TRINKET2 = "Schmuck 2"
    L.SLOT_MAINHAND = "Haupthand"
    L.SLOT_OFFHAND = "Nebenhand"

    -- Commands
    L.CMD_HELP = "/msim help - Diese Hilfe anzeigen"
    L.CMD_EXPORT = "/msim - SimC Export"
    L.CMD_GEAR = "/msim gear - Ausrüstung anzeigen"
    L.CMD_WEIGHTS = "/msim weights - Stat-Gewichtungen"
    L.CMD_BIS = "/msim bis - BiS Übersicht"
    L.CMD_CONFIG = "/msim config - Einstellungen"
    L.CMD_QUICKSIM = "/msim quicksim - Quick Sim über Raidbots"
end
