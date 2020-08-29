-- patch to sim/simactions

local simactions = include('sim/simactions')
local simdefs = include('sim/simdefs')
local simquery = include('sim/simquery')

local function unitIsHacking( unit )
	-- mod_data_hacking: added by Manual Hacking mod
	return unit:getTraits().monster_hacking or unit:getTraits().data_hacking or unit:getTraits().mod_data_hacking
end

-- Overwrite useDoorAction. Change at '-- CBF:' below.
function simactions.useDoorAction( sim, exitOp, unitID, x0, y0, facing )
	local player = sim:getCurrentPlayer()
	local unit = sim:getUnit( unitID )
	local cell = sim:getCell(x0, y0)

	assert( unit:getPlayerOwner() == player, unit:getName()..","..tostring(unit:getPlayerOwner())..","..tostring(exitOp) )
	assert( cell )
	if sim:isVersion("0.17.5") then
		assert( simquery.canModifyExit( unit, exitOp, cell, facing ))
	end
	assert( simquery.canReachDoor( unit, cell, facing ))

	--face the door correctly if it's not in the same cell
	local vizFacing = facing
	local x1,y1 = unit:getLocation()
	if x0 ~= x1 or y0 ~= y1 then
		vizFacing = simquery.getDirectionFromDelta(x0-x1,y0-y1)
	end

	-- CBF: Skip the facing update if the unit is in a multi-turn hacking animation.
	-- We want the agent to return to their existing facing at the end of the door anim.
	if not unitIsHacking(unit) then
		unit:setFacing(vizFacing)
	end

	if not unit:getTraits().noDoorAnim then
		sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR, { unitID = unitID, facing = vizFacing, exitOp=exitOp } )
	end
	sim:modifyExit( cell, facing, exitOp, unit,  unit:getTraits().sneaking )
    if unit:isValid() then
	    if not unit:getTraits().noDoorAnim then
		    sim:dispatchEvent( simdefs.EV_UNIT_USEDOOR_PST, { unitID = unitID, facing = vizFacing, exitOp=exitOp } )
	    end
	    if exitOp == simdefs.EXITOP_BREAK_DOOR and not unit:getTraits().interrupted then
		    sim:dispatchEvent( simdefs.EV_UNIT_GUNCHECK, { unit = unit, facing = vizFacing } )
	    end
    end
	unit:getTraits().interrupted = nil
end
