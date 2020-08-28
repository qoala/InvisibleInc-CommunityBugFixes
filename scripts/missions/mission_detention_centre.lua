-- patch to sim/missions/mission_detention_centre.lua

local mission_detention_centre = include( "sim/missions/mission_detention_centre" )

local oldInit = mission_detention_centre.init

function mission_detention_centre:init( scriptMgr, sim )
	oldInit( self, scriptMgr, sim )

	-- -----
	-- Detention Centers agent chance fix
	-- -----
	sim:getTags().cbfCouldHaveAgent = true
end
