local mission_scoring = include( "mission_scoring" )

local oldDoFinishMission = mission_scoring.DoFinishMission
mission_scoring.DoFinishMission = function( sim, campaign, ... )
	local flow_result = oldDoFinishMission( sim, campaign, ... )

	-- -----
	-- Rescued agent MAA status fix - fix
	-- -----
	for i, agent in ipairs( sim._resultTable.agents ) do
		if agent._cbf_name then
			agent.name = agent._cbf_name
		end
	end

	return flow_result
end
