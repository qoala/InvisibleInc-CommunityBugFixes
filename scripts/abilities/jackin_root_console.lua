-- patch to sim/abilities/jackin_root_console.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )

local oldJackinRootConsole = abilitydefs.lookupAbility("jackin_root_console")
local oldIsTarget = oldJackinRootConsole.isTarget

local jackin_root_console = util.extend(oldJackinRootConsole)
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
return jackin_root_console
