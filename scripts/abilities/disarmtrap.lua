-- patch to sim/abilities/disarmtrap.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local inventory = include( "sim/inventory" )
local simdefs = include( "sim/simdefs" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

local oldDisarmTrap = abilitydefs.lookupAbility("disarmtrap")

local disarmtrap = util.extend(oldDisarmTrap)
{
	-- Overwrite disarmtrap.executeAbility. Changes at "CBF:"
	executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		local oldFacing = abilityOwner:getFacing()

		-- CBF: Don't reset aiming for this action.
		if not cbf_util.simCheckFlag(sim, "cbf_inventory_recheckoverwatchondrop") then
			unit:resetAllAiming()
		end

		local cell = sim:getCell( abilityOwner:getLocation() )

		local target = sim:getUnit(targetUnitID)

		local newFacing = target:getFacing()

		abilityOwner:setFacing( newFacing )
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = abilityOwner:getID() } )

		local target2 = sim:getUnit(target:getTraits().linkedTrap)

		sim:warpUnit( target, nil )
		sim:despawnUnit( target )
		sim:warpUnit( target2, nil )
		sim:despawnUnit( target2 )

		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = abilityOwner:getID() } )

		sim:processReactions( abilityOwner )

		if abilityOwner:isValid() then
			abilityOwner:setFacing( oldFacing )
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = abilityOwner } )
		end
	end,
}
return disarmtrap

