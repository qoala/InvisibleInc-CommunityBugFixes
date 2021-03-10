-- lateInit patch to sim/btree/situations/idle
--
-- Conditionally disables the function so should be applied after other patches.

local IdleSituation = include("sim/btree/situations/idle")

local oldGeneratePatrolPath = IdleSituation.generatePatrolPath

function IdleSituation:generatePatrolPath( unit, x0, y0, noPatrolCheck )
	local sim = unit:getSim()
	-- Note: this fix has been removed from campaign options. Preserved only for backwards compatibility.
	local applyFix = sim:getParams().difficultyOptions.cbf_nopatrol_nopatrolchange

	if not applyFix or not unit:getTraits().nopatrol then
		oldGeneratePatrolPath( self, unit, x0, y0, noPatrolCheck )
	end
end
