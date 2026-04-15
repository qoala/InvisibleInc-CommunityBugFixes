local actions = include("sim/btree/actions")

-- fix issue caused by the asymmetric losmap that a guard can spot an agent without them seeing the guard at all
local ReactToTarget = actions.ReactToTarget
actions.ReactToTarget = function(sim, unit, ...)
    local target = unit:getBrain():getTarget()
    if target and unit:isValid() and target:isPC() and target:getTraits().isAgent and
            not sim:canPlayerSeeUnit(sim:getPC(), unit) then
        sim:getPC():glimpseUnit(sim, unit:getID())
    end
    return ReactToTarget(sim, unit, ...)
end
