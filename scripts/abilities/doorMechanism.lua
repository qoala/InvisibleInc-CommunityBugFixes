-- patch to sim/abilities/doorMechanism.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local inventory = include( "sim/inventory" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )

local oldDoorMechanism = abilitydefs.lookupAbility("doorMechanism")

local doorMechanism = util.extend(oldDoorMechanism)
{
	-- Overwrite doorMechanism.executeAbility. Changes at "CBF:"
	-- Includes patches from FunctionLibrary
	executeAbility = function( self, sim, unit, userUnit, x0, y0, dir )
		local fromCell = sim:getCell( x0, y0 )
		assert( fromCell and dir )

		-- CBF: custom recheckAllAiming only resets ambush/overwatch if it's no longer available.
		if userUnit.recheckAllAiming then
			userUnit:recheckAllAiming()
		else
			-- This shouldn't happen
			simlog("CBF: unit did not define recheckAllAiming. Falling back to resetAllAiming. %s [%d]", userUnit:getName(), userUnit:getID())
			userUnit:resetAllAiming()
		end

		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = userUnit:getID(), facing = dir } )
		-- Function Library: decodeVault support for NIAA
		local doorDevice = nil
		if unit:getTraits().decodeVault then
			doorDevice = include( SCRIPT_PATHS.W93_NIAA .. "/W93_lock_decoder" )
		else
			doorDevice = include( string.format( "sim/units/%s", unit:getTraits().doorDevice ))
		end
		doorDevice.applyToDoor( sim, fromCell, dir, unit, userUnit )
		inventory.useItem( sim, userUnit, unit )

		sim:emitSound( simdefs.SOUND_PLACE_TRAP, x0, y0, userUnit)	

		sim:processReactions( userUnit )
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = userUnit:getID(), facing = dir } )	
		-- Function Library: support for LEVER
		if simquery.LEVER_resetStatus then
			simquery.LEVER_resetStatus( sim, userUnit, "ANY", false )
		end
	end,
}
return doorMechanism
