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

local oldCanSoftPath = simquery.canSoftPath
function simquery.canSoftPath(sim, unit, startcell, endcell, ...)
	local impassMemory = unit:getBrain()
		and unit:getBrain():getSenses()
		and unit:getBrain():getSenses().CBF_impassMemory
	if not cbf_util.simCheckFlag(sim, "cbf_disguisefix_pathing") or not impassMemory then
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
			elseif cellUnit:isValid() then
				local impass = impassMemory.impass[cellUnit:getID()]
				if impass and impass.x == endcell.x and impass.y == endcell.y then
					if impass.hard then
						-- we directly saw this tile or unit
						return false, simdefs.CANMOVE_DYNAMIC_IMPASS
					elseif simquery.checkCellCover(sim, startcell.x, startcell.y, endcell.x, endcell.y) then
						-- we did not directly see this tile or unit, but we got blocked here and still can't see it directly
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
