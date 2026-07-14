local addonName, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale("NoDebuffNoLoot")

local options = {
    name = "NoDebuffNoLoot",
    handler = NoDebuffNoLoot,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L["SHOW_HUD"],
            order = 1,
            args = {
                desc = {
                    type = "description",
                    name = L["ASSIGNMENTS_DESC"],
                    order = 1,
                },
                showHud = {
                    type = "toggle",
                    name = L["SHOW_HUD"],
                    desc = L["SHOW_HUD_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.shown end,
                    set = function(_, val) 
                        NoDebuffNoLoot.db.profile.hud.shown = val 
                        if val then NoDebuffNoLoot:UpdateTracker() else ns.UI:Clear() end
                    end,
                    order = 2,
                },
                alwaysShow = {
                    type = "toggle",
                    name = L["OPT_ALWAYS_SHOW"],
                    desc = L["OPT_ALWAYS_SHOW_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.alwaysShow end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.alwaysShow = val
                        NoDebuffNoLoot:UpdateTracker()
                    end,
                    order = 2.5,
                },
                lockHud = {
                    type = "toggle",
                    name = L["OPT_LOCK"],
                    desc = L["OPT_LOCK_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.locked end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.locked = val
                        ns.UI:SetLocked(val)
                    end,
                    order = 3,
                },
                filterMine = {
                    type = "toggle",
                    name = L["OPT_FILTER_MINE"],
                    desc = L["OPT_FILTER_MINE_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.filterMine end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.filterMine = val
                        NoDebuffNoLoot:UpdateTracker()
                    end,
                    order = 4,
                    width = "full",
                },
                onlyMissing = {
                    type = "toggle",
                    name = L["OPT_ONLY_MISSING"],
                    desc = L["OPT_ONLY_MISSING_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.onlyMissing end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.onlyMissing = val
                        NoDebuffNoLoot:UpdateTracker()
                    end,
                    order = 4.5,
                    width = "full",
                },
                bossOnly = {
                    type = "toggle",
                    name = L["OPT_BOSS_ONLY"],
                    desc = L["OPT_BOSS_ONLY_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.hud.bossOnly end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.bossOnly = val
                        NoDebuffNoLoot:UpdateTracker()
                    end,
                    order = 5,
                    width = "full",
                },
                scale = {
                    type = "range",
                    name = L["OPT_HUD_SCALE"] or "Escala del HUD",
                    desc = L["OPT_HUD_SCALE_DESC"] or "Ajusta el tamaño general de la interfaz del HUD.",
                    min = 0.5,
                    max = 2.0,
                    step = 0.05,
                    get = function() return NoDebuffNoLoot.db.profile.hud.scale or 1.0 end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.scale = val
                        if ns.UI and ns.UI.UpdateLayout then ns.UI:UpdateLayout() end
                    end,
                    order = 6,
                },
                width = {
                    type = "range",
                    name = L["OPT_HUD_WIDTH"] or "Ancho del HUD",
                    desc = L["OPT_HUD_WIDTH_DESC"] or "Ajusta el ancho de las barras del HUD en píxeles.",
                    min = 120,
                    max = 400,
                    step = 5,
                    get = function() return NoDebuffNoLoot.db.profile.hud.width or 220 end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.width = val
                        if ns.UI and ns.UI.UpdateLayout then ns.UI:UpdateLayout() end
                    end,
                    order = 7,
                },
                showSpellName = {
                    type = "toggle",
                    name = L["OPT_SHOW_SPELL_NAME"] or "Mostrar nombre de hechizo",
                    desc = L["OPT_SHOW_SPELL_NAME_DESC"] or "Muestra u oculta el nombre del hechizo en el HUD para ahorrar espacio.",
                    get = function() return NoDebuffNoLoot.db.profile.hud.showSpellName ~= false end,
                    set = function(_, val)
                        NoDebuffNoLoot.db.profile.hud.showSpellName = val
                        NoDebuffNoLoot:UpdateTracker()
                    end,
                    order = 8,
                    width = "full",
                },
                alertsHeader = {
                    type = "header",
                    name = L["OPT_ALERTS_HEADER"],
                    order = 10,
                },
                alertChat = {
                    type = "toggle",
                    name = L["OPT_CHAT"],
                    desc = L["OPT_CHAT_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.alerts.chat end,
                    set = function(_, val) NoDebuffNoLoot.db.profile.alerts.chat = val end,
                    order = 11,
                },
                alertSound = {
                    type = "toggle",
                    name = L["OPT_SOUND"],
                    desc = L["OPT_SOUND_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.alerts.sound end,
                    set = function(_, val) NoDebuffNoLoot.db.profile.alerts.sound = val end,
                    order = 12,
                },
                alertFlash = {
                    type = "toggle",
                    name = L["OPT_FLASH"],
                    desc = L["OPT_FLASH_DESC"],
                    get = function() return NoDebuffNoLoot.db.profile.alerts.visual_flash end,
                    set = function(_, val) NoDebuffNoLoot.db.profile.alerts.visual_flash = val end,
                    order = 13,
                },
                minimapHeader = {
                    type = "header",
                    name = L["OPT_MINIMAP_HEADER"],
                    order = 20,
                },
                minimapIcon = {
                    type = "toggle",
                    name = L["OPT_MINIMAP"],
                    desc = L["OPT_MINIMAP_DESC"],
                    get = function() return not NoDebuffNoLoot.db.profile.minimap.hide end,
                    set = function(_, val) 
                        NoDebuffNoLoot.db.profile.minimap.hide = not val
                        if ns.LDBIcon then
                            if val then ns.LDBIcon:Show("NoDebuffNoLoot") else ns.LDBIcon:Hide("NoDebuffNoLoot") end
                        end
                    end,
                    order = 21,
                },
            },
        },
        assignments = {
            type = 'group',
            name = L["ASSIGNMENTS"],
            order = 2,
            args = {
                desc = {
                    type = "description",
                    name = L["ASSIGNMENTS_MOVED"],
                    order = 1,
                },
                openRealConfig = {
                    type = "execute",
                    name = L["OPT_OPEN_ASSIGNMENTS"],
                    desc = L["OPT_OPEN_ASSIGNMENTS_DESC"],
                    func = function()
                        -- Cierra la ventana actual de opciones de Blizzard
                        HideUIPanel(InterfaceOptionsFrame)
                        -- Abre la nueva interfaz custom
                        if ns.ConfigUI and ns.ConfigUI.Show then
                            ns.ConfigUI:Show()
                        end
                    end,
                    order = 2,
                    width = "full",
                }
            },
        },
    },
}

function NoDebuffNoLoot:SetupOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("NoDebuffNoLoot", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("NoDebuffNoLoot", "NoDebuffNoLoot")
end
