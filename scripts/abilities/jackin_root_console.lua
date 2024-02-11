-- patch to sim/abilities/jackin_root_console.lua
local abilitydefs = include("sim/abilitydefs")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- ===

local abil = abilitydefs.lookupAbility("jackin_root_console")

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

local oldCanUse = abil.canUseAbility
function abil:canUseAbility(sim, unit, userUnit, targetUnitID)
    local oldIce
    if unit:getPlayerOwner() == sim:getPC() and unit:getTraits().mainframe_ice > 0 then
        -- Hide bugged firewalls if they've gotten out of sync with player ownership.
        oldIce = unit:getTraits().mainframe_ice
        unit:getTraits().mainframe_ice = 0
    end

    local ret, reason = oldCanUse(self, sim, unit, userUnit, targetUnitID)

    if oldIce then
        unit:getTraits().mainframe_ice = oldIce
    end

    return ret, reason
end
