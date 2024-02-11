-- patch to sim/abilities/prime_emp.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local inventory = include("sim/inventory")
local simdefs = include("sim/simdefs")
local simfactory = include("sim/simfactory")
local unitdefs = include("sim/unitdefs")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- ===

local abil = abilitydefs.lookupAbility("prime_emp")

-- Overwrite prime_emp.executeAbility. Changes at "CBF:"
function abil:executeAbility(sim, unit, userUnit)
    local cell = sim:getCell(unit:getLocation()) or sim:getCell(userUnit:getLocation())
    local newUnit = simfactory.createUnit(unitdefs.lookupTemplate(unit:getUnitData().id), sim)
    sim:dispatchEvent(simdefs.EV_UNIT_PICKUP, {unitID = userUnit:getID()})

    sim:spawnUnit(newUnit)
    sim:warpUnit(newUnit, cell)
    newUnit:removeAbility(sim, "carryable")

    sim:emitSound(simdefs.SOUND_ITEM_PUTDOWN, cell.x, cell.y, userUnit)
    sim:emitSound(simdefs.SOUND_PRIME_EMP, cell.x, cell.y, userUnit)

    newUnit:getTraits().primed = true

    if newUnit:getTraits().trigger_mainframe then
        newUnit:getTraits().mainframe_item = true
        newUnit:getTraits().mainframe_status = "on"
        newUnit:setPlayerOwner(userUnit:getPlayerOwner())
    end

    -- CBF: Don't reset aiming for this action.
    if not cbf_util.simCheckFlag(sim, "cbf_inventory_recheckoverwatchondrop") then
        userUnit:resetAllAiming()
    end

    inventory.useItem(sim, userUnit, unit)

    if userUnit:isValid() then
        sim:dispatchEvent(simdefs.EV_UNIT_REFRESH, {unit = userUnit})
    end
end
