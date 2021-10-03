-- patch to sim/simunit

local mathutil = include( "modules/mathutil" )
local simdefs = include( "sim/simdefs" )
local simquery = include( "sim/simquery" )
local simunit = include('sim/simunit')

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )
local constants = include( SCRIPT_PATHS.qoala_commbugfix .. "/constants" )

-- Overwrite simunit:onWarp. Changes at "CBF:"
function simunit:onWarp(sim, oldcell, cell)
	if self:getPlayerOwner() and self:getPlayerOwner():isNPC() and self:getTraits().isGuard then
		for i,checkUnit in pairs( sim:getAllUnits() ) do
			if checkUnit:getTraits().hologram then
				local x0,y0 = self:getLocation()
				local x1,y1 = checkUnit:getLocation()
				if x0 and y0 and x1 and y1 then
					local distance = mathutil.dist2d( x0, y0, x1, y1 )
					local checkDist = 2
					if not self:getTraits().hasHearing then
						checkDist = 1
					end
					local brain = self:getBrain()
					if distance < checkDist and brain then
						-- CBF: Check if walls are blocking us from immediately observing the hologram.
						-- Vanilla uses REASON_FOUNDOBJECT as an alerting interest.
						local reason = simdefs.REASON_FOUNDOBJECT
						local option = cbf_util.simCheckFlag(sim, "cbf_holowallsounds", constants.HOLOWALLSOUNDS.VANILLA)

						if (x0 ~= x1 or y0 ~= y1) and option ~= constants.HOLOWALLSOUNDS.VANILLA then
							local open = false
							local cell = sim:getCell(x0, y0)
							local dir = simquery.getDirectionFromDelta(x1 - x0, y1 - y0)
							if (dir % 2) == 0 then
								-- orthogonally adjacent: is the direct path blocked?
								open = simquery.isOpenExit(cell.exits[dir])
							else
								-- diagonally adjacent: Are both orthogonal-stepping routes blocked?
								local dirL = (dir - 1) % simdefs.DIR_MAX
								local dirR = (dir + 1) % simdefs.DIR_MAX
								local openLR = (simquery.isOpenExit(cell.exits[dirL]) and simquery.isOpenExit(cell.exits[dirL].cell.exits[dirR]))
								local openRL = (simquery.isOpenExit(cell.exits[dirR]) and simquery.isOpenExit(cell.exits[dirR].cell.exits[dirL]))
								open = openLR or openRL
							end

							if not open then
								if option == constants.HOLOWALLSOUNDS.NOTICE then
									reason = simdefs.REASON_NOISE
								else
									reason = nil
								end
							end
						end

						if reason then
							brain:getSenses():addInterest( x1, y1, simdefs.SENSE_HEARING, reason, checkUnit)
						end
					end
				end

			end
		end
	end
end

-- Instead of simunit:resetAllAiming, checks that any aiming is still valid.
-- rawset to add new method, simunit:recheckAllAiming, to the readonly prototype.
rawset(simunit, "recheckAllAiming", function( self )
	if not cbf_util.simCheckFlag(self:getSim(), "cbf_inventory_recheckoverwatchondrop") then
		self:resetAllAiming()
		return
	end

	local didReset = false;
    if self:isAiming()then
		local overwatch = self:ownsAbility("overwatch")
		if not overwatch or not overwatch:canUseAbility( self:getSim(), self ) then
			self:setAiming(false)
			didReset = true
		end
    end

    if self:getTraits().isMeleeAiming then
		local overwatch = self:ownsAbility("overwatchMelee")
		if not overwatch or not overwatch:canUseAbility( self:getSim(), self ) then
			self:getTraits().isMeleeAiming = false
			didReset = true
		end
    end

	if didReset then
	    self:getSim():dispatchEvent( simdefs.EV_UNIT_REFRESH, { unit = self })
	end
end)
