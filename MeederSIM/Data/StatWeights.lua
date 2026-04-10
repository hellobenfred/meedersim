----------------------------------------------------------------------
-- MeederSIM - Stat Weights (Midnight Season 1)
-- All 13 classes, 39 specs. Raid + M+ weights.
----------------------------------------------------------------------
MeederSIM.Weights = {
    WARRIOR = {
        Arms       = { raid={strength=1,crit=.82,haste=.78,mastery=.85,versatility=.70}, mythicplus={strength=1,crit=.75,haste=.88,mastery=.72,versatility=.82} },
        Fury       = { raid={strength=1,crit=.80,haste=.90,mastery=.75,versatility=.68}, mythicplus={strength=1,crit=.78,haste=.92,mastery=.65,versatility=.80} },
        Protection = { raid={strength=.60,crit=.50,haste=.85,mastery=.70,versatility=1}, mythicplus={strength=.55,crit=.55,haste=.90,mastery=.65,versatility=1} },
    },
    PALADIN = {
        Holy        = { raid={intellect=1,crit=.85,haste=.80,mastery=.90,versatility=.75}, mythicplus={intellect=1,crit=.82,haste=.90,mastery=.70,versatility=.85} },
        Protection  = { raid={strength=.55,crit=.50,haste=1,mastery=.80,versatility=.85}, mythicplus={strength=.50,crit=.55,haste=1,mastery=.75,versatility=.90} },
        Retribution = { raid={strength=1,crit=.78,haste=.90,mastery=.82,versatility=.72}, mythicplus={strength=1,crit=.75,haste=.92,mastery=.70,versatility=.82} },
    },
    HUNTER = {
        ["Beast Mastery"] = { raid={agility=1,crit=.72,haste=.90,mastery=.80,versatility=.68}, mythicplus={agility=1,crit=.70,haste=.88,mastery=.75,versatility=.78} },
        Marksmanship      = { raid={agility=1,crit=.85,haste=.78,mastery=.82,versatility=.70}, mythicplus={agility=1,crit=.80,haste=.85,mastery=.72,versatility=.78} },
        Survival          = { raid={agility=1,crit=.80,haste=.85,mastery=.75,versatility=.72}, mythicplus={agility=1,crit=.78,haste=.88,mastery=.68,versatility=.82} },
    },
    ROGUE = {
        Assassination = { raid={agility=1,crit=.82,haste=.78,mastery=.88,versatility=.70}, mythicplus={agility=1,crit=.78,haste=.82,mastery=.75,versatility=.80} },
        Outlaw        = { raid={agility=1,crit=.75,haste=.85,mastery=.70,versatility=.90}, mythicplus={agility=1,crit=.72,haste=.88,mastery=.65,versatility=.90} },
        Subtlety      = { raid={agility=1,crit=.85,haste=.78,mastery=.82,versatility=.72}, mythicplus={agility=1,crit=.80,haste=.85,mastery=.72,versatility=.82} },
    },
    PRIEST = {
        Discipline = { raid={intellect=1,crit=.80,haste=.90,mastery=.75,versatility=.82}, mythicplus={intellect=1,crit=.78,haste=.92,mastery=.68,versatility=.88} },
        Holy       = { raid={intellect=1,crit=.78,haste=.85,mastery=.88,versatility=.72}, mythicplus={intellect=1,crit=.75,haste=.90,mastery=.72,versatility=.82} },
        Shadow     = { raid={intellect=1,crit=.78,haste=.90,mastery=.82,versatility=.70}, mythicplus={intellect=1,crit=.75,haste=.92,mastery=.72,versatility=.80} },
    },
    SHAMAN = {
        Elemental   = { raid={intellect=1,crit=.82,haste=.88,mastery=.85,versatility=.72}, mythicplus={intellect=1,crit=.78,haste=.90,mastery=.80,versatility=.80} },
        Enhancement = { raid={agility=1,crit=.78,haste=.90,mastery=.82,versatility=.70}, mythicplus={agility=1,crit=.75,haste=.92,mastery=.72,versatility=.82} },
        Restoration = { raid={intellect=1,crit=.90,haste=.78,mastery=.85,versatility=.80}, mythicplus={intellect=1,crit=.85,haste=.85,mastery=.72,versatility=.88} },
    },
    MAGE = {
        Arcane = { raid={intellect=1,crit=.78,haste=.85,mastery=.90,versatility=.72}, mythicplus={intellect=1,crit=.75,haste=.88,mastery=.82,versatility=.80} },
        Fire   = { raid={intellect=1,crit=.90,haste=.85,mastery=.80,versatility=.72}, mythicplus={intellect=1,crit=.88,haste=.88,mastery=.72,versatility=.80} },
        Frost  = { raid={intellect=1,crit=.82,haste=.78,mastery=.88,versatility=.70}, mythicplus={intellect=1,crit=.80,haste=.82,mastery=.82,versatility=.78} },
    },
    WARLOCK = {
        Affliction  = { raid={intellect=1,crit=.72,haste=.90,mastery=.88,versatility=.70}, mythicplus={intellect=1,crit=.70,haste=.92,mastery=.78,versatility=.80} },
        Demonology  = { raid={intellect=1,crit=.78,haste=.92,mastery=.82,versatility=.70}, mythicplus={intellect=1,crit=.75,haste=.90,mastery=.75,versatility=.80} },
        Destruction = { raid={intellect=1,crit=.85,haste=.88,mastery=.78,versatility=.72}, mythicplus={intellect=1,crit=.82,haste=.90,mastery=.70,versatility=.80} },
    },
    MONK = {
        Brewmaster  = { raid={agility=.60,crit=.55,haste=.70,mastery=.65,versatility=1}, mythicplus={agility=.55,crit=.60,haste=.75,mastery=.60,versatility=1} },
        Mistweaver  = { raid={intellect=1,crit=.82,haste=.88,mastery=.75,versatility=.80}, mythicplus={intellect=1,crit=.78,haste=.90,mastery=.68,versatility=.88} },
        Windwalker  = { raid={agility=1,crit=.80,haste=.78,mastery=.88,versatility=.72}, mythicplus={agility=1,crit=.78,haste=.82,mastery=.78,versatility=.82} },
    },
    DRUID = {
        Balance     = { raid={intellect=1,crit=.78,haste=.90,mastery=.85,versatility=.72}, mythicplus={intellect=1,crit=.75,haste=.92,mastery=.78,versatility=.82} },
        Feral       = { raid={agility=1,crit=.90,haste=.72,mastery=.82,versatility=.70}, mythicplus={agility=1,crit=.85,haste=.78,mastery=.72,versatility=.80} },
        Guardian    = { raid={agility=.55,crit=.50,haste=.60,mastery=.70,versatility=1}, mythicplus={agility=.50,crit=.55,haste=.65,mastery=.65,versatility=1} },
        Restoration = { raid={intellect=1,crit=.78,haste=.90,mastery=.88,versatility=.75}, mythicplus={intellect=1,crit=.75,haste=.92,mastery=.78,versatility=.85} },
    },
    DEMONHUNTER = {
        Havoc     = { raid={agility=1,crit=.88,haste=.78,mastery=.75,versatility=.82}, mythicplus={agility=1,crit=.85,haste=.82,mastery=.68,versatility=.88} },
        Vengeance = { raid={agility=.60,crit=.55,haste=.90,mastery=.65,versatility=1}, mythicplus={agility=.55,crit=.60,haste=.92,mastery=.60,versatility=1} },
        Devourer  = { raid={agility=1,crit=.80,haste=.85,mastery=.90,versatility=.75}, mythicplus={agility=1,crit=.78,haste=.88,mastery=.82,versatility=.82} },
    },
    DEATHKNIGHT = {
        Blood  = { raid={strength=.55,crit=.55,haste=.90,mastery=.72,versatility=1}, mythicplus={strength=.50,crit=.60,haste=.92,mastery=.68,versatility=1} },
        Frost  = { raid={strength=1,crit=.78,haste=.82,mastery=.90,versatility=.72}, mythicplus={strength=1,crit=.75,haste=.85,mastery=.82,versatility=.80} },
        Unholy = { raid={strength=1,crit=.78,haste=.82,mastery=.90,versatility=.72}, mythicplus={strength=1,crit=.75,haste=.85,mastery=.80,versatility=.82} },
    },
    EVOKER = {
        Devastation  = { raid={intellect=1,crit=.82,haste=.88,mastery=.85,versatility=.72}, mythicplus={intellect=1,crit=.80,haste=.90,mastery=.78,versatility=.82} },
        Preservation = { raid={intellect=1,crit=.85,haste=.82,mastery=.88,versatility=.78}, mythicplus={intellect=1,crit=.82,haste=.88,mastery=.75,versatility=.85} },
        Augmentation = { raid={intellect=1,crit=.78,haste=.90,mastery=.82,versatility=.85}, mythicplus={intellect=1,crit=.75,haste=.92,mastery=.78,versatility=.88} },
    },
}
