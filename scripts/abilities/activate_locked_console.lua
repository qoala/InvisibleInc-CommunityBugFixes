-- patch to sim/abilities/activate_locked_console.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local abilityutil = include("sim/abilities/abilityutil")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local oldActivateLockedConsole = abilitydefs.lookupAbility("activate_locked_console")
local oldIsTarget = oldActivateLockedConsole.isTarget

function hasSecurityChip(sim, abilityOwner, unit)
    if cbf_util.simCheckFlag(sim, "cbf_ending_finaldoor") then
        for i, item in ipairs(unit:getChildren()) do
            if item:getTraits().finalAugmentKey then
                return true
            end
        end
    else
        for i, item in ipairs(unit:getChildren()) do
            if item:getTraits().keybits then
                if item:getTraits().keybits == abilityOwner:getTraits().keybits then
                    return true
                end
            end
        end
    end
    return false
end

local activate_locked_console = util.extend(oldActivateLockedConsole) {
    isTarget = function(self, abilityOwner, unit, targetUnit)
        local sim = abilityOwner:getSim()
        if cbf_util.simCheckFlag(sim, "cbf_ending_remotehacking") then
            if targetUnit ~= abilityOwner then
                return false
            end
        end
        return oldIsTarget(self, abilityOwner, unit, targetUnit)
    end,

    -- Overwrite canUseAbility. Changes at "CBF:"
    canUseAbility = function(self, sim, abilityOwner, unit, targetUnitID)
        local targetUnit = sim:getUnit(targetUnitID)
        local userUnit = abilityOwner:getUnitOwner()

        if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
            return false, util.sformat(
                    STRINGS.ABILITIES.UI.REASON.COOLDOWN, abilityOwner:getTraits().cooldown)
        end

        -- CBF: Check for the security chip by its unique trait, instead of keybits.
        -- Removing keybits from the chip so that it can't unlock the door directly.
        if not hasSecurityChip(sim, abilityOwner, unit) then
            return false, STRINGS.UI.REASON.MONST3R_REQUIRED
        end

        -- CBF: Check player owner instead of firewalls. Don't lock out if Rubiks boosted firewalls after hacking.
        if abilityOwner:getPlayerOwner() ~= sim:getPC() then
            return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
        end

        return abilityutil.checkRequirements(abilityOwner, userUnit)
    end,
}
return activate_locked_console
