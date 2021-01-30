-- patch to sim/abilities/disarmtrap.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local inventory = include( "sim/inventory" )
local simdefs = include( "sim/simdefs" )

local oldDisarmTrap = abilitydefs.lookupAbility("disarmtrap")

local disarmtrap = util.extend(oldDisarmTrap)
{
	-- Overwrite disarmtrap.executeAbility. Changes at "CBF:"
	executeAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		local oldFacing = abilityOwner:getFacing()

		-- CBF: custom recheckAllAiming only resets ambush/overwatch if it's no longer available.
		if userUnit.recheckAllAiming then
			userUnit:recheckAllAiming()
		else
			-- This shouldn't happen
			simlog("CBF: unit did not define recheckAllAiming. Falling back to resetAllAiming. %s [%d]", userUnit:getName(), userUnit:getID())
			userUnit:resetAllAiming()
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

