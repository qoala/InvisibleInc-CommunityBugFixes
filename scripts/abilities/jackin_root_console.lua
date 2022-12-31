-- patch to sim/abilities/jackin_root_console.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local oldJackinRootConsole = abilitydefs.lookupAbility("jackin_root_console")
local oldIsTarget = oldJackinRootConsole.isTarget

local jackin_root_console = util.extend(oldJackinRootConsole) {
    isTarget = function(self, abilityOwner, unit, targetUnit)
        local sim = abilityOwner:getSim()
        if cbf_util.simCheckFlag(sim, "cbf_ending_remotehacking") then
            if targetUnit ~= abilityOwner then
                return false
            end
        end
        return oldIsTarget(self, abilityOwner, unit, targetUnit)
    end,
}
return jackin_root_console
