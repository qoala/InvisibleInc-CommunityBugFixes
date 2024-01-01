-- patch to dlc/activate_refit_drone.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local abilityutil = include("sim/abilities/abilityutil")
local simquery = include("sim/simquery")

local oldAbility = abilitydefs.lookupAbility("activate_refit_drone")

local activate_refit_drone = util.extend(oldAbility or {}) {
    -- Overwrite canUseAbility. Changes at "CBF:"
    canUseAbility = function(self, sim, unit, userUnit, targetUnitID)
        if unit:getTraits().relased_hostage then
            return false
        end

        if unit:getTraits().mainframe_status ~= "active" then
            return false
        end

        if unit:getTraits().cooldown and unit:getTraits().cooldown > 0 then
            return false, util.sformat(STRINGS.UI.REASON.COOLDOWN, unit:getTraits().cooldown)
        end

        -- CBF: Check player owner instead of firewalls. Don't lock out if Rubiks boosted firewalls after hacking.
        if unit:getPlayerOwner() ~= sim:getPC() then
            return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
        end

        if userUnit:getPlayerOwner() == nil or userUnit:getTraits().isDrone then
            return false
        end

        return simquery.canUnitReach(sim, userUnit, unit:getLocation())
    end,
}
return activate_refit_drone
