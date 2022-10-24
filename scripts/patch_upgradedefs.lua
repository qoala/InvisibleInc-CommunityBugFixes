

local function addEscortsFixed()
	local upgrade_templates = include("sim/upgradedefs").upgrade_templates

	-- ===
	-- Additional upgrade type for Escorts Fixed.
	-- ===
	upgrade_templates.clearChildren = {
		apply = function( unitData, params )
			unitData.children = {}
		end,
	}
end

return {
	addEscortsFixed = addEscortsFixed,
}
