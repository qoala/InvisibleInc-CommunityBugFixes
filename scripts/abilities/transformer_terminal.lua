-- patch to dlc/transformer_terminal.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local abilityutil = include("sim/abilities/abilityutil")
local simquery = include("sim/simquery")

local oldAbility = abilitydefs.lookupAbility("transformer_terminal")

local transformer_terminal = util.extend(oldAbility or {}) {
    -- Overwrite canUseAbility. Changes at "CBF:"
    canUseAbility = function(self, sim, abilityOwner, unit, targetUnitID)
        if abilityOwner:getTraits().mainframe_status ~= "active" then
            return false
        end

        -- CBF: Check player owner instead of firewalls. Don't lock out if Rubiks boosted firewalls after hacking.
        if abilityOwner:getPlayerOwner() ~= sim:getPC() then
            return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
        end

        if not simquery.canUnitReach(sim, unit, abilityOwner:getLocation()) then
            return false
        end

        if abilityOwner:getTraits().power_transfered then
            return false
        end

        local player = unit:getPlayerOwner()
        if player:getCpus() < self.PWRneeded then
            return false, util.sformat(STRINGS.DLC1.TRANSFORMER_TERMINAL_SELL_PWR_ERROR)
        end

        return true

    end,
}
return transformer_terminal
