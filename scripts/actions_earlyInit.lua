local actions = include("sim/btree/actions")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local onPathBlocked = actions.MoveTo.onPathBlocked
actions.MoveTo.onPathBlocked = function(self, blocker, ...)
	if not cbf_util.simCheckFlag(self.sim, "cbf_disguisefix_pathing") then
		return onPathBlocked(self, blocker, ...)
	end

	if self.unit:getPlayerOwner() ~= blocker:getPlayerOwner() then
		local x0, y0 = self.unit:getLocation()
		local x1, y1 = blocker:getLocation()

		if
			math.abs(x1 - x0) == 1
			and math.abs(y1 - y0) == 1
			and (
				simquery.checkCellCover(self.sim, x0, y0, x1, y1) and not self.unit:getTraits().seesHidden
				or not self.sim:getLOS():raycastToCell(x0, y0, x1, y1, 0, math.pi)
			)
		then
			-- calculate new path when diagonal with no vision on the cell
			return simdefs.BSTATE_RUNNING
		elseif not simquery.isEnemyTarget(self.unit:getPlayerOwner(), blocker) then
			-- TODO: add gen option here
			if true then
				-- NEW: immediately calculate new path and go around non-hostile unit from a different owner
				-- this affects hacked drones, disguised agents (that don't break on proximity), lethal lasers
				return simdefs.BSTATE_RUNNING
			end
		elseif
			-- hostile unit blocked us on a cell that is visible, react to it
			-- (still return RUNNING so the unit will process the interest immediately,
			-- alternatively call processReactions to process the interest and return FAILED)
			self.unit:getBrain():getSenses():addInterest(x0, y0, simdefs.SENSE_PERIPHERAL, simdefs.REASON_NOTICED)
		then
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
