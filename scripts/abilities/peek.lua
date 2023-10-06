-- patch to sim/abilities/carryable.lua
local util = include("modules/util")
local abilitydefs = include("sim/abilitydefs")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local speechdefs = include("sim/speechdefs")

local oldPeek = abilitydefs.lookupAbility("peek")

local peek = util.extend(oldPeek) {
    -- Overwrite peek.executeAbility. Changes at "CBF:"
    executeAbility = function(self, sim, unit, userUnit, exitX, exitY, exitDir)

        local x0, y0 = unit:getLocation()
        local fromCell = sim:getCell(x0, y0)

        self:removePeek(sim)

        sim:emitSpeech(unit, speechdefs.EVENT_PEEK)
        -- unit:setAiming( false )
        sim:emitSound(simdefs.SOUND_PEEK, x0, y0, nil)
        unit:useMP(simdefs.DEFAULT_COST, sim)

        -- Any door peeks?
        local peekInfo = {x0 = x0, y0 = y0, cellvizCount = 0}
        if exitX and exitY and exitDir then
            local exitCell = sim:getCell(exitX, exitY)
            if exitCell then
                peekInfo.preferredExit = exitCell.exits[exitDir]
            end
        end

        for i = 1, #simdefs.ADJACENT_EXITS, 3 do
            local dx, dy, dir = simdefs.ADJACENT_EXITS[i], simdefs.ADJACENT_EXITS[i + 1],
                                simdefs.ADJACENT_EXITS[i + 2]
            local cell = sim:getCell(fromCell.x + dx, fromCell.y + dy)
            if (dx == 0 and dy == 0) or
                    simquery.isOpenExit(fromCell.exits[simquery.getDirectionFromDelta(dx, dy)]) then
                local exit = cell and cell.exits[dir]
                if exit and exit.door and exit.keybits ~= simdefs.DOOR_KEYS.ELEVATOR and
                        exit.keybits ~= simdefs.DOOR_KEYS.GUARD then
                    local peekDx, peekDy = simquery.getDeltaFromDirection(dir)
                    self:doPeek(
                            unit, not exit.closed, sim, cell.x, cell.y, peekInfo, peekDx, peekDy,
                            exit)
                end
            end
        end

        -- CBF: Track which diagonals failed, to try peeking orthogonally as well.
        -- N: +y
        -- E: +x
        -- W: -x
        -- S: -y
        local tryPeekE, tryPeekN, tryPeekW, tryPeekS = false, false, false, false

        if self:canPeek(sim, fromCell, 1, 1) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, 1, 1)
        else
            tryPeekN, tryPeekE = true, true
        end
        if self:canPeek(sim, fromCell, -1, 1) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, -1, 1)
        else
            tryPeekN, tryPeekW = true, true
        end
        if self:canPeek(sim, fromCell, 1, -1) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, 1, -1)
        else
            tryPeekS, tryPeekE = true, true
        end
        if self:canPeek(sim, fromCell, -1, -1) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, -1, -1)
        else
            tryPeekS, tryPeekW = true, true
        end

        if tryPeekN and self:canPeekOrthogonal(sim, fromCell, 0, 1) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, 0, 1)
        end
        if tryPeekE and self:canPeekOrthogonal(sim, fromCell, 1, 0) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, 1, 0)
        end
        if tryPeekW and self:canPeekOrthogonal(sim, fromCell, -1, 0) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, -1, 0)
        end
        if tryPeekS and self:canPeekOrthogonal(sim, fromCell, 0, -1) then
            self:doPeek(unit, true, sim, x0, y0, peekInfo, 0, -1)
        end

        sim:dispatchEvent(simdefs.EV_UNIT_PEEK, {unitID = unit:getID(), peekInfo = peekInfo})

        -- Add trigger for eyeball removal (notably, before processReactions)
        sim:addTrigger(simdefs.TRG_UNIT_WARP, self, unit)
        sim:addTrigger(simdefs.TRG_UNIT_KO, self, unit)

        sim:processReactions(unit)
    end,

    -- Copy of peek.canPeek, but modified to handle orthogonal directions.
    canPeekOrthogonal = function(self, sim, fromCell, dx, dy)
        if sim:getCell(fromCell.x + dx, fromCell.y + dy) == nil then
            return false
        end

        if math.abs(dx) == math.abs(dy) then
            return false -- Can only peek to orthogonal cells with this.
        end

        local testCell = sim:getCell(fromCell.x + dx, fromCell.y + dy)
        local facing = simquery.getDirectionFromDelta(-dx, -dy)
        local exit = testCell.exits[facing]

        return exit and not (exit.door and exit.closed)
    end,
}
return peek
