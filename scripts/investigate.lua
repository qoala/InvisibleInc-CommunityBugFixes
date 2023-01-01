-- patch to sim/btree/situations/investigate
local InvestigateSituation = include("sim/btree/situations/investigate")

local function markCloudsSearched(sim, unit, cell)
    if cell and cell.cbfSmokeCloudIDs then
        for _, cloudID in ipairs(cell.cbfSmokeCloudIDs) do
            local cloud = sim:getUnit(cloudID)
            if cloud then
                cloud:setSmokeInvestigated(unit)
            end
        end
    end
    if cell and cell.cbfSmokeEdgeID then
        local edge = sim:getUnit(cell.cbfSmokeEdgeID)
        if edge then
            edge:setInvestigated(unit)
        end
    end
end

local oldMarkInvestigated = InvestigateSituation.markInterestInvestigated
function InvestigateSituation:markInterestInvestigated(unit, ...)
    -- Mark any smoke clouds on the investigator's tile as investigated
    local sim = unit:getSim()
    local cell = sim:getCell(unit:getLocation())
    markCloudsSearched(sim, unit, cell)
    -- Mark any smoke clouds on the interest
    local interest = unit:getBrain():getInterest()
    if interest and interest.reason == simdefs.REASON_SMOKE and (interest.x ~= x or interest.y ~= y) and
            sim:canUnitSee(unit, interest.x, interest.y) then
        local targetCell = sim:getCell(interest.x, interest.y)
        markCloudsSearched(sim, unit, targetCell)
    end

    return oldMarkInvestigated(self, unit, ...)
end

