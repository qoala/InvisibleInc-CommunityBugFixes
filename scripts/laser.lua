-- patch to sim/units/laser

local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local laser = include( "sim/units/laser" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

-- sim/units/laser doesn't export the class, unlike most unit class files, and the exported function was registered as a local, so can't be appended.
-- Use debug.getupvalue to extract the class table
if not laser.laser_emitter then
	laser.laser_emitter = cbf_util.extractUpvalue( laser.createLaserEmitter, "laser_emitter" )
end
if not laser.laserbeam then
	local ClassFactory = include('modules/class_factory')
	local CF = cbf_util.extractUpvalue( ClassFactory.AddClass, "ClassFactory" )
	local createLaserBeam = CF["laserbeam"]
	assert(createLaserBeam~= nil, "Missing laserbeam class")
	laser.laserbeam = cbf_util.extractUpvalue( createLaserBeam, "laserbeam" )
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
-- Overwritten/Appended laser_emitter methods
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

-- ===
-- Overwritten/Appended laserbeam methods
-- ===

local function getRandomDaemon(sim)
	if sim:isVersion("0.17.5") then
		-- Select a random daemon, based on the current level's available list (same code as Fractal)
		local programList = sim:getIcePrograms()
		return programList:getChoice( sim:nextRand( 1, programList:getTotalWeight() ))
	else
		-- Older fallback, using the same code as Cyber Consciousness (equivalent to original laser code).
		local npc_abilities = include( "sim/abilities/npc_abilities" )
		local daemons = {}
		for k, v in pairs(npc_abilities) do
			if v.standardDaemon then
				table.insert(daemons, k)
			end
		end
		return daemons[sim:nextRand(1,#daemons)]
	end
end

local oldTripLaser = laser.laserbeam.tripLaser

function laser.laserbeam:tripLaser( sim, x0, y0, unit, ... )
	if not cbf_util.simCheckFlag(self:getSim(), "cbf_laserdaemons") then
		return oldTripLaser( self, sim, x0, y0, unit, ... )
	end

	-- Overwrite laserbeam:tripLaser. Changes at "CBF:"

	local emitterUnit = sim:getUnit( self:getTraits().emitterID )

	if self:getTraits().koDamage and unit:getWounds() then
		sim:emitSound( simdefs.SOUND_HIT_LASERS_FLESH, x0, y0, unit)
		sim:damageUnit(unit, 0, self:getTraits().koDamage )
	end

	if emitterUnit:getPlayerOwner() and emitterUnit:getPlayerOwner():isPC() then
		emitterUnit:getPlayerOwner():glimpseUnit( sim, unit:getID() )
	else

		if self:getTraits().tripsDaemon then
			sim:emitSound( simdefs.SOUND_HIT_LASERS_FLESH, x0, y0, unit )
			-- CBF: get a random Daemon from the world-specific list, including override resolution.
			-- Don't spawn authority,etc in OMNI. Never spawn old Felix.
			local daemon = getRandomDaemon( sim )
			sim:getNPC():addMainframeAbility( sim, daemon )
		end

		if self:getTraits().isAlarm then
			sim:trackerAdvance( 1, STRINGS.UI.ALARM_LASER_SCAN )
		end
	end

	if self:getTraits().damage and unit:getWounds() then
		sim:emitSound( simdefs.SOUND_HIT_LASERS_FLESH, x0, y0, unit)
		sim:damageUnit( unit, self:getTraits().damage, nil, nil, self )
	end
end
