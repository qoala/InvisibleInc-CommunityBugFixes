local actions = include("sim/btree/actions")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")
local array = include("modules/array")

local onPathBlocked = actions.MoveTo.onPathBlocked
actions.MoveTo.onPathBlocked = function(self, blocker, ...)
	if not cbf_util.simCheckFlag(self.sim, "cbf_disguisefix_pathing") then
		return onPathBlocked(self, blocker, ...)
	end

	if self.unit:getPlayerOwner() ~= blocker:getPlayerOwner() then
		if
			self.unit:getSeenUnits() and array.find(self.unit:getSeenUnits(), blocker)
			or simquery.couldUnitSee(self.sim, self.unit, blocker, true)
		then
			-- we handle these cases in simquery.canSoftPath
			return simdefs.BSTATE_RUNNING
		else
			-- be confused
			local x, y = self.unit:getLocation()
			self.unit:getBrain():getSenses():addInterest(x, y, simdefs.SENSE_PERIPHERAL, simdefs.REASON_NOTICED)
			return simdefs.BSTATE_RUNNING
		end
	end
	return simdefs.BSTATE_FAILED
end

for _, action in pairs(actions) do
	if type(action) == "table" and action.onPathBlocked == onPathBlocked then
		action.onPathBlocked = actions.MoveTo.onPathBlocked
	end
end
