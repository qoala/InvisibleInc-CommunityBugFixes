local IdleSituation = include("sim/btree/situations/idle")

local oldGeneratePatrolPath = IdleSituation.generatePatrolPath

function IdleSituation:generatePatrolPath( unit, x0, y0, noPatrolCheck )
	local sim = unit:getSim()
	local applyFix = sim:getParams().difficultyOptions.cbf_nopatrol_nopatrolchange

	if not applyFix or not unit:getTraits().nopatrol then
		oldGeneratePatrolPath( self, unit, x0, y0, noPatrolCheck )
	end
end
