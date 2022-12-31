-- patch to sim/abilities/activate_locked_console.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local abilityutil = include("sim/abilities/abilityutil")
local simquery = include("sim/simquery")

local oldOpenDetentionCells = abilitydefs.lookupAbility("open_detention_cells")

local open_detention_cells = util.extend(oldOpenDetentionCells or {}) {
    -- Overwrite canUseAbility. Changes at "CBF:"
    canUseAbility = function(self, sim, abilityOwner, unit, targetUnitID)
        if abilityOwner:getTraits().mainframe_status ~= "active" then
            return false
        end

        if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
            return false,
                   util.sformat(STRINGS.UI.REASON.COOLDOWN, abilityOwner:getTraits().cooldown)
        end

        -- CBF: Check player owner instead of firewalls. Don't lock out if Rubiks boosted firewalls after hacking.
        if abilityOwner:getPlayerOwner() ~= sim:getPC() then
            return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
        end

        if not simquery.canUnitReach(sim, unit, abilityOwner:getLocation()) then
            return false
        end

        return true
    end,
}
return open_detention_cells
