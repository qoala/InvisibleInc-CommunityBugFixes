-- patch to sim/abilities/scandevice.lua
local array = include("modules/array")
local abilitydefs = include("sim/abilitydefs")
local abilityutil = include("sim/abilities/abilityutil")
local simquery = include("sim/simquery")

local abil = abilitydefs.lookupAbility("scandevice")

local oldAcquireTargets = abil.acquireTargets
function abil:acquireTargets(targets, game, sim, unit, ...)
    local unitTargets = oldAcquireTargets(self, targets, game, sim, unit, ...)

    -- Find directions blocked by a closed door.
    local foundBadExit = false
    local badExits = {}
    local userUnit = simquery.isAgent(unit) and unit or unit:getUnitOwner()
    local cell = sim:getCell(userUnit:getLocation())
    for dir, exit in pairs(cell.exits) do
        if not simquery.isOpenExit(exit) then
            foundBadExit = true
            badExits[exit.cell.id] = true
        end
    end

    if foundBadExit then
        -- Remove targets on the far side of the closed doors.
        local units = unitTargets._units
        array.removeIf(
                units, function(u)
                    local x, y = u:getLocation()
                    return x and badExits[simquery.toCellID(x, y)]
                end)
    end
    return unitTargets
end

local oldCanUseAbility = abil.canUseAbility
function abil:canUseAbility(sim, unit, ...)
    local result, reason = oldCanUseAbility(self, sim, unit, ...)

    if not result or sim:getHideDaemons() then
        return result, reason
    end

    -- Double-check "has a target in range" to exclude targets behind closed doors.
    local userUnit = simquery.isAgent(unit) and unit or unit:getUnitOwner()
    local cell = sim:getCell(userUnit:getLocation())
    for dir, exit in pairs(cell.exits) do
        if simquery.isOpenExit(exit) then
            local unit = array.findIf(
                    exit.cell.units, function(u)
                        return u:getTraits().mainframe_program
                    end)
            if unit then
                -- Found a target. Good to go.
                return result, reason
            end
        end
    end
    -- No target.
    return false, STRINGS.UI.REASON.NO_DAEMONS
end
