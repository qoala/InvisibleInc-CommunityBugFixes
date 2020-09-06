-- patch to sim/simquery

local simquery = include('sim/simquery')

-- Is the unit currently engaged in a persistent animation that expects its current facing?
function simquery.cbfAgentHasStickyFacing( unit )
	-- mod_data_hacking: added by Manual Hacking mod
	return (unit:getTraits().monster_hacking
			or unit:getTraits().data_hacking
			or unit:getTraits().mod_data_hacking)
end
