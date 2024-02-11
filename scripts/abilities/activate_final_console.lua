-- patch to sim/abilities/activate_final_console.lua
local abilitydefs = include("sim/abilitydefs")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- Returns true if within the surrounding 8 tiles
-- Preserves ability to "remote-hack" the final mainframe terminal anywhere along its 3-wide length.
local function isCloseEnough(unit, targetUnit)
    local x0, y0 = unit:getLocation()
    local x1, y1 = targetUnit:getLocation()
    return math.abs(x0 - x1) <= 1 and math.abs(y0 - y1) <= 1
end

-- ===

local abil = abilitydefs.lookupAbility("activate_final_console")

local oldIsTarget = abil.isTarget
function abil:isTarget(abilityOwner, unit, targetUnit)
    local sim = abilityOwner:getSim()
    if cbf_util.simCheckFlag(sim, "cbf_ending_remotehacking") then
        if targetUnit ~= abilityOwner then
            return false
        end
    end
    return oldIsTarget(self, abilityOwner, unit, targetUnit)
end

local oldAcquireTargets = abil.acquireTargets
function abil:acquireTargets(targets, game, sim, abilityOwner, unit)
    local units = {}
    if not cbf_util.simCheckFlag(sim, "cbf_ending_remotehacking") then
        return oldAcquireTargets(self, targets, game, sim, abilityOwner, unit)
    end

    local units = {}
    for _, targetUnit in pairs(sim:getAllUnits()) do
        if self:isTarget(abilityOwner, unit, targetUnit) and isCloseEnough(unit, targetUnit) then
            table.insert(units, targetUnit)
        end
    end

    return targets.unitTarget(game, units, self, abilityOwner, unit)
end
