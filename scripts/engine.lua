
local simengine = include("sim/engine")

local oldInit = simengine.init

function simengine:init( ... )
	oldInit( self, ... )

	if self:getParams().difficultyOptions.cbf_nopatrol_fixfacing then
		for i,unit in pairs( self:getAllUnits() ) do
			if unit:getTraits().nopatrol then
				unit:getTraits().patrolPath[1].facing = unit:getFacing()
			end
		end
	end
end
