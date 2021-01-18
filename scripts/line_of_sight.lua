-- patch to sim/line_of_sight

local line_of_sight = include("sim/line_of_sight")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")

local oldCalculateUnitLos = line_of_sight.calculateUnitLOS

function line_of_sight:calculateUnitLOS( start_cell, unit, ... )
	local cells = oldCalculateUnitLos( self, start_cell, unit, ... )

	local fixmagicsight = self.sim:getParams().difficultyOptions.cbf_fixmagicsight
	local facing = unit:getFacing()
	-- If unit has AGP's ignoreWalls trait, assume vision was handled correctly.
	if fixmagicsight and unit:getTraits().LOSrads == nil and facing % 2 == 1 and not unit:getTraits().ignoreWalls then
		-- MAGICAL SIGHT. On a diagonal facing, units see the adjacent two cells.
		-- Suppress this vision if the unit can't see the cell regardless of facing. Possible causes:
		-- (1) the unit has less than 1 tile of vision range (pulse drone)
		-- (2) the cell is visually blocked (smoke)
		local exit1 = start_cell.exits[ (facing + 1) % simdefs.DIR_MAX ]
		local exit2 = start_cell.exits[ (facing - 1) % simdefs.DIR_MAX ]
		if exit1 and cells[exit1.cell.id] and not simquery.couldUnitSeeCell( self.sim, unit, exit1.cell ) then
			cells[exit1.cell.id] = nil
		end
		if exit2 and cells[exit2.cell.id] and not simquery.couldUnitSeeCell( self.sim, unit, exit2.cell ) then
			cells[exit2.cell.id] = nil
		end
	end

	return cells
end
