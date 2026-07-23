local astar_handlers = include("sim/astar_handlers")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local new = astar_handlers.coop_handler.new
astar_handlers.coop_handler.new = function(self, unit, ...)
	local coop_handler = new(self, unit, ...)
	if
		not unit:getSim()
		or not cbf_util.simCheckFlag(unit:getSim(), "cbf_disguisefix_pathing")
		or not (unit:getBrain() and unit:getBrain():getSenses() and unit:getBrain():getSenses().CBF_impassMemory)
	then
		return coop_handler
	end

    coop_handler.lostTargetInterest = nil

	-- ughh, AGP's astar override makes guards not even try to move onto an overwatched agent's tile diagonally...
	local _handleNode = coop_handler._handleNode
	coop_handler._handleNode = function(self, ...)
		local isUnitUnderOverwatch = simquery.isUnitUnderOverwatch
		simquery.isUnitUnderOverwatch = function()
			return false
		end
		local node = _handleNode(self, ...)
		simquery.isUnitUnderOverwatch = isUnitUnderOverwatch
		return node
	end

    return coop_handler
end
