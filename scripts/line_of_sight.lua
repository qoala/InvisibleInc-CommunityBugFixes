-- patch to sim/line_of_sight
local line_of_sight = include("sim/line_of_sight")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local oldCalculateUnitLos = line_of_sight.calculateUnitLOS

function line_of_sight:calculateUnitLOS(start_cell, unit, ...)
    local cells = oldCalculateUnitLos(self, start_cell, unit, ...)

    local fixmagicsight = cbf_util.simCheckFlag(self.sim, "cbf_fixmagicsight")
    local facing = unit:getFacing()
    -- If unit has AGP's ignoreWalls trait, assume vision was handled correctly.
    if fixmagicsight and not unit:getTraits().ignoreWalls then
        if unit:getTraits().LOSrads == nil and facing % 2 == 1 and not unit:isPC() then
            -- MAGICAL SIGHT. On a diagonal facing, units see the adjacent two cells if not blocked by walls.
            -- Suppress this vision if the unit can't see the cell regardless of facing. Possible causes:
            -- (1) the unit has less than 1 tile of vision range (pulse drone)
            -- (2) the cell is visually blocked (smoke)
            local exit1 = start_cell.exits[(facing + 1) % simdefs.DIR_MAX]
            local exit2 = start_cell.exits[(facing - 1) % simdefs.DIR_MAX]
            if exit1 and cells[exit1.cell.id] and
                    not simquery.couldUnitSeeCell(self.sim, unit, exit1.cell) then
                cells[exit1.cell.id] = nil
            end
            if exit2 and cells[exit2.cell.id] and
                    not simquery.couldUnitSeeCell(self.sim, unit, exit2.cell) then
                cells[exit2.cell.id] = nil
            end
        elseif unit:getTraits().LOSarc and unit:getTraits().LOSarc >= 2 * math.pi and
                not unit:isPC() then
            -- MAGICAL SIGHT 2. Units with full 360 vision see all four adjacent cells if not blocked by walls.
            -- Intent: player units in smoke can see adjacent guards to steal/KO
            -- Suppress this vision for non-player units, so that certain modded guards don't unexpectedly see through smoke.
            for i, dir in ipairs(simdefs.DIR_SIDES) do
                local exit1 = start_cell.exits[dir]
                if exit1 and cells[exit1.cell.id] and
                        not simquery.couldUnitSeeCell(self.sim, unit, exit1.cell) then
                    cells[exit1.cell.id] = nil
                end
            end
        elseif unit:getTraits().LOSrads == nil and facing % 2 == 0 and not unit:isPC() then
            local exit = start_cell.exits[facing]
            if simquery.isOpenExit(exit) and simquery.couldUnitSeeCell(self.sim, unit, exit.cell) then
                cells[simquery.toCellID(exit.cell.x, exit.cell.y)] = exit.cell
            end
        elseif unit:getTraits().LOSarc and unit:getTraits().LOSarc >= 2 * math.pi and unit:isPC() and
                facing % 2 == 1 then
            -- Diagonal magic sight takes precedence over 360-vision magic sight.
            -- Apply full magic sight for player units with 360-vision that are facing diagonally.
            for i, dir in ipairs(simdefs.DIR_SIDES) do
                local exit1 = start_cell.exits[dir]
                if simquery.isOpenExit(exit1) then
                    cells[simquery.toCellID(exit1.cell.x, exit1.cell.y)] = exit1.cell
                end
            end
        end
    end

    return cells
end
