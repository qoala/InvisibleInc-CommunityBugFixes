-- patch to sim/btree/situations/idle
local simquery = include("sim/simquery")
local mathutil = include("modules/mathutil")
local IdleSituation = include("sim/btree/situations/idle")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")
local constants = include(SCRIPT_PATHS.qoala_commbugfix .. "/constants")

local oldGeneratePatrolPath = IdleSituation.generatePatrolPath

local function isBrokenStationaryPath(patrolPath)
    -- If generatePatrolPath rejects all its candidates for the 2nd patrol node, it leaves only the
    -- initial position in the patrol path.
    return patrolPath and #patrolPath == 1 and not patrolPath[1].facing
end

local function findValidSecondPatrolCell(sim, unit, x0, y0)
    -- Simplified logic from the original generatePatrolPath with looser restrictions.
    -- Only applicable with beginnerPatrols disabled.
    -- * Removes "Non-beginner patrols must NOT start and end in the same ROOM." condition,
    --   usually broken when starting in a prefab with a large room and no exit within reach.
    -- * Always rejects patrols into starting room. If that limit was hit, don't make it worse.
    local cell0 = sim:getCell(x0, y0)
    local maxMP, maxRangeOnly = unit:getTraits().mpMax, true
    local cells = simquery.floodFill(
            sim, unit, cell0, maxMP, nil, simquery.canSoftPath, maxRangeOnly, sim)
    table.sort(
            cells, function(c1, c2)
                return mathutil.distSqr2d(x0, y0, c1.x, c1.y) >
                               mathutil.distSqr2d(x0, y0, c2.x, c2.y)
            end)
    for i, cell in ipairs(cells) do
        local isPatrolIntoEntry = cell.procgenRoom.tags.entry
        if not isPatrolIntoEntry then
            return cell
        end
    end
    -- No valid patrol paths. Give up.
    return nil
end

local function fixBrokenPatrolPath(situation, unit, x0, y0)
    local sim = unit:getSim()
    local beginnerPatrols = sim:getParams().difficultyOptions.beginnerPatrols

    if beginnerPatrols then
        -- Less clear how it can fail with beginnerPatrols enabled.
        -- Make a stationary patrol with proper facing to avoid breaking beginnerPatrols rules.
        situation:generateStationaryPath(unit, x0, y0)
    elseif cbf_util.simCheckFlag(sim, "cbf_idle_fixfailedpatrolpath") ==
            constants.IDLE_FIXFAILEDPATROLPATH.REGENERATE then
        -- Try to find a valid patrol path with looser restrictions.
        local destCell = findValidSecondPatrolCell(sim, unit, x0, y0)
        if destCell then
            local path = {}
            table.insert(path, {x = x0, y = y0})
            table.insert(path, {x = destCell.x, y = destCell.y})
            unit:getTraits().patrolPath = path
        else
            -- Fallback to a stationary path with the starting point.
            situation:generateStationaryPath(unit, x0, y0)
        end
    else
        -- User requested stationary paths as the fix.
        situation:generateStationaryPath(unit, x0, y0)
    end
end

function IdleSituation:generatePatrolPath(unit, x0, y0, noPatrolCheck)
    local oldPatrolPath = unit:getTraits().patrolPath
    oldGeneratePatrolPath(self, unit, x0, y0, noPatrolCheck)

    -- Fix for broken stationary paths
    local sim = unit:getSim()
    local fixFailedPatrolPath = cbf_util.simCheckFlag(
            sim, "cbf_idle_fixfailedpatrolpath", constants.IDLE_FIXFAILEDPATROLPATH.DISABLED)
    if fixFailedPatrolPath ~= constants.IDLE_FIXFAILEDPATROLPATH.DISABLED then
        local newPatrolPath = unit:getTraits().patrolPath
        local pathChanged = not oldPatrolPath or oldPatrolPath ~= newPatrolPath
        if pathChanged and isBrokenStationaryPath(newPatrolPath) then
            -- Use the starting point chosen by generatePatrolPath, in case x0,y0 were initially nil.
            fixBrokenPatrolPath(self, unit, newPatrolPath[1].x, newPatrolPath[1].y)
        end
    end
end
