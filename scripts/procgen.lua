local procgen = include("sim/procgen")
local mazegen = include("sim/mazegen")
local array = include("modules/array")

local function analyzeFeatures(cxt)
    for _, room in ipairs(cxt.rooms) do
        room.tags = room.tags or {}
    end

    local originRoom = array.findIf(
            cxt.rooms, function(r)
                return r.tags ~= nil and r.tags.entry
            end)

    mazegen.breadthFirstSearch(
            cxt, originRoom, function(room)
                room.lootWeight = (room.depth or 0) + 1
            end)
    local exitRoom = array.findIf(
            cxt.rooms, function(r)
                return r.tags ~= nil and (r.tags.exit or r.tags.exit_vault) -- fix endless exit not being included
            end)
    if exitRoom then
        mazegen.breadthFirstSearch(
                cxt, exitRoom, function(room)
                    room.lootWeight = room.lootWeight * ((room.depth or 0) + 1)
                end)
    end

    for i, room in ipairs(cxt.rooms) do
        cxt.maxLootWeight = math.max(room.lootWeight, cxt.maxLootWeight or 0)
    end
end

upvalueUtil.findAndReplace(procgen.generateLevel, "analyzeFeatures", analyzeFeatures)
