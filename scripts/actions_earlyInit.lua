local actions = include("sim/btree/actions")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local onPathBlocked = actions.MoveTo.onPathBlocked
actions.MoveTo.onPathBlocked = function(self, blocker, ...)
	local impassMemory = self.unit:getBrain()
		and self.unit:getBrain():getSenses()
		and self.unit:getBrain():getSenses().CBF_impassMemory
	if not cbf_util.simCheckFlag(self.sim, "cbf_disguisefix_pathing") or not impassMemory then
		return onPathBlocked(self, blocker, ...)
	end

	local x0, y0 = self.unit:getLocation()
	local x1, y1 = blocker:getLocation()
	local inCover = simquery.checkCellCover(self.sim, x0, y0, x1, y1)

	if simquery.isEnemyTarget(self.unit:getPlayerOwner(), blocker) and not inCover then
		self.unit:getBrain():getSenses():addInterest(x0, y0, simdefs.SENSE_PERIPHERAL, simdefs.REASON_NOTICED)
		impassMemory:updateUnit(blocker, not inCover)
		return simdefs.BSTATE_RUNNING
	elseif self.unit:getPlayerOwner() ~= blocker:getPlayerOwner() then
		-- also return RUNNING if it's not an enemy target but it is still from a different player owner
		impassMemory:updateUnit(blocker, not inCover)
		return simdefs.BSTATE_RUNNING
	else
		return simdefs.BSTATE_FAILED
	end
end

for _, action in pairs(actions) do
	if type(action) == "table" and action.onPathBlocked == onPathBlocked then
		action.onPathBlocked = actions.MoveTo.onPathBlocked
	end
end
