local util = include("modules/util")

local function createLateDefs()
    local prop_templates = include("sim/unitdefs/propdefs")
    return {
        cbf_smoke_edge = util.extend(prop_templates.smoke_edge) { --
            type = "cbf_smoke_edge",
        },
    }
end

return {createLateDefs = createLateDefs}
