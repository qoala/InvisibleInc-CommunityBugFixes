-- patch to sim/engine

local array = include("modules/array")
local simdefs = include("sim/simdefs")
local simengine = include("sim/engine")

-- -----
-- Prefab stationary guard facing fix
-- -----

local oldInit = simengine.init

function simengine:init( ... )
	oldInit( self, ... )

	if self:getParams().difficultyOptions.cbf_nopatrol_fixfacing then
		for i,unit in pairs( self:getAllUnits() ) do
			if unit:getTraits().nopatrol then
				unit:getTraits().patrolPath[1].facing = unit:getFacing()
			end
		end
	end
end

-- -----
-- END Prefab stationary guard facing fix
-- -----

-- -----
-- Pathing: moving interest fix
-- -----

-- New 'pathing queue', modelled after the existing 'tracker queue' (alarm updates) and 'daemon queue' (plastech modded guards).
-- Delay various updates until after a sequence has completed.
-- This queue additionally dedupes inserted requests. If the same unit updates its path multiple times, only the final update is performed.
-- (Reduces the processing load when sprinting past many guards.)
function simengine:cbfStartPathingQueue()
	-- assert( not self._cbfPathingQueue )  -- If an error is thrown, the queue might not be closed. Vanilla queues restart with a new queue state in this case.
	self._cbfPathingQueue = {}
end

function simengine:cbfProcessPathingQueue()
	local queue = self._cbfPathingQueue
	self._cbfPathingQueue = nil

	if queue and #queue > 0 then
		simlog( simdefs.LOG_AI, "Processing Queued Path Updates" )
		-- Loosely re-perform aiplayer:tickAllBrains, in order of final pathing update.
		for i, data in ipairs(queue) do
			local unit = data.unit
			if unit:isValid() and not unit:isDown() then
				-- force think. Overriding the original path.
				simlog( simdefs.LOG_AI, "[%s] Queued Path Update", tostring(unit:getID() ))
				unit:getBrain():reset()
				unit:getBrain():think()
			end
		end

		local aiPlayer = self:getNPC()
		-- (Rest of this is from aiplayer:tickAllBrains)

		--reactions
		for _,unit in pairs(aiPlayer:getPrioritisedUnits() ) do
			if unit:getBrain() and unit:getBrain():getSenses():shouldUpdate() then

				simlog( simdefs.LOG_AI, "[%s] Reaction Double-Thinking", tostring(unit:getID() ))
				aiPlayer:tickBrain(unit)
			end
		end

		if not aiPlayer:getCurrentAgent() then
			aiPlayer:prioritiseUnits()
		end
	end
end

function simengine:cbfHasPathingQueue()
	return self._cbfPathingQueue ~= nil
end

function simengine:cbfAddToPathingQueue( unit )
	assert( unit and unit:isValid() )
	local unitID = unit:getID()
	-- Only the last pathing update will matter
	array.removeIf( self._cbfPathingQueue, function( data ) return data.unitID == unitID end )
	table.insert( self._cbfPathingQueue, {unitID=unitID, unit=unit} )
end

local oldMoveUnit = simengine.moveUnit

function simengine:moveUnit( unit, moveTable, ... )
	local pathingOption = self:getParams().difficultyOptions.cbf_pathing
	local usePathingQueue = pathingOption and pathingOption.use_pathing_queue and self:getCurrentPlayer():isPC()
	if usePathingQueue then
		self:cbfStartPathingQueue()
	end

	local canMoveReason, end_cell = oldMoveUnit( self, unit, moveTable, ... )

	if usePathingQueue then
		self:cbfProcessPathingQueue()
	end

	return canMoveReason, end_cell
end

-- -----
-- END Pathing: moving interest fix
-- -----
