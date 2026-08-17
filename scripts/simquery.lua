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

-- idea: only check for enemy impass during the npc turn and when the unit is already standing adjacent to it
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

	local unitCell = sim:getCell(unit:getLocation())

    for i, cellUnit in ipairs(endcell.units) do
        if unit and (unit:getTraits().dynamicImpass or cellUnit:getTraits().emitterID) and
                cellUnit:getTraits().dynamicImpass then
            if cellUnit:getTraits().emitterID and cellUnit:canControl(unit) then
                -- Owned emitters will turn themselves off, so they are not considered impassable.
            elseif cellUnit:getPlayerOwner() == unit:getPlayerOwner() then
                -- Allow pathing through same owners.
            elseif not cellUnit:getTraits().isAgent then
                return false, simdefs.CANMOVE_DYNAMIC_IMPASS
			elseif
				unit:getTraits().vip
				and unit:getBrain()
				and (
					unit:getBrain():getTarget() == cellUnit
					or array.findIf(unit:getBrain():getSenses().interests, function(interest)
							return interest.reason == simdefs.REASON_LOSTTARGET
								and interest.x == endcell.x
								and interest.y == endcell.y
								and interest.sourceUnit == cellUnit
						end)
				)
			then
				-- vip units are allowed to react to impass on enemies during pc turn because their paths
				-- automatically get updated from the invalidation from Senses:processWarpTrigger
				return false, simdefs.CANMOVE_DYNAMIC_IMPASS
			elseif
				sim:getCurrentPlayer() == unit:getPlayerOwner()
				-- first, check if the unit is currently adjacent at all, no matter the startcell
				and unitCell
				and simquery.canPathBetween(sim, unit, unitCell, endcell)
			then
				if math.abs(endcell.x - startcell.x) == 1 and math.abs(endcell.y - startcell.y) == 1 then
					-- reject all diagonals, no matter which direction we are facing
					-- (necessary because of the AGP coop handler punishing movement to overwatched agents which
					-- could cause the guard to not even try to move on its tile)
					return false, simdefs.CANMOVE_DYNAMIC_IMPASS
				else
					-- now do startcell-independent checking of the unit cell
					local dx, dy = endcell.x - unitCell.x, endcell.y - unitCell.y
					if
						-- only if we're looking at this cell
						unit:getFacing() == simquery.getDirectionFromDelta(dx, dy)
						and (
							-- either we are already standing orthogonal to the endcell
							math.abs(dx) + math.abs(dy) == 1
							-- or it's a non-hostile (hacked drones, disguises)
							or not simquery.isEnemyTarget(unit:getPlayerOwner(), cellUnit)
						)
					then
						return false, simdefs.CANMOVE_DYNAMIC_IMPASS
					end
				end
			end
        end
    end

    return simquery.canStaticPath(sim, unit, startcell, endcell)
end

-- this mistakenly returned true on a target if it leaves overwatch but the guard had multiple targets before
-- (there is no cleanup in the combat situation until the guard leaves combat)
function simquery.isUnitUnderOverwatch(target)
    local aiPlayer = target:getSim() and target:getSim():getNPC()
    local situation = aiPlayer and aiPlayer:findExistingCombatSituation(target)
    if situation and situation:isValid() then
        for k, unit in pairs(situation.units) do
            if not unit:isDown() and not unit:getTraits().pacifist -- check if the unit actually still has this target
            and unit:getBrain() and unit:getBrain():getSenses() and
                    unit:getBrain():getSenses():hasTarget(target) then
                return true
            end
        end
    end
    return false
end
