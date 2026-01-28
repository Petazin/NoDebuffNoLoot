local addonName, ns = ...

local options = {
    name = "NoDebuffNoLoot",
    handler = NoDebuffNoLoot,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = "Configuración General",
            order = 1,
            args = {
                desc = {
                    type = "description",
                    name = "Asigna jugadores a cada debuff crítico para rastrear su presencia en el boss.",
                    order = 1,
                },
                showHud = {
                    type = "toggle",
                    name = "Mostrar HUD",
                    desc = "Muestra u oculta el panel de debuffs.",
                    get = function() return NoDebuffNoLoot.db.profile.hud.shown end,
                    set = function(_, val) 
                        NoDebuffNoLoot.db.profile.hud.shown = val 
                        if val then NoDebuffNoLoot:UpdateTracker() else ns.UI:Clear() end
                    end,
                    order = 2,
                },
            },
        },
        assignments = {
            type = 'group',
            name = "Asignaciones",
            order = 2,
            args = {
                -- Se llenará dinámicamente o por clase
            },
        },
    },
}

-- Función para generar los controles de asignación dinámicamente
function NoDebuffNoLoot:SetupOptions()
    for name, info in pairs(ns.Data.Debuffs) do
        options.args.assignments.args[name:gsub("%s+", "")] = {
            type = 'input',
            name = name,
            desc = "Nombre del jugador responsable de este debuff.",
            get = function() return self.db.profile.assignments[name] or "" end,
            set = function(_, val) 
                if val == "" then val = nil end
                self.db.profile.assignments[name] = val
                self:UpdateTracker()
            end,
            order = 10,
        }
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable("NoDebuffNoLoot", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("NoDebuffNoLoot", "NoDebuffNoLoot")
end
