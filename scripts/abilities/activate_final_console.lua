-- patch to sim/abilities/activate_final_console.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local oldActivateFinalConsole = abilitydefs.lookupAbility("activate_final_console")
local oldIsTarget = oldActivateFinalConsole.isTarget
local oldAcquireTargets = oldActivateFinalConsole.acquireTargets

-- Returns true if within the surrounding 8 tiles
-- Preserves ability to "remote-hack" the final mainframe terminal anywhere along its 3-wide length.
local function isCloseEnough(unit, targetUnit)
    local x0, y0 = unit:getLocation()
    local x1, y1 = targetUnit:getLocation()
    return math.abs(x0 - x1) <= 1 and math.abs(y0 - y1) <= 1
end

local activate_final_console = util.extend(oldActivateFinalConsole) {
    isTarget = function(self, abilityOwner, unit, targetUnit)
        local sim = abilityOwner:getSim()
        if cbf_util.simCheckFlag(sim, "cbf_ending_remotehacking") then
            if targetUnit ~= abilityOwner then
                return false
            end
        end
        return oldIsTarget(self, abilityOwner, unit, targetUnit)
    end,

    acquireTargets = function(self, targets, game, sim, abilityOwner, unit)
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
    end,
}
return activate_final_console
