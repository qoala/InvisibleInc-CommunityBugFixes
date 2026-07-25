local aiplayer = include("sim/aiplayer")
local simdefs = include("sim/simdefs")
local array = include("modules/array")

-- part of the canSoftPath/onPathBlocked fixes - invalidate all paths at pc turn start before aiplayer ticks brains
-- to recalculate any stale paths that are still aware of enemy agents
local onTrigger = aiplayer.onTrigger
aiplayer.onTrigger = function(self, sim, evType, evData, ...)
	if evType == simdefs.TRG_START_TURN and evData ~= self then
		for _, unit in ipairs(self:getUnits()) do
			self.pather:invalidatePath(unit)
		end
	end
	return onTrigger(self, sim, evType, evData, ...)
end

-- part of overwatch fixes
-- sim_cbf_movingUnit is set in simengine.moveUnit
-- unit:getTraits()._cbf_aim_id is checked in shootOverwatch.executeAbility

-- probably safer so set our own tracker instead of checking for the movePath trait in case some mod messes with it
local origTickBrain = aiplayer.tickBrain
function aiplayer:tickBrain(unit)
    local wasAiming = unit:isAiming()
    local thought = origTickBrain(self, unit)
    if not wasAiming and unit:isAiming() and self._sim:getCurrentPlayer():isPC() then
        unit:getTraits()._cbf_aim_id = self._sim:getActionCount()
    end
    return thought
end

-- if unit is still in the process of moving, do not tick brains unless processing reactions to the moving unit.
-- might also need to intercept if no sourceUnit is given, but haven't found the need to so far.
local origProcessReactions = aiplayer.processReactions
function aiplayer:processReactions(sourceUnit)
    local movingUnit = self._sim._cbf_movingUnit
    if movingUnit and sourceUnit and movingUnit ~= sourceUnit and movingUnit:canAct() and
            not movingUnit:getTraits().interrupted then
        return
    end
    origProcessReactions(self, sourceUnit)
end
