-- patch to sim/abilities/doorMechanism.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local inventory = include("sim/inventory")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local abil = abilitydefs.lookupAbility("doorMechanism")

-- Overwrite doorMechanism.executeAbility. Changes at "CBF:"
-- Includes patches from FunctionLibrary for NIAA and LEVER.
function abil:executeAbility(sim, unit, userUnit, x0, y0, dir)
    local fromCell = sim:getCell(x0, y0)
    assert(fromCell and dir)

    -- CBF: Don't reset aiming for this action.
    if not cbf_util.simCheckFlag(sim, "cbf_inventory_recheckoverwatchondrop") then
        userUnit:resetAllAiming()
    end

    -- RolandJ: If we're not on the target tile (the near side of the door),
    -- face that tile, instead of facing the exit's dir.
    local ux, uy = userUnit:getLocation()
    local vizFacing
    if ux == x0 and uy == y0 then
        vizFacing = dir
    else
        vizFacing = simquery.getDirectionFromDelta(x0 - ux, y0 - uy)
    end
    sim:dispatchEvent(simdefs.EV_UNIT_USEDOOR, {unitID = userUnit:getID(), facing = vizFacing})
    -- Function Library: decodeVault support for NIAA
    local doorDevice = nil
    if unit:getTraits().decodeVault then
        doorDevice = include(SCRIPT_PATHS.W93_NIAA .. "/W93_lock_decoder")
    else
        doorDevice = include(string.format("sim/units/%s", unit:getTraits().doorDevice))
    end
    -- RJ: Must use dir for the exit, not vizFacing, in order to apply device correctly.
    doorDevice.applyToDoor(sim, fromCell, dir, unit, userUnit)
    inventory.useItem(sim, userUnit, unit)

    sim:emitSound(simdefs.SOUND_PLACE_TRAP, x0, y0, userUnit)

    sim:processReactions(userUnit)
    -- RJ: vizFacing again.
    sim:dispatchEvent(simdefs.EV_UNIT_USEDOOR_PST, {unitID = userUnit:getID(), facing = vizFacing})
    -- Function Library: support for LEVER
    if simquery.LEVER_resetStatus then
        simquery.LEVER_resetStatus(sim, userUnit, "ANY", false)
    end
end
