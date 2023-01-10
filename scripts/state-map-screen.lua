-- patch to client/states/state-map-screen
local mapScreen = include("states/state-map-screen")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local function autoSet(p, flag, default)
    if p[flag] == nil then
        simlog("[CBF] Auto-enabling %s=%s between missions.", tostring(flag), tostring(default))
        p[flag] = default
    end
end

local oldClosePreview = mapScreen.closePreview
function mapScreen:closePreview(previewScreen, situation, goToThere, ...)
    if goToThere and cbf_util.optionsCheckFlag(self._campaign.difficultyOptions, "cbf_autoupdate", true) then
        -- Auto update newly-added fixes before the next mission.
        local p = self._campaign.difficultyOptions.cbf_params
        -- v1.11.0
        autoSet(p, "cbf_flurry_reset", true)
        autoSet(p, "cbf_smoke_dynamicedges", true)
        autoSet(p, "cbf_smoke_rememberedges", true)
    end

    return oldClosePreview(self, previewScreen, situation, goToThere, ...)
end
