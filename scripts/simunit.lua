-- patch to sim/simunit

local simunit = include('sim/simunit')
local simdefs = include( "sim/simdefs" )

-- Instead of resetAllAiming, checks that any aiming is still valid.
-- rawset to add a new method to the readonly prototype.
rawset(simunit, "recheckAllAiming", function( self )
	if not self:getSim():getParams().difficultyOptions.cbf_inventory_recheckoverwatchondrop then
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
