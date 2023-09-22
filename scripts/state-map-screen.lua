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
        if not self._campaign.difficultyOptions.cbf_params then
          local p = {}

          -- cbf_ending_finaldoor requires a paired options-level flag.
          p.cbf_params.cbf_ending_incognitadrop = true
          p.cbf_params.cbf_ending_remotehacking = true
          p.cbf_params.cbf_missionvault_hackresponse = true

          p.cbf_params.cbf_nopatrol_fixfacing = true
          p.cbf_params.cbf_idle_fixfailedpatrolpath =
                  constants.IDLE_FIXFAILEDPATROLPATH.REGENERATE
          p.cbf_params.cbf_ignoresleepingtag = true
          p.cbf_params.cbf_fixmagicsight = true
          p.cbf_params.cbf_pulsereact = true
          p.cbf_params.cbf_disguisefix_pathing = true
          p.cbf_params.cbf_smoke_dynamicedges = true
          p.cbf_params.cbf_smoke_rememberedges = true
          p.cbf_params.cbf_fixsharedinterest = true

          p.cbf_params.cbf_pathing = {}
          p.cbf_params.cbf_pathing.reset_on_interest_moved = true
          p.cbf_params.cbf_pathing.use_pathing_queue = false

          p.cbf_params.cbf_agent_drillmodtrait = true
          -- cbf_agent_speed5 is an options-level flag.
          p.cbf_params.cbf_flurry_reset = true

          p.cbf_params.cbf_cycletiming = true

          p.cbf_params.cbf_laserdragsymmetry = true
          p.cbf_params.cbf_laserdaemons = true

          -- Escorts Fixed requires paired options-level flags, and also requires checking for
          -- the standalone Escorts Fixed mod.

          self._campaign.difficultyOptions.cbf_params = p
        end
        local p = self._campaign.difficultyOptions.cbf_params
        -- v1.11.0
        autoSet(p, "cbf_flurry_reset", true)
        autoSet(p, "cbf_smoke_dynamicedges", true)
        autoSet(p, "cbf_smoke_rememberedges", true)
    end

    return oldClosePreview(self, previewScreen, situation, goToThere, ...)
end