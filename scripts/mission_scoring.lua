-- patch to client/mission_scoring

local mission_scoring = include( "mission_scoring" )
local serverdefs = include( "modules/serverdefs" )

local oldDoFinishMission = mission_scoring.DoFinishMission

mission_scoring.DoFinishMission = function( sim, campaign, ... )

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
		if deployData.agentDef.id == 100 then
			i = agentID
		end
	end

	if i and (survivors == false) then
		local Monster_data = deployed[i]
		Monster_data.agentDef.leave = nil
	end

	local flow_result = oldDoFinishMission( sim, campaign, ... )

	return flow_result
end
