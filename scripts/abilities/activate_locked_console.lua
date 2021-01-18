-- patch to sim/abilities/activate_locked_console.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )

local oldActivateLockedConsole = abilitydefs.lookupAbility("activate_locked_console")
local oldIsTarget = oldActivateLockedConsole.isTarget

local activate_locked_console = util.extend(oldActivateLockedConsole)
{
	isTarget = function( self, abilityOwner, unit, targetUnit )
		local sim = abilityOwner:getSim()
		if sim:getParams().difficultyOptions.cbf_ending_remotehacking then
			if targetUnit ~= abilityOwner then
				return false
			end
		end
		return oldIsTarget( self, abilityOwner, unit, targetUnit )
	end
}
return activate_locked_console
