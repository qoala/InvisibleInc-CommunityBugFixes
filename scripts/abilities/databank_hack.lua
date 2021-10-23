-- patch to sim/abilities/activate_locked_console.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local abilityutil = include( "sim/abilities/abilityutil" )
local simquery = include( "sim/simquery" )

local oldDatabankHack = abilitydefs.lookupAbility("databank_hack")

local databank_hack = util.extend(oldDatabankHack or {})
{
	-- Overwrite canUseAbility. Changes at "CBF:"
	canUseAbility = function( self, sim, abilityOwner, unit, targetUnitID )
		local targetUnit = sim:getUnit( targetUnitID )
		local userUnit = abilityOwner:getUnitOwner()

		if abilityOwner:getTraits().mainframe_status ~= "active" then
			return false
		end

		if sim:isVersion("0.17.11") and unit:getTraits().isDrone then
			return false
		end

		if abilityOwner:getTraits().cooldown and abilityOwner:getTraits().cooldown > 0 then
			return false,  util.sformat(STRINGS.UI.REASON.COOLDOWN,abilityOwner:getTraits().cooldown)
		end
		if abilityOwner:getTraits().usesCharges and abilityOwner:getTraits().charges < 1 then
			return false, util.sformat(STRINGS.UI.REASON.CHARGES)
		end


		if unit:getTraits().data_hacking or abilityOwner:getTraits().hacker then
			return false, STRINGS.UI.REASON.ALREADY_HACKING
		end

		-- CBF: Check player owner instead of firewalls. Don't lock out if Rubiks boosted firewalls after hacking.
		if abilityOwner:getPlayerOwner() ~= sim:getPC() then
			return false, STRINGS.ABILITIES.TOOLTIPS.UNLOCK_WITH_INCOGNITA
		end

		if not simquery.canUnitReach( sim, unit, abilityOwner:getLocation() ) then
			return false
		end

		return abilityutil.checkRequirements( abilityOwner, userUnit )
	end,
}
return databank_hack
