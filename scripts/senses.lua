-- patch to sim/btree/senses
local Senses = include("sim/btree/senses")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local oldAddInterest = Senses.addInterest
function Senses:addInterest(x, y, sense, reason, sourceUnit, ignoreDisguise, ...)
    local interest = oldAddInterest(self, x, y, sense, reason, sourceUnit, ignoreDisguise, ...)

    -- CBF: Update observed pathing when the guard's current interest moves.
    -- Reference equality check: Did addInterest just modify the interest object held by the brain?
    if interest and self.unit:getBrain():getInterest() and interest ==
            self.unit:getBrain():getInterest() then
        local sim = self.unit:getSim()
        local pathingOption = cbf_util.simCheckFlag(sim, "cbf_pathing")
        if pathingOption and pathingOption.reset_on_interest_moved and sim:getCurrentPlayer():isPC() then
            if sim:cbfHasPathingQueue() then
                sim:cbfAddToPathingQueue(self.unit)
			elseif self.unit:getPather() then
				self.unit:getPather():invalidatePath(self.unit)
            end
        end
    end

    return interest
end

local oldProcessAppearedTrigger = Senses.processAppearedTrigger
function Senses:processAppearedTrigger(sim, evData, ...)
    -- CBF: Don't re-investigate parts of a smoke cloud that we've already inspected.
    local smokeEdgeOption = cbf_util.simCheckFlag(sim, "cbf_smoke_rememberedges")
    if smokeEdgeOption and evData.unit:getTraits().smokeEdge and evData.unit.getActiveSmokeClouds then
        local canInvestigate = false
        for _, cloud in ipairs(evData.unit:getActiveSmokeClouds(sim)) do
            if not cloud:hasBeenSmokeInvestigated(self.unit) then
                canInvestigate = true
                break
            end
        end
        if not canInvestigate then
            -- Already investigated these clouds.
            return
        end
    end

    return oldProcessAppearedTrigger(self, sim, evData, ...)
end
