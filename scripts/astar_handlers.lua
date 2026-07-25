local astar_handlers = include("sim/astar_handlers")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local new = astar_handlers.coop_handler.new
astar_handlers.coop_handler.new = function(self, unit, ...)
	local coop_handler = new(self, unit, ...)
	if not unit:getSim() or not cbf_util.simCheckFlag(unit:getSim(), "cbf_disguisefix_pathing") then
		return coop_handler
	end

	-- the main buggy part about this AGP feature is that it can stop vip units from moving indefinitely if it has an
	-- interest at a door, but it's fine during NPC turn (we recalculate paths at pc turn start)
	if unit:getSim():getCurrentPlayer() ~= unit:getPlayerOwner() then
		coop_handler.lostTargetInterest = nil
	end

	return coop_handler
end
