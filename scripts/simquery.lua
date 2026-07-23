-- patch to sim/simquery
local simdefs = include("sim/simdefs")
local simquery = include('sim/simquery')
local array = include("modules/array")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- Is the unit currently engaged in a persistent animation that expects its current facing?
function simquery.cbfAgentHasStickyFacing(unit)
    -- mod_data_hacking: added by Manual Hacking mod
    return (unit:getTraits().monster_hacking or unit:getTraits().data_hacking or
                   unit:getTraits().mod_data_hacking)
end

-- idea: only check for enemy impass when the unit is currently acting and recalculating because of something that happened
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

	for i, cellUnit in ipairs(endcell.units) do
		if
			unit
			and (unit:getTraits().dynamicImpass or cellUnit:getTraits().emitterID)
			and cellUnit:getTraits().dynamicImpass
		then
			if cellUnit:getTraits().emitterID and cellUnit:canControl(unit) then
				-- Owned emitters will turn themselves off, so they are not considered impassable.
			elseif cellUnit:getPlayerOwner() == unit:getPlayerOwner() then
				-- Allow pathing through same owners.
			elseif not cellUnit:getTraits().isAgent then
				return false, simdefs.CANMOVE_DYNAMIC_IMPASS
			elseif
				-- vip units are allowed to update their paths on seen units during pc turn because their paths
				-- get invalidated from Senses:processWarpTrigger
				(unit:canReact() or unit:getTraits().vip)
				and unit:getSeenUnits()
				and array.find(unit:getSeenUnits(), cellUnit)
			then
				-- we can see this dynImpass unit
				return false, simdefs.CANMOVE_DYNAMIC_IMPASS
			elseif
				unit:canReact()
				and simquery.couldUnitSee(sim, unit, cellUnit, true)
				and (
					simquery.checkCellCover(sim, startcell.x, startcell.y, endcell.x, endcell.y)
						and not unit:getTraits().seesHidden
					or not sim:getLOS():raycastToCell(
						startcell.x,
						startcell.y,
						endcell.x,
						endcell.y,
						0,
						math.pi,
						unit:getTraits().LOSrange
					)
				)
			then
				-- we could see this unit, but not from this position
				return false, simdefs.CANMOVE_DYNAMIC_IMPASS
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
