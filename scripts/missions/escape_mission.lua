-- Additional escapeMission scripts
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")
local constants = include(SCRIPT_PATHS.qoala_commbugfix .. "/constants")

function initFoundPrisoner(sim)
    if sim:getParams().foundPrisoner == nil then
        local spawnAgentOption = cbf_util.simCheckFlag(sim, "cbf_detention_spawnagent")
        if spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT or spawnAgentOption ==
                constants.MISSIONDETCENTER_SPAWNAGENT.ALWAYS then
            -- First detention center should always have an agent.
            sim:getParams().foundPrisoner = true
        elseif spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.FIFTYFIFTY then
            sim:getParams().foundPrisoner = false
        end
    end
end

function init(scriptMgr, sim)
    initFoundPrisoner(sim)
end

return {init = init}
