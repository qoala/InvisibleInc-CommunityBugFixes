-- patch to dlc/activate_refit_drone.lua
local abilitydefs = include("sim/abilitydefs")

local function patchAbility()
    local abil = abilitydefs.lookupAbility("activate_refit_drone")
    if not abil then
        return
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
end

patchAbility()
