-- Fix observePath ability not respecting vision gained from camera canisters, turrets etc.
-- Check all PC units that have hasSight and are not agents or eyeballs
local array = include("modules/array")
local abilitydefs = include("sim/abilitydefs")
local observePath = abilitydefs.lookupAbility("observePath")

local origAquireTargets = observePath.acquireTargets
function observePath:acquireTargets(targets, game, sim, unit, userUnit, ...)
    local unitTarget = origAquireTargets(self, targets, game, sim, unit, userUnit, ...)
    for _, targetUnit in pairs(sim:getAllUnits()) do
        if self:isTarget(unitTarget._abilityUser, targetUnit) and not array.find(unitTarget._units, targetUnit) then
            for _, seerUnit in pairs(sim:getPC():getUnits()) do
                if not (seerUnit:getTraits().isAgent or seerUnit:getTraits().peekID) and seerUnit:getTraits().hasSight and
                    sim:canUnitSeeUnit(seerUnit, targetUnit) then
                    table.insert(unitTarget._units, targetUnit)
                    break
                end
            end
        end
    end
    return unitTarget
end
