-- patch to sim/abilities/prime_emp.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local inventory = include( "sim/inventory" )
local simdefs = include( "sim/simdefs" )
local simfactory = include( "sim/simfactory" )
local unitdefs = include( "sim/unitdefs" )

local oldPrimeEmp = abilitydefs.lookupAbility("prime_emp")

local prime_emp = util.extend(oldPrimeEmp)
{
	-- Overwrite prime_emp.executeAbility. Changes at "CBF:"
	executeAbility = function( self, sim, unit, userUnit )
		local cell = sim:getCell( unit:getLocation() ) or sim:getCell( userUnit:getLocation() )
		local newUnit = simfactory.createUnit( unitdefs.lookupTemplate( unit:getUnitData().id ), sim )
		sim:dispatchEvent( simdefs.EV_UNIT_PICKUP, { unitID = userUnit:getID() } )

		sim:spawnUnit( newUnit )
		sim:warpUnit( newUnit, cell )
		newUnit:removeAbility(sim, "carryable")

		sim:emitSound( simdefs.SOUND_ITEM_PUTDOWN, cell.x, cell.y, userUnit)
		sim:emitSound( simdefs.SOUND_PRIME_EMP, cell.x, cell.y, userUnit)

		newUnit:getTraits().primed = true

		if newUnit:getTraits().trigger_mainframe then
			newUnit:getTraits().mainframe_item = true
			newUnit:getTraits().mainframe_status = "on"
			newUnit:setPlayerOwner( userUnit:getPlayerOwner() )
		end

		-- CBF: custom recheckAllAiming only resets ambush/overwatch if it's no longer available.
		if userUnit.recheckAllAiming then
			userUnit:recheckAllAiming()
		else
			-- This shouldn't happen
			simlog("CBF: unit did not define recheckAllAiming. Falling back to resetAllAiming. %s [%d]", userUnit:getName(), userUnit:getID())
			userUnit:resetAllAiming()
		end

		inventory.useItem( sim, userUnit, unit )

		if userUnit:isValid() then
			sim:dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = userUnit  } )
		end
	end,
}
return prime_emp

