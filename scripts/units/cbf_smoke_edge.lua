-- New unit type for CBF
local util = include("modules/util")
local array = include("modules/array")
local unitdefs = include("sim/unitdefs")
local simunit = include("sim/simunit")
local simdrone = include("sim/units/simdrone")
local simcamera = include("sim/units/simcamera")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local simfactory = include("sim/simfactory")

-- ===

local smoke_edge = {ClassType = "cbf_smoke_edge"}

function smoke_edge:_updateCloudState(sim)
    local cell = sim:getCell(self._smokeX, self._smokeY)

    -- Check for connectivity between edge and its cloud(s).
    local hasActiveCloud = false
    for _, cloud in ipairs(self._clouds) do
        self._activeClouds[cloud.id] = false
        for _, dir in ipairs(cloud.dirs) do
            local exit = cell.exits[dir]
            if simquery.isOpenExit(exit) then
                hasActiveCloud = true
                self._activeClouds[cloud.id] = true
                break
            end
        end
    end

    local onMap = self:getLocation() ~= nil
    if hasActiveCloud and not onMap then
        sim:warpUnit(self, cell)
    elseif onMap and not hasActiveCloud then
        sim:warpUnit(self, nil)
    end
end

-- ===
-- Interface methods

function smoke_edge:onSpawn(sim)
    sim:addTrigger(simdefs.TRG_UNIT_WARP_PRE, self)
    sim:addTrigger(simdefs.TRG_UNIT_USEDOOR_PRE, self)
    sim:addTrigger(simdefs.TRG_UNIT_USEDOOR, self)
end

function smoke_edge:onDespawn(sim)
    sim:removeTrigger(simdefs.TRG_UNIT_WARP_PRE, self)

    if self._smokeX then
        local cell = sim:getCell(self._smokeX, self._smokeY)
        if cell and cell.cbfSmokeEdgeID == self:getID() then
            cell.cbfSmokeEdgeID = nil
        end
    end
end

function smoke_edge:onTrigger(sim, evType, evData)
    if evType == simdefs.TRG_UNIT_WARP_PRE then
        if evData.unit == self and evData.to_cell and
                (evData.to_cell.x ~= self._smokeX or evData.to_cell.y ~= self._smokeY) then
            -- Reject attempts to warp anywhere except our pre-defined location and nil.
            simlog(
                    "[CBF] smokeEdge:warp attempted to unexpected cell %s,%s instead of defined %s,%s",
                    tostring(evData.to_cell.x), tostring(evData.to_cell.y), tostring(self._smokeX),
                    tostring(self._smokeY))
            self:getTraits().interrupted = true
        end
    elseif evType == simdefs.TRG_UNIT_USEDOOR_PRE then
        -- Maybe hide before LOS-update when closing a door between us and the cloud
        local x, y = self._smokeX, self._smokeY
        if self:getLocation() and
                ((evData.cell.x == x and evData.cell.y == y) or
                        (evData.tocell.x == x and evData.tocell.y == y)) then
            self:_updateCloudState(sim)
        end
    elseif evType == simdefs.TRG_UNIT_USEDOOR then
        -- Maybe reveal after LOS-update when opening a door between us and the cloud
        local x, y = self._smokeX, self._smokeY
        if not self:getLocation() and
                ((evData.cell.x == x and evData.cell.y == y) or
                        (evData.tocell.x == x and evData.tocell.y == y)) then
            self:_updateCloudState(sim)
        end
    end
end

function smoke_edge:setInvestigated(unit, ...)
    simunit.setInvestigated(self, unit, ...)

    -- Also mark our clouds as investigated
    for _, cloud in ipairs(self:getActiveSmokeClouds(self._sim)) do
        cloud:setSmokeInvestigated(unit)
    end
end

-- ===
-- Public methods

function smoke_edge:setSmokeLocation(cell)
    assert(cell.cbfSmokeEdgeID == nil, tostring(cell.x) .. "," .. tostring(cell.y))
    cell.cbfSmokeEdgeID = self:getID()
    self._smokeX, self._smokeY = cell.x, cell.y
end

function smoke_edge:registerSmokeCloud(sim, cloudUnit, cloudCells)
    -- Adjacent directions from this edge into the cloud's cells.
    local dirs = {}

    local x, y = self._smokeX, self._smokeY
    local adjacencies = {}
    for _, dir in ipairs(simdefs.DIR_SIDES) do
        local dx, dy = simquery.getDeltaFromDirection(dir)
        adjacencies[simquery.toCellID(x + dx, y + dy)] = dir
    end
    for _, cell in ipairs(cloudCells) do
        local dir = adjacencies[simquery.toCellID(cell.x, cell.y)]
        if dir then
            table.insert(dirs, dir)
        end
    end

    self._clouds = self._clouds or {}
    self._activeClouds = self._activeClouds or {}
    table.insert(self._clouds, {id = cloudUnit:getID(), dirs = dirs})
    self:_updateCloudState(sim)
end

function smoke_edge:unregisterSmokeCloud(sim, cloudUnit)
    if self._clouds then
        local id = cloudUnit:getID()
        array.removeIf(
                self._clouds, function(c)
                    return c.id == id
                end)
        if #self._clouds == 0 then
            if self:getLocation() then
                sim:warpUnit(self, nil)
            end
            sim:despawnUnit(self)
        else
            self._activeClouds[id] = nil
            self:_updateCloudState(sim)
        end
    end
end

function smoke_edge:getActiveSmokeClouds(sim)
    local clouds = {}
    for cloudID, _ in pairs(self._activeClouds) do
        local cloudUnit = sim:getUnit(cloudID)
        if cloudUnit then
            table.insert(clouds, cloudUnit)
        end
    end
    return clouds
end
function smoke_edge:isActiveForSmokeCloud(cloudID)
    return self._activeClouds and self._activeClouds[cloudID]
end

-- ===

local function createSmokeEdge(unitData, sim)
    return simunit.createUnit(unitData, sim, smoke_edge)
end

simfactory.register(createSmokeEdge)

return smoke_edge
