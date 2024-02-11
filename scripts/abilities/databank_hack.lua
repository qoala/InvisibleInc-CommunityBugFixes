-- patch to dlc/databank_hack.lua
local abilitydefs = include("sim/abilitydefs")

local function patchAbility()
    local abil = abilitydefs.lookupAbility("databank_hack")
    if not abil then
        simlog("[CBF][WARN] databank_hack ability not present. No DLC?")
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
