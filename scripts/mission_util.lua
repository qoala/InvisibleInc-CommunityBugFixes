-- patch to sim/missions/mission_util

local mission_util = include( "sim/missions/mission_util" )
local simquery = include( "sim/simquery" )

mission_util.findCellsAwayFromTag = function( sim, tag, dist )
	local cells = sim:getCells( tag )
	local cell = cells[1]
	local foundCells = {}

	if cell then
		local x0,y0= cell.x,cell.y
		local possibleCells = {}
		sim:forEachCell( function( c )
			if math.abs(x0-c.x) > dist or math.abs(y0-c.y) > dist then
				if not simquery.checkDynamicImpass(sim, c) and simquery.canStaticPath( sim, nil, nil, cell) then
					local badMatch = false

					for tag,bool in pairs(c.procgenRoom.tags) do
						if tag == "entry" then
							badMatch = true
						end
						if sim:isVersion("0.17.11") then
							if c.impass ~= 0  then
								badMatch = true
							end
						end
					end
					-- noguard implies the prefab doesn't want unrelated things randomly placed here.
					if simquery.cellHasTag(sim, c, "noguard") then
						badMatch = true
					end

					if not badMatch then
						table.insert(foundCells,c)
					end
				end
			end
		end )
	end

	return foundCells
end
