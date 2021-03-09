-- patch to sim/simplayer

local util = include( "modules/util" )
local simplayer = include( "sim/simplayer" )
local aiplayer = include( "sim/simplayer" )
local pcplayer = include( "sim/pcplayer" )

local oldOnStartTurn = simplayer.onStartTurn

-- Overwrite simplayer:onStartTurn. Changes at "CBF:"
function simplayer:onStartTurn( sim, ... )
	local fixCycleTiming = sim:getParams().difficultyOptions.cbf_cycletiming
	if fixCycleTiming then
		-- CBF: Move this clause before all unit:onStartTurn calls, instead of after.
		--   Laptops, Distributed Processing, etc generate start of turn power during this call instead of as a TRG_START_TURN handler.
		if sim:getTags().clearPWREachTurn then
			self:addCPUs( -self:getCpus( ), sim )
		end

		local units = util.tdupe( self._units )
		for i,unit in ipairs( units ) do
			if unit:isValid() then
				unit:onStartTurn( sim )
			end
		end
	else
		oldOnStartTurn( self, sim, ... )
	end
end

-- Update known subclasses of simplayer (subclasses that don't use the class factory don't see changes in their base class)
if aiplayer.onStartTurn == oldOnStartTurn then
	log:write("CBF DEBUG: replicating onStartTurn patch to aiplayer")
	aiplayer.onStartTurn = simplayer.onStartTurn
end
if pcplayer.onStartTurn == oldOnStartTurn then
	log:write("CBF DEBUG: replicating onStartTurn patch to pcplayer")
	pcplayer.onStartTurn = simplayer.onStartTurn
end
