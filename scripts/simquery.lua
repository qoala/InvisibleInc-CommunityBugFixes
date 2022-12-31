-- patch to sim/simquery
local simdefs = include("sim/simdefs")
local simquery = include('sim/simquery')

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- Is the unit currently engaged in a persistent animation that expects its current facing?
function simquery.cbfAgentHasStickyFacing(unit)
    -- mod_data_hacking: added by Manual Hacking mod
    return (unit:getTraits().monster_hacking or unit:getTraits().data_hacking or
                   unit:getTraits().mod_data_hacking)
end

-- Disguise Fix/Function Library:
-- Allow pathing through enemies unless we START next to them and are looking towards their tile
-- This way the original intention is preserved (making guards go around the obstacle between them and the agent if the agent is blocking them from making a diagonal move)
-- While also fixing them refusing to path through non-hostile agents as well as "magically" knowing where the agents are
-- Unfortunately this is complicated by some guards not stopping when they see the agent (like System Admins) so we end up having to store impass we've previously encountered for later
-- Also don't block non-dynamicImpass units except from laser grids.
local oldCanSoftPath = simquery.canSoftPath
function simquery.canSoftPath(sim, unit, startcell, endcell, ...)
    if not cbf_util.simCheckFlag(sim, "cbf_disguisefix_pathing") then
        return oldCanSoftPath(sim, unit, startcell, endcell, ...)
    end
    -- Transistor: hijacked guards still try to call this, but are not NPC-owned.
    if unit:getTraits().psiTakenGuard then
        return
    end

    assert(not endcell.ghostID)
    assert(not startcell.ghostID)
    assert(unit:isNPC())

    if not unit:getTraits().rememberedImpass then
        unit:getTraits().rememberedImpass = {}
    end

    for i, cellUnit in ipairs(endcell.units) do
        if unit and (unit:getTraits().dynamicImpass or cellUnit:getTraits().emitterID) and
                cellUnit:getTraits().dynamicImpass then
            local x0, y0 = unit:getLocation()
            if cellUnit:getTraits().emitterID and cellUnit:canControl(unit) then
                -- Owned emitters will turn themselves off, so they are not considered impassable.
            elseif cellUnit:getPlayerOwner() == unit:getPlayerOwner() then
                -- Allow pathing through same owners.
            elseif not cellUnit:getTraits().isAgent then
                return false, simdefs.CANMOVE_DYNAMIC_IMPASS
            elseif (startcell.x == x0 and startcell.y == y0 and
                    sim:canUnitSee(unit, endcell.x, endcell.y)) or
                    (math.abs(x0 - endcell.x) + math.abs(y0 - endcell.y) == 1 and
                            unit:getTraits().rememberedImpass[endcell.id]) then
                unit:getTraits().rememberedImpass[endcell.id] = true
                return false, simdefs.CANMOVE_DYNAMIC_IMPASS
            else

            end
        end
    end

    unit:getTraits().rememberedImpass[endcell.id] = nil

    return simquery.canStaticPath(sim, unit, startcell, endcell)
end
