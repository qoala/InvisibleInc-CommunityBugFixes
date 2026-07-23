local astar_handlers = include("sim/astar_handlers")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local new = astar_handlers.coop_handler.new
astar_handlers.coop_handler.new = function(self, unit, ...)
	local coop_handler = new(self, unit, ...)
	if not unit:getSim() or not cbf_util.simCheckFlag(unit:getSim(), "cbf_disguisefix_pathing") then
		return coop_handler
	end

	-- new simquery.canSoftPath handles enemy impass
	coop_handler.lostTargetInterest = nil

	return coop_handler
end
