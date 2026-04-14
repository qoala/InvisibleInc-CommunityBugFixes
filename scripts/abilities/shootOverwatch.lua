-- do not execute shootOverwatch if guard started aiming during the very same PC action.
-- trait set in aiplayer.tickBrain

local abilitydefs = include("sim/abilitydefs")
local shootOverwatch = abilitydefs.lookupAbility("shootOverwatch")

local origOnTrigger = shootOverwatch.onTrigger
function shootOverwatch:onTrigger(sim, evType, evData, userUnit, ...)
    if userUnit:getTraits()._cbf_aim_id == sim:getActionCount() then
        return
    end
    origOnTrigger(self, sim, evType, evData, userUnit, ...)
end

local origExecuteAbility = shootOverwatch.executeAbility
function shootOverwatch:executeAbility(sim, unit, userUnit, targetUnit, ...)
    origExecuteAbility(self, sim, unit, userUnit, targetUnit, ...)
    sim:processReactions(userUnit) -- issue #19 
end
