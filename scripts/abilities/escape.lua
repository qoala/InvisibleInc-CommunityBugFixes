-- patch to sim/abilities/escape.lua

local util = include( "modules/util" )
local abilitydefs = include( "sim/abilitydefs" )
local unitdefs = include( "sim/unitdefs" )

local oldEscape = abilitydefs.lookupAbility("escape")
local oldCanUseAbility = oldEscape.canUseAbility

local escape = util.extend(oldEscape)
{
	canUseAbility = function( self, sim, unit )
		local res, reason = oldCanUseAbility( self, sim, unit )

		-- Modified copy of the vanilla loop for checking exit_reqiuired_item "escaping now would immediately lose the game".
		-- Changes at "CBF:"
		if res and sim:hasTag( "exit_reqiuired_item" ) and not sim:getPC():getEscapedWithObjective() then
			-- CBF: Instead of tracking "all agents" and "agents escaping", track "active agents remaining in the mission".
			--      Make a distinction between the active agents and abandoned agents.
			local agentsRemaining = 0
			local hasItem = false
			for _, unit in pairs( sim:getAllUnits() ) do

				if unit:hasAbility( "escape" )	then
					local c = sim:getCell( unit:getLocation() )
					if c and c.exitID  then
						-- Agent is leaving

						for i,item in ipairs(unit:getChildren())do
							if item:getUnitData().id == sim:getTags().exit_reqiuired_item then
								hasItem = true
							end
						end
					elseif unit:isNeutralized() then
						-- CBF: Agent being abandoned
					else
						-- CBF: Active agent remaining
						agentsRemaining = agentsRemaining + 1
					end
				end
			end
			-- CBF: Replaced 'agents <= agentsLeaving' with 'agentsRemaining <= 0'.
			if agentsRemaining <= 0 and not hasItem then
				local name =  unitdefs.lookupTemplate( sim:getTags().exit_reqiuired_item ).name
				return false, util.sformat(STRINGS.UI.REASON.NEED_ITEM_TO_LEAVE,name)
			end
		end

		return res, reason
	end
}
return escape
