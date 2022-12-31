-- patch to sim/simplayer
local util = include("modules/util")
local simplayer = include("sim/simplayer")
local aiplayer = include("sim/simplayer")
local pcplayer = include("sim/pcplayer")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- Update known subclasses of simplayer (subclasses that don't use the class factory don't see changes in their base class)
local function replicateToSubclasses(subclasses, name, fn, oldFn)
    for _, subclass in ipairs(subclasses) do
        if subclass[name] == oldFn then
            subclass[name] = fn
        end
    end
end

-- ===

local oldOnStartTurn = simplayer.onStartTurn

-- Overwrite simplayer:onStartTurn. Changes at "CBF:"
function simplayer:onStartTurn(sim, ...)
    local fixCycleTiming = cbf_util.simCheckFlag(sim, "cbf_cycletiming")
    if fixCycleTiming then
        -- CBF: Move this clause before all unit:onStartTurn calls, instead of after.
        --   Laptops, Distributed Processing, etc generate start of turn power during this call instead of as a TRG_START_TURN handler.
        if sim:getTags().clearPWREachTurn then
            self:addCPUs(-self:getCpus(), sim)
        end

        local units = util.tdupe(self._units)
        for i, unit in ipairs(units) do
            if unit:isValid() then
                unit:onStartTurn(sim)
            end
        end
    else
        oldOnStartTurn(self, sim, ...)
    end
end

replicateToSubclasses({pcplayer}, 'onStartTurn', simplayer.onStartTurn, oldOnStartTurn)

-- ===

local oldDeployUnit = simplayer.deployUnit

function simplayer:deployUnit(sim, agentID, ...)
    if agentID == 99 and cbf_util.simCheckFlag(sim, "cbf_escorts_fixed") then -- monst3r
        if sim:getParams().agency._keptItems and sim:getParams().agency._keptItems[100] then
            local agentDef = self._deployed[agentID].agentDef
            agentDef.upgrades = sim:getParams().agency._keptItems[100]
        end
    end

    return oldDeployUnit(self, sim, agentID, ...)
end

replicateToSubclasses({pcplayer}, 'deployUnit', simplayer.deployUnit, oldDeployUnit)
