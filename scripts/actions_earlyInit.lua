local actions = include("sim/btree/actions")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")

local oldCheckLookaround, idx, subFn = upvalueUtil.find(actions.DoLookAround, "checkLookaround", 5)
if idx then
	local function checkLookaround(sim, unit, delta, ...)
		if unit:getTraits().no_look_around or unit:getTraits().lookaroundRange then
			return oldCheckLookaround(sim, unit, delta, ...)
		end

		local x0, y0 = unit:getLocation()
		local dir = unit:getFacing()
		local probeCells = {}

		local cell = sim:getCell(x0, y0)
		if dir % 2 == 0 then
			-- start from diagonal instead of the tile directly in front of us that we can see anyway
			-- that way we get to ignore cover on the diagonal tile
			local dx, dy = simquery.getDeltaFromDirection(simquery.addFacing(dir, delta))
			local facing = simquery.addFacing(dir, delta * 2)
			if
				simquery.isOpenExit(cell.exits[dir]) and simquery.isOpenExit(cell.exits[dir].cell.exits[facing])
				or simquery.isOpenExit(cell.exits[facing])
					and simquery.isOpenExit(cell.exits[facing].cell.exits[dir])
			then
				probeCells = sim:getLOS():probeLOS(x0 + dx, y0 + dy, facing, unit:getTraits().LOSrange)
				-- I don't think there is a need to ever peek forward, it's weird
				-- the guard is mostly looking left and right while leaning forward,
				-- and not tilting their head a little bit to the left/right to look forward 
				-- local dx, dy = simquery.getDeltaFromDirection( facing )
				-- probeCells = sim:getLOS():probeLOS(x0 + dx, y0 + dy, dir, unit:getTraits().LOSrange)
			end
		else
			local dx, dy = simquery.getDeltaFromDirection(dir)
			if simquery.isConnected(sim, cell, sim:getCell(x0 + dx, y0 + dy)) then
				local facing = simquery.addFacing(dir, delta)
				probeCells = sim:getLOS():probeLOS(x0 + dx, y0 + dy, facing, unit:getTraits().LOSrange)
			end
		end

		-- we never have a lookaroundRange in this case but maybe some mod is tracking lookarounds with this idk
		if sim:isVersion("0.17.9") then
			sim:dispatchEvent(
				simdefs.EV_PULSE_SCAN,
				{ unit = unit, cells = probeCells, range = unit:getTraits().lookaroundRange }
			)
		end

		for _, cell in ipairs(probeCells) do
			for _, targetUnit in ipairs(cell.units) do
				if
					simquery.isEnemyAgent(unit:getPlayerOwner(), targetUnit)
					and simquery.couldUnitSee(sim, unit, targetUnit, true)
					and not sim:canUnitSeeUnit(unit, targetUnit)
				then
					unit:getBrain()
						:getSenses()
						:addInterest(cell.x, cell.y, simdefs.SENSE_PERIPHERAL, simdefs.REASON_NOTICED, targetUnit)
				end
			end
		end
		return probeCells
	end
	debug.setupvalue(subFn, idx, checkLookaround)
end
