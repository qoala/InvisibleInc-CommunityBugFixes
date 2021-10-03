-- patch to client/mission_scoring

local array = include( "modules/array" )
local mission_scoring = include( "mission_scoring" )
local serverdefs = include( "modules/serverdefs" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )
local constants = include( SCRIPT_PATHS.qoala_commbugfix .. "/constants" )

local oldDoFinishMission = mission_scoring.DoFinishMission

mission_scoring.DoFinishMission = function( sim, campaign, ... )

	-- -----
	-- DLC mid2 softlock fix.
	-- -----

	local player = sim:getPC()
	local agency = campaign.agency
	local survivors = false
	local deployed = player:getDeployed()
	local i = nil
	for agentID, deployData in pairs( deployed ) do
		local agentDef = serverdefs.findAgent( agency, agentID )
		-- log:write("LOG deployData")
		-- log:write(util.stringize(deployData,2))
		if deployData.agentDef and deployData.id then
			if deployData.escapedUnit and not deployData.agentDef.leave then
				survivors = true
				-- log:write("LOG survivors true")
			end
		end
		if deployData.agentDef.id == constants.AGENT_IDS.MONST3R_PC then
			i = agentID
		end
	end

	if i and (survivors == false) then
		local Monster_data = deployed[i]
		Monster_data.agentDef.leave = nil
		-- Remove Monst3r from the detention pool if he was a starting agent and lost, to prevent having 2 Monst3rs.
		-- Unless another mod is preserving augments from the detention pool, they will be lost.
		array.removeIf( agency.unitDefsPotential, function( adef ) return adef.id == constants.AGENT_IDS.MONST3R_PC end )
	end

	-- -----
	-- END DLC mid2 softlock fix.
	-- -----

	local previousFoundPrisoner = campaign.foundPrisoner

	local flow_result = oldDoFinishMission( sim, campaign, ... )

	-- -----
	-- Detention Centers agent chance fix
	-- -----

	local spawnAgentOption = cbf_util.optionsCheckFlag(campaign.difficultyOptions, "cbf_detention_spawnagent", constants.MISSIONDETCENTER_SPAWNAGENT.VANILLA)
	if spawnAgentOption ~= constants.MISSIONDETCENTER_SPAWNAGENT.VANILLA then
		if spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.ALWAYS then
			campaign.foundPrisoner = true
		elseif sim:getTags().cbfCouldHaveAgent then
			-- No change needed
		elseif previousFoundPrisoner == nil and spawnAgentOption == constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT then
			-- Initialize foundPrisoner for the first time.
			campaign.foundPrisoner = true
		else
			-- Leave the previous prisoner-vs-agent chance after missions that couldn't have an agent in the first place
			campaign.foundPrisoner = previousFoundPrisoner
		end
	end

	-- -----
	-- END Detention Centers agent chance fix
	-- -----

	return flow_result
end
