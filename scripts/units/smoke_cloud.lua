-- patch to sim/units/smoke_cloud
local util = include("modules/util")
local array = include("modules/array")
local simunit = include("sim/simunit")
local prop_templates = include("sim/unitdefs/propdefs")
local simquery = include("sim/simquery")
local simdefs = include("sim/simdefs")
local simfactory = include("sim/simfactory")

local smoke_cloud = include("sim/units/smoke_cloud")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- ===
-- Copy vanilla helper functions for onWarp. Changes at CBF:

local function createSmokeEdge(sim, cell)
    local unit = simfactory.createUnit(prop_templates.cbf_smoke_edge, sim)
    sim:spawnUnit(unit)
    unit:setSmokeLocation(cell) -- CBF: Smoke will move into this cell after cloud registration.
    return unit
end

local function occludeSight(self, sim, targetCell, smokeRadius)
    local cells = simquery.floodFill(
            sim, nil, targetCell, smokeRadius, simquery.getManhattanMoveCost,
            simquery.canPathBetween)
    local segments, interestUnits = {}, {}
    local los = sim:getLOS()
    for _, cell in ipairs(cells) do
        for _, dir in ipairs(simdefs.DIR_SIDES) do
            local dx, dy = simquery.getDeltaFromDirection(dir)
            local tocell = sim:getCell(cell.x + dx, cell.y + dy)
            if tocell and array.find(cells, tocell) == nil then
                table.insert(segments, tocell)
                table.insert(segments, simquery.getReverseDirection(dir))
                -- CBF: Spawn an interest-source or register with an existing one.
                local interestUnit = tocell.cbfSmokeEdgeID and sim:getUnit(tocell.cbfSmokeEdgeID)
                if not interestUnit then
                    -- Spawn an interest point here.
                    interestUnit = createSmokeEdge(sim, tocell)
                end
                interestUnit:registerSmokeCloud(sim, self, cells)
                table.insert(interestUnits, interestUnit:getID())
            end
            table.insert(segments, cell)
            table.insert(segments, dir)
        end
        -- CBF: register cloud on this cell for 'smoke investigated' checks.
        if cell.cbfSmokeCloudIDs then
            table.insert(cell.cbfSmokeCloudIDs, self:getID())
        else
            cell.cbfSmokeCloudIDs = {self:getID()}
        end
    end

    sim:getLOS():insertSegments(unpack(segments))

    -- Not sure if there's a way around this, must refresh sight for everyone.
    for i, unit in pairs(sim:getAllUnits()) do
        sim:refreshUnitLOS(unit)
    end
    sim:dispatchEvent(simdefs.EV_EXIT_MODIFIED) -- Update shadow map.

    return cells, segments, interestUnits
end

-- ===

-- Overwrite vanilla onWarp. Changes at CBF.
local oldOnWarp = smoke_cloud.onWarp
function smoke_cloud:onWarp(sim, oldcell, cell)
    if not cbf_util.simCheckFlag(sim, "cbf_smoke_dynamicedges") then
        return oldOnWarp(self, sim, oldcell, cell)
    end

    if self._cells then
        -- CBF: Clear cell registrations.
        for _, cell in ipairs(self._cells) do
            if cell.cbfSmokeCloudIDs then
                array.removeElement(cell.cbfSmokeCloudIDs, self:getID())
            end
        end
        self._cells = nil
    end
    if self._segments then
        sim:getLOS():removeSegments(unpack(self._segments))
        self._segments = nil
        for i, unit in pairs(sim:getAllUnits()) do
            sim:refreshUnitLOS(unit)
        end
        sim:dispatchEvent(simdefs.EV_EXIT_MODIFIED) -- Update shadow map.
    end
    if self._interestUnits then
        -- CBF: reference-counted removal.
        for i, unitID in ipairs(self._interestUnits) do
            local unit = sim:getUnit(unitID)
            if unit then
                unit:unregisterSmokeCloud(sim, self) -- Will despawn the unit if no more clouds.
            end
        end
        self._interestUnits = nil
    end
    if cell then
        self._cells, self._segments, self._interestUnits = occludeSight(
                self, sim, cell, self:getTraits().radius)
        for i, cell in ipairs(self._cells) do
            for i, unit in ipairs(cell.units) do
                if unit:getBrain() and unit:getTraits().hasSight then
                    unit:getBrain():getSenses():addInterest(
                            cell.x, cell.y, simdefs.SENSE_SIGHT, simdefs.REASON_SMOKE)
                end
            end
        end
        sim:dispatchEvent(simdefs.EV_UNIT_REFRESH, {unit = self})
    end
end

-- Like simunit:setInvestigated/:getInvestigated, but always keep track of investigator units.
-- The vanilla flag's behavior of "after investigated once, new guards ignore it" would be a drastic
-- change for smoke clouds.
function smoke_cloud:setSmokeInvestigated(unit)
    assert(unit)
    if not self:getTraits().smokeInvestigated then
        self:getTraits().smokeInvestigated = {[unit:getID()] = true}
    else
        self:getTraits().smokeInvestigated[unit:getID()] = true
    end
end

function smoke_cloud:hasBeenSmokeInvestigated(unit)
    if unit and self:getTraits().smokeInvestigated then
        return self:getTraits().smokeInvestigated[unit:getID()]
    end
end
