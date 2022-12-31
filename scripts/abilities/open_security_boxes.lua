-- patch to sim/abilities/activate_locked_console.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local abilityutil = include("sim/abilities/abilityutil")
local simquery = include("sim/simquery")

local oldOpenSecurityBoxes = abilitydefs.lookupAbility("open_security_boxes")

local open_security_boxes = util.extend(oldOpenSecurityBoxes or {}) {
    -- Overwrite canUseAbility. Changes at "CBF:"
    canUseAbility = function(self, sim, abilityOwner, unit, targetUnitID)
        local targetUnit = sim:getUnit(targetUnitID)
        local userUnit = abilityOwner:getUnitOwner()

        if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
            return false, util.sformat(STRINGS.UI.REASON.COOLDOWN, unit:getTraits().cooldown)
        end

        -- CBF: Check player owner instead of firewalls. Don't lock out if Rubiks boosted firewalls after hacking.
        if abilityOwner:getPlayerOwner() ~= sim:getPC() then
            return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
        end

        return abilityutil.checkRequirements(abilityOwner, userUnit)
    end,
}
return open_security_boxes
