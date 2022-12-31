-- patch to sim/abilities/carryable.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local inventory = include("sim/inventory")
local simdefs = include("sim/simdefs")

local oldCarryable = abilitydefs.lookupAbility("carryable")

local carryable = util.extend(oldCarryable) {
    -- Overwrite carryable.executeAbility. Changes at "CBF:"
    executeAbility = function(self, sim, unit, userUnit)
        local cell = sim:getCell(unit:getLocation())
        if cell then
            -- Pickup
            inventory.pickupItem(sim, userUnit, unit)
            sim:dispatchEvent(simdefs.EV_UNIT_PICKUP, {unitID = userUnit:getID()})

        else
            -- Drop
            inventory.dropItem(sim, userUnit, unit)
            local x0, y0 = userUnit:getLocation()
            sim:emitSound(simdefs.SOUND_ITEM_PUTDOWN, x0, y0, userUnit)
            sim:dispatchEvent(simdefs.EV_UNIT_PICKUP, {unitID = userUnit:getID()})
        end

        -- CBF: custom recheckAllAiming only resets ambush/overwatch if it's no longer available.
        if userUnit.recheckAllAiming then
            userUnit:recheckAllAiming()
        else
            -- This shouldn't happen
            simlog(
                    "CBF: unit did not define recheckAllAiming. Falling back to resetAllAiming. %s [%d]",
                    userUnit:getName(), userUnit:getID())
            userUnit:resetAllAiming()
        end
        sim:dispatchEvent(simdefs.EV_UNIT_REFRESH, {unit = userUnit})
    end,
}
return carryable
