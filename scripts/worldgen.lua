local worldgen = include("sim/worldgen")
local mathutil = include("modules/mathutil")

-- DLC adds an exact copy of the existing camera prefab for some reason, but the filename comparison here fails
-- which causes cameras to be closer to each other than intended if the DLC is enabled (or if WE special ftm cameras are used)
function worldgen.cameraFitness(candidates)
	return function(cxt, prefab, tx, ty)
		local MIN_CAMERA_DISTANCE = 5
		local x0, y0 = prefab.camera.x + tx + prefab.tx, prefab.camera.y + ty + prefab.ty
		local room = cxt:roomContaining(x0, y0)
		local count = 0
		for _, candidate in ipairs(candidates) do
			-- fixed using direct filename comparison, check for camera instead
			if candidate.prefab.camera then
				-- fixed usage of prefab.ty instead of candidate.prefab.ty
                -- (not relevant in vanilla because there is only one camera prefab, but if some mod ever adds a custom camera prefab then it will be)
				local x1, y1 =
					candidate.prefab.camera.x + candidate.tx + candidate.prefab.tx,
					candidate.prefab.camera.y + candidate.ty + candidate.prefab.ty
				local r2 = cxt:roomContaining(x1, y1)
				if r2.roomIndex == room.roomIndex then
					if mathutil.dist2d(x0, y0, x1, y1) < MIN_CAMERA_DISTANCE then
						return 0
					end
					count = count + 1
				end
			end
		end
		if count >= 2 then
			return 0
		else
			return 1
		end
	end
end

local _, idx, subFn = upvalueUtil.find(worldgen.worlds.ftm.generatePrefabs, "cameraFitness", 5)
if idx then
	debug.setupvalue(subFn, idx, worldgen.cameraFitness)
end
