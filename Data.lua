local addonName, ns = ...
ns.Data = {}

-- Debuffs críticos de TBC por clase
ns.Data.Debuffs = {
    -- Guerrero
    ["Sunder Armor"] = { id = 25225, class = "WARRIOR", icon = "Interface\\Icons\\Ability_Warrior_Sunder" },
    ["Thunder Clap"] = { id = 25264, class = "WARRIOR", icon = "Interface\\Icons\\Spell_Nature_ThunderClap" },
    ["Demoralizing Shout"] = { id = 25203, class = "WARRIOR", icon = "Interface\\Icons\\Ability_Warrior_WarCry" },
    
    -- Druida
    ["Faerie Fire"] = { id = 26994, class = "DRUID", icon = "Interface\\Icons\\Spell_Nature_FaerieFire" },
    ["Demoralizing Roar"] = { id = 26998, class = "DRUID", icon = "Interface\\Icons\\Ability_Druid_DemoralizingRoar" },

    -- Hunter
    ["Hunter's Mark"] = { id = 14325, class = "HUNTER", icon = "Interface\\Icons\\Ability_Hunter_Snares" },
    ["Scorpid Sting"] = { id = 3043, class = "HUNTER", icon = "Interface\\Icons\\Ability_Hunter_CriticalShot" },
    ["Viper Sting"] = { id = 3034, class = "HUNTER", icon = "Interface\\Icons\\Ability_Hunter_AimedShot" },
    ["Serpent Sting"] = { id = 27019, class = "HUNTER", icon = "Interface\\Icons\\Ability_Hunter_Quickshot" },

    -- Chamán
    ["Stormstrike"] = { id = 17364, class = "SHAMAN", icon = "Interface\\Icons\\Spell_Holy_SealOfMight" },
    ["Flame Shock"] = { id = 25457, class = "SHAMAN", icon = "Interface\\Icons\\Spell_Fire_FlameShock" },
    ["Earth Shock"] = { id = 25454, class = "SHAMAN", icon = "Interface\\Icons\\Spell_Nature_EarthShock" },

    -- Paladín
    ["Judgement of Light"] = { id = 27163, class = "PALADIN", icon = "Interface\\Icons\\Spell_Holy_DivineIntervention" },
    ["Judgement of Wisdom"] = { id = 27164, class = "PALADIN", icon = "Interface\\Icons\\Spell_Holy_RighteousnessAura" },
    ["Judgement of the Crusader"] = { id = 27159, class = "PALADIN", icon = "Interface\\Icons\\Spell_Holy_HolySmite" },

    -- Warlock
    ["Curse of Elements"] = { id = 27228, class = "WARLOCK", icon = "Interface\\Icons\\Spell_Shadow_ChillTouch" },
    ["Curse of Recklessness"] = { id = 27226, class = "WARLOCK", icon = "Interface\\Icons\\Spell_Shadow_UnholyStrength" },
    ["Curse of Weakness"] = { id = 27224, class = "WARLOCK", icon = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth" },
}

-- Función auxiliar para obtener el ID de un hechizo por nombre (soporte multilenguaje futuro)
function ns.Data.GetSpellID(name)
    local data = ns.Data.Debuffs[name]
    return data and data.id
end
