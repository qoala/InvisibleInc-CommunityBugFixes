local script_mgr = include("sim/level").script_mgr
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local util = include("modules/util")

-- fix mission scripts not triggering for units and cells that are already seen before the hook waiting for the TRG was added

local loadScript = script_mgr.loadScript
script_mgr.loadScript = function(self, ...)
	loadScript(self, ...)
    -- iterating by keys for stable order and protection against mutation during iteration
	for ID, unit in util.pairsByKeys(self.sim:getAllUnits()) do
		if unit and simquery.couldUnitSee(self.sim, unit) then
			local cells = {}
			self.sim:getLOS():getVizCells(ID, cells)
			self.sim:triggerEvent(simdefs.TRG_LOS_REFRESH, { seer = unit, cells = cells })
			if unit:getSeenUnits() then
				for _, seenUnit in ipairs(util.tdupe(unit:getSeenUnits())) do
					self.sim:triggerEvent(simdefs.TRG_UNIT_APPEARED, { seerID = ID, unit = seenUnit })
				end
			end
		end
	end
end
