local function packCoord(x, y)
	return y * 1000 + x
end

local function doPatchMatchTags(prefab, antiTags)
	local t = prefab.match_elements
	for i=1, #t, 4 do
		local antiValue = antiTags[packCoord(t[i], t[i+1])]
		if antiValue then
			t[i+3] = antiValue
		end
	end
end

local function patchEntryGuard()
	local prefabs = include("sim/prefabs/shared/prefabt").PREFABT0

	local prefab = prefabs[85] -- [entry_guard facing=0]
	if not prefab then
		simlog("[CBF][ERROR] Mismatch failure patching prefab. Expected entry_guard,facing=0 in slot 85. prefabt length %s", #prefabs)
	end
	if not (prefab.filename == [[sim/prefabs/shared/entry_guard]] and prefab.facing == 0) then
		simlog("[CBF][ERROR] Mismatch failure patching prefab. Expected entry_guard,facing=0. Got %s,facing=%s", prefab.filename, prefab.facing)
		return
	end

	-- append "door_#" to each interior tile's anti-match tags in the direction of the elevator's side wall.
	doPatchMatchTags(prefab, {
		[packCoord(1,2)] = "tile burnt door_6 wall_6 door_0 wall_0 door_4",
		[packCoord(1,1)] = "tile burnt door_2 wall_2 wall_6 door_0 wall_0 door_4",
		[packCoord(2,2)] = "tile burnt door_6 wall_6 door_4 wall_4 door_0",
		[packCoord(2,1)] = "tile burnt door_2 wall_2 wall_6 door_4 wall_4 door_0",
	})
	prefab = prefabs[86] -- [entry_guard facing=2]
	doPatchMatchTags(prefab, {
		[packCoord(1,1)] = "tile burnt door_0 wall_0 door_2 wall_2 door_6",
		[packCoord(2,1)] = "tile burnt door_4 wall_4 wall_0 door_2 wall_2 door_6",
		[packCoord(1,2)] = "tile burnt door_0 wall_0 door_6 wall_6 door_2",
		[packCoord(2,2)] = "tile burnt door_4 wall_4 wall_0 door_6 wall_6 door_2",
	})
	prefab = prefabs[87] -- [entry_guard facing=4]
	doPatchMatchTags(prefab, {
		[packCoord(2,1)] = "tile burnt door_2 wall_2 door_4 wall_4 door_0",
		[packCoord(2,2)] = "tile burnt door_6 wall_6 wall_2 door_4 wall_4 door_0",
		[packCoord(1,1)] = "tile burnt door_2 wall_2 door_0 wall_0 door_4",
		[packCoord(1,2)] = "tile burnt door_6 wall_6 wall_2 door_0 wall_0 door_4",
	})
	prefab = prefabs[88] -- [entry_guard facing=6]
	doPatchMatchTags(prefab, {
		[packCoord(2,2)] = "tile burnt door_4 wall_4 door_6 wall_6 door_2",
		[packCoord(1,2)] = "tile burnt door_0 wall_0 wall_4 door_6 wall_6 door_2",
		[packCoord(2,1)] = "tile burnt door_4 wall_4 door_2 wall_2 door_6",
		[packCoord(1,1)] = "tile burnt door_0 wall_0 wall_4 door_2 wall_2 door_6",
	})
end

local function patchBarrierLaser()
end

local function resetPrefabs()
	package.loaded["sim/prefabs/shared/prefabt"] = nil
end

return {
	resetPrefabs = resetPrefabs,
	patchEntryGuard = patchEntryGuard,
	patchBarrierLaser = patchBarrierLaser,
}
