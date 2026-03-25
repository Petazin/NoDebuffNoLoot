local addonName, ns = ...
ns.Data = {}

-- Debuffs críticos de TBC por clase y especialización (Talentos)
-- talentId: { tabIndex, talentIndex } conforme a GetTalentInfo()
ns.Data.Debuffs = {
    -- GUERRERO
    ["Sunder Armor"] = { id = 25225, class = "WARRIOR", priority = "S", icon = "Interface\\Icons\\Ability_Warrior_Sunder" },
    ["Thunder Clap"] = { id = 25264, class = "WARRIOR", priority = "A", icon = "Interface\\Icons\\Spell_Nature_ThunderClap" },
    ["Demoralizing Shout"] = { id = 25203, class = "WARRIOR", priority = "A", icon = "Interface\\Icons\\Ability_Warrior_WarCry" },
    ["Blood Frenzy"] = { id = 29859, class = "WARRIOR", priority = "S", talentId = {1, 15}, icon = "Interface\\Icons\\Ability_Warrior_BloodFrenzy" },
    
    -- DRUIDA
    ["Faerie Fire"] = { id = 26994, class = "DRUID", priority = "S", icon = "Interface\\Icons\\Spell_Nature_FaerieFire" },
    ["Improved Faerie Fire"] = { id = 26994, class = "DRUID", priority = "S", talentId = {1, 16}, icon = "Interface\\Icons\\Spell_Nature_FaerieFire" },
    ["Demoralizing Roar"] = { id = 26998, class = "DRUID", priority = "B", icon = "Interface\\Icons\\Ability_Druid_DemoralizingRoar" },
    ["Mangle"] = { id = 33876, class = "DRUID", priority = "S", talentId = {2, 18}, icon = "Interface\\Icons\\Ability_Druid_Mangle" },
    ["Insect Swarm"] = { id = 27013, class = "DRUID", priority = "B", talentId = {1, 10}, icon = "Interface\\Icons\\Spell_Nature_InsectSwarm" },

    -- CAZADOR
    ["Hunter's Mark"] = { id = 14325, class = "HUNTER", priority = "A", talentId = {2, 3}, icon = "Interface\\Icons\\Ability_Hunter_Snares" },
    ["Expose Weakness"] = { id = 34503, class = "HUNTER", priority = "S", talentId = {3, 18}, icon = "Interface\\Icons\\Ability_Hunter_ExposeWeakness" },
    ["Scorpid Sting"] = { id = 3043, class = "HUNTER", priority = "B", icon = "Interface\\Icons\\Ability_Hunter_CriticalShot" },
    ["Screech"] = { id = 27050, class = "HUNTER", priority = "B", icon = "Interface\\Icons\\Ability_Hunter_Screech" },

    -- PÍCARO
    ["Expose Armor"] = { id = 26866, class = "ROGUE", priority = "A", icon = "Interface\\Icons\\Ability_Rogue_ExposeArmor" },
    ["Improved Expose Armor"] = { id = 26866, class = "ROGUE", priority = "S", talentId = {1, 5}, icon = "Interface\\Icons\\Ability_Rogue_ExposeArmor" },

    -- MAGO
    ["Improved Scorch"] = { id = 22959, class = "MAGE", priority = "S", talentId = {2, 9}, icon = "Interface\\Icons\\Spell_Fire_SoulBurn" },
    ["Winters Chill"] = { id = 28593, class = "MAGE", priority = "S", talentId = {3, 10}, icon = "Interface\\Icons\\Spell_Frost_IceFloes" },

    -- BRUJO
    ["Curse of Elements"] = { id = 27228, class = "WARLOCK", priority = "S", icon = "Interface\\Icons\\Spell_Shadow_ChillTouch" },
    ["Malediction"] = { id = 27228, class = "WARLOCK", priority = "S", talentId = {1, 12}, icon = "Interface\\Icons\\Spell_Shadow_ChillTouch" },
    ["Curse of Recklessness"] = { id = 27226, class = "WARLOCK", priority = "S", icon = "Interface\\Icons\\Spell_Shadow_UnholyStrength" },
    ["Curse of Weakness"] = { id = 27224, class = "WARLOCK", priority = "B", icon = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth" },

    -- SACERDOTE
    ["Shadow Weaving"] = { id = 15258, class = "PRIEST", priority = "S", talentId = {3, 11}, icon = "Interface\\Icons\\Spell_Shadow_BlackPlague" },
    ["Misery"] = { id = 33191, class = "PRIEST", priority = "S", talentId = {3, 18}, icon = "Interface\\Icons\\Spell_Shadow_Misery" },

    -- CHAMÁN
    ["Stormstrike"] = { id = 17364, class = "SHAMAN", priority = "A", icon = "Interface\\Icons\\Spell_Holy_SealOfMight" },

    -- PALADÍN
    ["Judgement of Light"] = { id = 27163, class = "PALADIN", priority = "A", icon = "Interface\\Icons\\Spell_Holy_DivineIntervention" },
    ["Judgement of Wisdom"] = { id = 27164, class = "PALADIN", priority = "A", icon = "Interface\\Icons\\Spell_Holy_RighteousnessAura" },
    ["Judgement of the Crusader"] = { id = 27159, class = "PALADIN", priority = "B", icon = "Interface\\Icons\\Spell_Holy_HolySmite" },
    ["Heart of the Crusader"] = { id = 27159, class = "PALADIN", priority = "A", talentId = {3, 4}, icon = "Interface\\Icons\\Spell_Holy_HolySmite" },
}

-- Función auxiliar para obtener el ID de un hechizo por nombre (soporta localizado)
function ns.Data.GetSpellID(name)
    if not name or name == "" then return nil end
    
    -- 1. Intentar búsqueda por clave directa (Inglés)
    local data = ns.Data.Debuffs[name]
    if data then return data.id end
    
    -- 2. Intentar búsqueda por nombre localizado
    for _, info in pairs(ns.Data.Debuffs) do
        local locName = GetSpellInfo(info.id)
        if locName and string.lower(locName) == string.lower(name) then
            return info.id
        end
    end
    
    return nil
end
