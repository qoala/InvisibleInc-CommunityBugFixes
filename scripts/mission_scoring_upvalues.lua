
local mission_scoring = include( "mission_scoring" )

local function appendUpvalue( fn, name, appender )
	local i = 1
	local oldValue
	while true do
		local n, v = debug.getupvalue(fn, i)
		assert(n, string.format( "Could not find upvalue: %s", name ) )
		if n == name then
			oldValue = v
			break
		end
		i = i + 1
	end

	local newValue = appender(oldValue)

	debug.setupvalue(fn, i, newValue)
end

if not mission_scoring._updateAgencyFromSim then
	appendUpvalue(mission_scoring.DoFinishMission, "updateAgencyFromSim", function(oldUpdateAgencyFromSim)
		mission_scoring._updateAgencyFromSim = oldUpdateAgencyFromSim

		local function updateAgencyFromSim( campaign, sim, situation, ... )
			return mission_scoring._updateAgencyFromSim( campaign, sim, situation, ... )
		end

		return updateAgencyFromSim
	end)
end
