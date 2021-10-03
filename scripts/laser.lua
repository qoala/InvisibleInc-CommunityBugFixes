-- patch to sim/units/laser

local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local laser = include( "sim/units/laser" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

local function extractUpvalue( fn, name )
	local i = 1
	while true do
		local n, v = debug.getupvalue(fn, i)
		assert(n, string.format( "Could not find upvalue: %s", name ) )
		if n == name then
			return v
		end
		i = i + 1
	end
end

-- sim/units/laser doesn't export the class, unlike most unit class files, and the exported function was registered as a local, so can't be appended.
-- Use debug.getupvalue to extract the class table
if not laser.laser_emitter then
	laser.laser_emitter = extractUpvalue( laser.createLaserEmitter, "laser_emitter" )
end

-- ===
-- Local functions copied from sim/units/laser
-- ===

local function canTripLaser( unit )
    return simquery.isAgent( unit ) or unit:getTraits().iscorpse
end

-- like pairs() but returns k,v in order of lexographically sorted k for determinism
local function lasercells( sim, unit )
	local function iteratorFn( startCell, cell )
		if cell == nil then
			return startCell
		else
			local exit = cell.exits[ unit:getFacing() ]
			if simquery.isOpenExit( exit ) then
				return exit.cell
			else
				return nil
			end
		end
	end

	return iteratorFn, sim:getCell( unit:getLocation() ), nil
end

-- ===
-- Overwritten/Appended methods
-- ===

-- Overwrite laser_emitter:canControl. Changes at "CBF:"
-- CBF: add an additional parameter (usually nil) to prevent excessive recursion
function laser.laser_emitter:canControl( unit, inRecursion )
	if canTripLaser( unit ) then
		-- if you are not an enemy because of disguise, it doesn't work.
		if not simquery.isEnemyAgent( self:getPlayerOwner(), unit, true) then
			return true
		end
		if not inRecursion and unit:getTraits().movingBody and self:canControl( unit:getTraits().movingBody, true ) then
			return true
		elseif not inRecursion and cbf_util.simCheckFlag(self:getSim(), "cbf_laserdragsymmetry") then
			-- CBF: dragged units also gain canControl if the dragging unit has that authority. Symmetric with the previous conditional.
			local _, draggedBy = simquery.isUnitDragged( self:getSim(), unit )
			if draggedBy and self:canControl( draggedBy, true ) then
				return true
			end
		end
	end
	return false
end


local oldOnTrigger = laser.laser_emitter.onTrigger
function laser.laser_emitter:onTrigger( sim, evType, evData, ... )
	oldOnTrigger( self, sim, evType, evData, ... )

	-- The vanilla reactivate check only runs when player owner is nil. Repeat that check for player owner is not nil.
	if (evType == simdefs.TRG_UNIT_WARP and evData.from_cell ~= evData.to_cell
			and self:getTraits().mainframe_status == "inactive" and self:getPlayerOwner() ~= nil
			and cbf_util.simCheckFlag(self:getSim(), "cbf_laserdragsymmetry")
			and self:canControl( evData.unit )) then
		-- If it's a friendly warping out of the laser range, may have to re-activate ourselves.
		local found = false
		for cell in lasercells( sim, self ) do
			if cell == evData.from_cell then
				found = true
			end
		end
		if found and self:canActivate( sim ) then
			self:activate( sim )
		end
	end
end
