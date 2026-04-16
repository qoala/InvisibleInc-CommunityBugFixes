-- do not execute shootOverwatch if guard started aiming during the very same PC action.
-- trait set in aiplayer.tickBrain
local abilitydefs = include("sim/abilitydefs")
local shootOverwatch = abilitydefs.lookupAbility("shootOverwatch")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

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
    if cbf_util.simCheckFlag(sim, "cbf_rebalance_overwatchDueling") then
        sim:processReactions(userUnit) -- issue #19 
    end
end
