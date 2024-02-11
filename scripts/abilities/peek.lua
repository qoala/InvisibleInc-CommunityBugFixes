-- patch to sim/abilities/peek.lua
local abilitydefs = include("sim/abilitydefs")
local simquery = include("sim/simquery")

local function patchPeek()
    local peek = abilitydefs.lookupAbility("peek")

    local oldExecute = peek.executeAbility
    function peek:executeAbility(sim, unit, userUnit, exitX, exitY, exitDir, ...)
        local x0, y0 = unit:getLocation()

        oldExecute(self, sim, unit, userUnit, exitX, exitY, exitDir, ...)

        -- If became down or moved by processReactions, then the peek eyeballs would've despawned.
        if not unit or not unit:isValid() or unit:isDown() then
            return
        end
        local x1, y1 = unit:getLocation()
        if x0 ~= x1 or y0 ~= y1 then
            return
        end

        -- CBF: Track which diagonals fail, to try peeking orthogonally as well.
        -- N: +y
        -- E: +x
        -- W: -x
        -- S: -y
        local tryPeekE, tryPeekN, tryPeekW, tryPeekS = false, false, false, false
        local fromCell = sim:getCell(x0, y0)

        if not self:canPeek(sim, fromCell, 1, 1) then
            tryPeekN, tryPeekE = true, true
        end
        if not self:canPeek(sim, fromCell, -1, 1) then
            tryPeekN, tryPeekW = true, true
        end
        if not self:canPeek(sim, fromCell, 1, -1) then
            tryPeekS, tryPeekE = true, true
        end
        if not self:canPeek(sim, fromCell, -1, -1) then
            tryPeekS, tryPeekW = true, true
        end

        local peekInfo = {cellvizCount = 10000} -- No further info required.
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
    end

    -- Copy of peek.canPeek, but modified to handle orthogonal directions.
    function peek:canPeekOrthogonal(sim, fromCell, dx, dy)
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
    end
end

return { --
    patchPeek = patchPeek,
}
