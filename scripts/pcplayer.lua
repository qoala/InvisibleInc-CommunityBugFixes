-- patch to sim/pcplayer

local array = include( "modules/array" )
local pcplayer = include( "sim/pcplayer" )
local util = include("modules/util")

local oldReserveUnits = pcplayer.reserveUnits

function pcplayer:reserveUnits( agentDefs )
	-- Check for double-reserving the same agent. In case mid1 added monst3r, but monst3r was in the detention pool.
	-- doReserveAction reserves deployed agents before the detention pool, so keep the first-reserved version.
	local hasDoubleReservedMonst3r = false
	for i,agentDef in ipairs( agentDefs ) do
		if self._deployed[ agentDef.id ] and (agentDef.id == 100) then
			hasDoubleReservedMonst3r = true
		end
	end
	
	if hasDoubleReservedMonst3r  then
		local dedupedAgentDefs = array.copy( agentDefs )
		array.removeIf( dedupedAgentDefs, function ( adef ) return adef.id == 100 end )
		oldReserveUnits( self, dedupedAgentDefs )
	else
		oldReserveUnits( self, agentDefs )
	end
end
