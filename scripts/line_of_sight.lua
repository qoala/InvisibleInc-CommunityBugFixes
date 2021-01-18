-- patch to sim/line_of_sight

local line_of_sight = include("sim/line_of_sight")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")

local oldCalculateUnitLos = line_of_sight.calculateUnitLOS

function line_of_sight:calculateUnitLOS( start_cell, unit, ... )
	local cells = oldCalculateUnitLos( self, start_cell, unit, ... )

	local fixmagicsight = self.sim:getParams().difficultyOptions.cbf_fixmagicsight
	local facing = unit:getFacing()
	if fixmagicsight and unit:getTraits().LOSrads == nil and facing % 2 == 1 then
		-- MAGICAL SIGHT. On a diagonal facing, units see the adjacent two cells.
		-- Suppress this vision if the unit can't see the cell regardless of facing. Possible causes:
		-- (1) the unit has less than 1 tile of vision range (pulse drone)
		-- (2) the cell is visually blocked (smoke)
		local exit1cell = start_cell.exits[ (facing + 1) % simdefs.DIR_MAX ].cell
		local exit2cell = start_cell.exits[ (facing - 1) % simdefs.DIR_MAX ].cell
		if cells[exit1cell.id] and not (unit:getTraits().LOSrange == nil or unit:getTraits().LOSrange >= 1) then
			cells[exit1cell.id] = nil
		end
		if cells[exit2cell.id] and not (unit:getTraits().LOSrange == nil or unit:getTraits().LOSrange >= 1) then
			cells[exit2cell.id] = nil
		end
	end

	return cells
end
