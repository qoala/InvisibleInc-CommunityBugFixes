-- Additional escapeMission scripts

local constants = include( SCRIPT_PATHS.qoala_commbugfix .. "/constants" )

function initFoundPrisoner( sim )
	if sim:getParams().foundPrisoner == nil then
		local spawnAgentOption = sim:getParams().difficultyOptions.cbf_detention_spawnagent
		if spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT then
			-- First detention center should always have an agent.
			sim:getParams().foundPrisoner = true
		elseif spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.FIFTYFIFTY then
			sim:getParams().foundPrisoner = false
		end
	end
end

function init( scriptMgr, sim )
	initFoundPrisoner( sim )
end

return {
	init = init,
}
