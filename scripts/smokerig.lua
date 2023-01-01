-- patch to client/gameplay/smokerig
local array = include("modules/array")

local smokerig = include("gameplay/smokerig").rig

-- ===
-- Copy vanilla helper functions for refresh. No changes.

local function createSmokeFx(rig, kanim, x, y)
    local fxmgr = rig._boardRig._game.fxmgr
    x, y = rig._boardRig:cellToWorld(x, y)

    local args = {
        x = x,
        y = y,
        kanim = kanim,
        symbol = "effect",
        anim = "loop",
        scale = 0.1,
        loop = true,
        layer = rig._boardRig:getLayer(),
    }

    return fxmgr:addAnimFx(args)
end

-- ===

-- Overwrite :refresh()
-- Changes at CBF:
function smokerig:refresh()
    self:_base().refresh(self)

    -- Smoke aint got no ghosting behaviour.
    local unit = self:getUnit()
    local cloudID = unit:getID()
    local cells = unit:getSmokeCells() or {}
    for i, cell in ipairs(cells) do
        if self.smokeFx[cell] == nil then
            local fx = createSmokeFx(self, "fx/smoke_grenade", cell.x, cell.y)
            fx._prop:setFrame(math.random(1, fx._prop:getFrameCount()))
            self.smokeFx[cell] = fx
            if self:getUnit():getTraits().gasColor then
                local color = self:getUnit():getTraits().gasColor
                fx._prop:setColor(color.r, color.g, color.b, 1)
                fx._prop:setSymbolModulate("smoke_particles_lt0", color.r, color.g, color.b, 1)
            end
        end
    end
    local edgeUnits = unit:getSmokeEdge() or {}
    local activeEdgeUnits = {}
    for i, unitID in ipairs(edgeUnits) do
        -- CBF: Only draw active smoke edges if we're using CBF dynamic smoke edges.
        local edgeUnit = self._boardRig:getSim():getUnit(unitID)
        if edgeUnit and
                (not edgeUnit.isActiveForSmokeCloud or edgeUnit:isActiveForSmokeCloud(cloudID)) then
            activeEdgeUnits[unitID] = true
            if self.smokeFx[unitID] == nil then
                local fx = createSmokeFx(self, "fx/smoke_grenade_test2", edgeUnit:getLocation())
                fx._prop:setFrame(math.random(1, fx._prop:getFrameCount()))
                self.smokeFx[unitID] = fx
                if self:getUnit():getTraits().gasColor then
                    local color = self:getUnit():getTraits().gasColor
                    fx._prop:setColor(color.r, color.g, color.b, 1)
                    fx._prop:setSymbolModulate("smoke_particles_lt0", color.r, color.g, color.b, 1)
                end
            end
        end
    end

    -- Remove any smoke that no longer exists.
    for k, fx in pairs(self.smokeFx) do
        if array.find(cells, k) == nil and array.find(activeEdgeUnits, k) == nil then
            fx:postLoop("pst")
        end
    end

    local gfxOptions = self._boardRig._game:getGfxOptions()
    for cell, fx in pairs(self.smokeFx) do
        fx._prop:setVisible(not gfxOptions.bMainframeMode)
    end
end
