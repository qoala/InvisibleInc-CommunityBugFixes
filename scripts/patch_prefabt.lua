local function packCoord(x, y)
    return y * 1000 + x
end

local function doPatchMatchTags(prefab, antiTags)
    local t = prefab.match_elements
    for i = 1, #t, 4 do
        local antiValue = antiTags[packCoord(t[i], t[i + 1])]
        if antiValue then
            t[i + 3] = antiValue
        end
    end
end

local function patchEntryGuard()
    local prefabs = include("sim/prefabs/shared/prefabt").PREFABT0

    local prefab = prefabs[85] -- [entry_guard facing=0]
    if not prefab then
        simlog(
                "[CBF][ERROR] Mismatch failure patching prefab. Expected entry_guard,facing=0 in slot 85. prefabt length %s",
                #prefabs)
    end
    if not (prefab.filename == [[sim/prefabs/shared/entry_guard]] and prefab.facing == 0) then
        simlog(
                "[CBF][ERROR] Mismatch failure patching prefab. Expected entry_guard,facing=0. Got %s,facing=%s",
                prefab.filename, prefab.facing)
        return
    end

    -- append "door_#" to each interior tile's anti-match tags in the direction of the elevator's side wall.
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 2)] = "tile burnt door_6 wall_6 door_0 wall_0 door_4",
                [packCoord(1, 1)] = "tile burnt door_2 wall_2 wall_6 door_0 wall_0 door_4",
                [packCoord(2, 2)] = "tile burnt door_6 wall_6 door_4 wall_4 door_0",
                [packCoord(2, 1)] = "tile burnt door_2 wall_2 wall_6 door_4 wall_4 door_0",
            })
    prefab = prefabs[86] -- [entry_guard facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt door_0 wall_0 door_2 wall_2 door_6",
                [packCoord(2, 1)] = "tile burnt door_4 wall_4 wall_0 door_2 wall_2 door_6",
                [packCoord(1, 2)] = "tile burnt door_0 wall_0 door_6 wall_6 door_2",
                [packCoord(2, 2)] = "tile burnt door_4 wall_4 wall_0 door_6 wall_6 door_2",
            })
    prefab = prefabs[87] -- [entry_guard facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(2, 1)] = "tile burnt door_2 wall_2 door_4 wall_4 door_0",
                [packCoord(2, 2)] = "tile burnt door_6 wall_6 wall_2 door_4 wall_4 door_0",
                [packCoord(1, 1)] = "tile burnt door_2 wall_2 door_0 wall_0 door_4",
                [packCoord(1, 2)] = "tile burnt door_6 wall_6 wall_2 door_0 wall_0 door_4",
            })
    prefab = prefabs[88] -- [entry_guard facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(2, 2)] = "tile burnt door_4 wall_4 door_6 wall_6 door_2",
                [packCoord(1, 2)] = "tile burnt door_0 wall_0 wall_4 door_6 wall_6 door_2",
                [packCoord(2, 1)] = "tile burnt door_4 wall_4 door_2 wall_2 door_6",
                [packCoord(1, 1)] = "tile burnt door_0 wall_0 wall_4 door_2 wall_2 door_6",
            })
end

local function patchBarrierLaser()
    local prefabs = include("sim/prefabs/shared/prefabt").PREFABT0

    local prefab = prefabs[1] -- [barrier_laser_1 facing=0]
    if not prefab then
        simlog(
                "[CBF][ERROR] Mismatch failure patching prefab. Expected barrier_laser_1,facing=0 in slot 1. prefabt length %s",
                #prefabs)
    end
    if not (prefab.filename == [[sim/prefabs/shared/barrier_laser_1]] and prefab.facing == 0) then
        simlog(
                "[CBF][ERROR] Mismatch failure patching prefab. Expected barrier_laser_1,facing=0. Got %s,facing=%s",
                prefab.filename, prefab.facing)
        return
    end

    -- laser_1, laser_2, laser_3: laser grid with solid pillars on either end.
    --   append 4x "door_#" to the anti-match tags (all directions) of the 2 end-pillar tiles.
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_6 door_6 door_0 door_2 door_4",
                [packCoord(5, 1)] = "tile burnt wall_6 door_6 door_0 door_2 door_4",
            })
    prefab = prefabs[2] -- [barrier_laser_1 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_0 door_0 door_2 door_4 door_6",
                [packCoord(1, 5)] = "tile burnt wall_0 door_0 door_2 door_4 door_6",
            })
    prefab = prefabs[3] -- [barrier_laser_1 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(5, 1)] = "tile burnt wall_2 door_2 door_4 door_6 door_0",
                [packCoord(1, 1)] = "tile burnt wall_2 door_2 door_4 door_6 door_0",
            })
    prefab = prefabs[4] -- [barrier_laser_1 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 5)] = "tile burnt wall_4 door_4 door_6 door_0 door_2",
                [packCoord(1, 1)] = "tile burnt wall_4 door_4 door_6 door_0 door_2",
            })

    prefab = prefabs[5] -- [barrier_laser_2 facing=0]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_6 door_6 door_0 door_2 door_4",
                [packCoord(6, 1)] = "tile burnt wall_6 door_6 door_0 door_2 door_4",
            })
    prefab = prefabs[6] -- [barrier_laser_2 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_0 door_0 door_2 door_4 door_6",
                [packCoord(1, 6)] = "tile burnt wall_0 door_0 door_2 door_4 door_6",
            })
    prefab = prefabs[7] -- [barrier_laser_2 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(6, 1)] = "tile burnt wall_2 door_2 door_4 door_6 door_0",
                [packCoord(1, 1)] = "tile burnt wall_2 door_2 door_4 door_6 door_0",
            })
    prefab = prefabs[8] -- [barrier_laser_2 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 6)] = "tile burnt wall_4 door_4 door_6 door_0 door_2",
                [packCoord(1, 1)] = "tile burnt wall_4 door_4 door_6 door_0 door_2",
            })

    prefab = prefabs[9] -- [barrier_laser_3 facing=0]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_6 door_6 door_0 door_2 door_4",
                [packCoord(4, 1)] = "tile burnt wall_6 door_6 door_0 door_2 door_4",
            })
    prefab = prefabs[10] -- [barrier_laser_3 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_0 door_0 door_2 door_4 door_6",
                [packCoord(1, 4)] = "tile burnt wall_0 door_0 door_2 door_4 door_6",
            })
    prefab = prefabs[11] -- [barrier_laser_3 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(4, 1)] = "tile burnt wall_2 door_2 door_4 door_6 door_0",
                [packCoord(1, 1)] = "tile burnt wall_2 door_2 door_4 door_6 door_0",
            })
    prefab = prefabs[12] -- [barrier_laser_3 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 4)] = "tile burnt wall_4 door_4 door_6 door_0 door_2",
                [packCoord(1, 1)] = "tile burnt wall_4 door_4 door_6 door_0 door_2",
            })

    -- laser_4, laser_5, laser_7: laser grid with thin walls on either end.
    --   append "door_#" to the anti-match tags in the outward wall directions of the 2 end tiles.
    prefab = prefabs[13] -- [barrier_laser_4 facing=0]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_6 door_0 wall_0 wall_4 door_4",
                [packCoord(3, 1)] = "tile burnt wall_6 wall_0 door_4 wall_4 door_0",
            })
    prefab = prefabs[14] -- [barrier_laser_4 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(0, 1)] = "tile burnt wall_0 door_2 wall_2 wall_6 door_6",
                [packCoord(0, 3)] = "tile burnt wall_0 wall_2 door_6 wall_6 door_2",
            })
    prefab = prefabs[15] -- [barrier_laser_4 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(3, 0)] = "tile burnt wall_2 door_4 wall_4 wall_0 door_0",
                [packCoord(1, 0)] = "tile burnt wall_2 wall_4 door_0 wall_0 door_4",
            })
    prefab = prefabs[16] -- [barrier_laser_4 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 3)] = "tile burnt wall_4 door_6 wall_6 wall_2 door_2",
                [packCoord(1, 1)] = "tile burnt wall_4 wall_6 door_2 wall_2 door_6",
            })

    prefab = prefabs[17] -- [barrier_laser_5 facing=0]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_6 door_0 wall_0 wall_4 door_4",
                [packCoord(5, 1)] = "tile burnt wall_6 wall_0 door_4 wall_4 door_0",
            })
    prefab = prefabs[18] -- [barrier_laser_5 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(0, 1)] = "tile burnt wall_0 door_2 wall_2 wall_6 door_6",
                [packCoord(0, 5)] = "tile burnt wall_0 wall_2 door_6 wall_6 door_2",
            })
    prefab = prefabs[19] -- [barrier_laser_5 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(5, 0)] = "tile burnt wall_2 door_4 wall_4 wall_0 door_0",
                [packCoord(1, 0)] = "tile burnt wall_2 wall_4 door_0 wall_0 door_4",
            })
    prefab = prefabs[20] -- [barrier_laser_5 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 5)] = "tile burnt wall_4 door_6 wall_6 wall_2 door_2",
                [packCoord(1, 1)] = "tile burnt wall_4 wall_6 door_2 wall_2 door_6",
            })

    prefab = prefabs[25] -- [barrier_laser_7 facing=0]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt wall_6 door_0 wall_0 door_4",
                [packCoord(3, 1)] = "tile burnt wall_6 door_4 wall_4 door_0",
            })
    prefab = prefabs[26] -- [barrier_laser_7 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(0, 1)] = "tile burnt wall_0 door_2 wall_2 door_6",
                [packCoord(0, 3)] = "tile burnt wall_0 door_6 wall_6 door_2",
            })
    prefab = prefabs[27] -- [barrier_laser_7 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(3, 0)] = "tile burnt wall_2 door_4 wall_4 door_0",
                [packCoord(1, 0)] = "tile burnt wall_2 door_0 wall_0 door_4",
            })
    prefab = prefabs[28] -- [barrier_laser_7 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 3)] = "tile burnt wall_4 door_6 wall_6 door_2",
                [packCoord(1, 1)] = "tile burnt wall_4 door_2 wall_2 door_6",
            })

    -- laser_4, laser_5, laser_7: Z-shape of walls with a 2-wide laser. Not sure if this ever gets placed?
    --   append a lot of "door_#" to anti-match, corresponding to where the prefab puts solid walls.
    prefab = prefabs[21] -- [barrier_laser_6 facing=0]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 5)] = "tile burnt door_6 wall_6 door_0 wall_0 door_2 door_4",
                [packCoord(1, 4)] = "tile burnt door_2 wall_2 door_6 wall_6 door_0 wall_0 door_4",
                [packCoord(1, 3)] = "tile burnt door_2 wall_2 wall_6 door_0 wall_0 door_4",
                [packCoord(1, 1)] = "tile burnt door_2 wall_2 door_0 wall_0 door_6",
                [packCoord(2, 5)] = "tile burnt door_6 wall_6 door_4 wall_4 door_2",
                [packCoord(2, 3)] = "tile burnt door_2 wall_2 secdoor_6 door_4 wall_4 door_0",
                [packCoord(2, 2)] = "tile burnt secdoor_2 door_6 wall_6 door_4 wall_4 door_0",
                [packCoord(2, 1)] = "tile burnt door_2 wall_2 door_4 wall_4 door_6 door_0",
            })
    prefab = prefabs[22] -- [barrier_laser_6 facing=2]
    doPatchMatchTags(
            prefab, {
                [packCoord(1, 1)] = "tile burnt door_0 wall_0 door_2 wall_2 door_4 door_6",
                [packCoord(2, 1)] = "tile burnt door_4 wall_4 door_0 wall_0 door_2 wall_2 door_6",
                [packCoord(3, 1)] = "tile burnt door_4 wall_4 wall_0 door_2 wall_2 door_6",
                [packCoord(5, 1)] = "tile burnt door_4 wall_4 door_2 wall_2 door_0",
                [packCoord(1, 2)] = "tile burnt door_0 wall_0 door_6 wall_6 door_4",
                [packCoord(3, 2)] = "tile burnt door_4 wall_4 secdoor_0 door_6 wall_6 door_2",
                [packCoord(4, 2)] = "tile burnt secdoor_4 door_0 wall_0 door_6 wall_6 door_2",
                [packCoord(5, 2)] = "tile burnt door_4 wall_4 door_6 wall_6 door_0 door_2",
            })
    prefab = prefabs[23] -- [barrier_laser_6 facing=4]
    doPatchMatchTags(
            prefab, {
                [packCoord(2, 1)] = "tile burnt door_2 wall_2 door_4 wall_4 door_6 door_0",
                [packCoord(2, 2)] = "tile burnt door_6 wall_6 door_2 wall_2 door_4 wall_4 door_0",
                [packCoord(2, 3)] = "tile burnt door_6 wall_6 wall_2 door_4 wall_4 door_0",
                [packCoord(2, 5)] = "tile burnt door_6 wall_6 door_4 wall_4 door_2",
                [packCoord(1, 1)] = "tile burnt door_2 wall_2 door_0 wall_0 door_6",
                [packCoord(1, 3)] = "tile burnt door_6 wall_6 secdoor_2 door_0 wall_0 door_4",
                [packCoord(1, 4)] = "tile burnt secdoor_6 door_2 wall_2 door_0 wall_0 door_4",
                [packCoord(1, 5)] = "tile burnt door_6 wall_6 door_0 wall_0 door_2 door_4",
            })
    prefab = prefabs[24] -- [barrier_laser_6 facing=6]
    doPatchMatchTags(
            prefab, {
                [packCoord(5, 2)] = "tile burnt door_4 wall_4 door_6 wall_6 door_0 door_2",
                [packCoord(4, 2)] = "tile burnt door_0 wall_0 door_4 wall_4 door_6 wall_6 door_2",
                [packCoord(3, 2)] = "tile burnt door_0 wall_0 wall_4 door_6 wall_6 door_2",
                [packCoord(1, 2)] = "tile burnt door_0 wall_0 door_6 wall_6 door_4",
                [packCoord(5, 1)] = "tile burnt door_4 wall_4 door_2 wall_2 door_0",
                [packCoord(3, 1)] = "tile burnt door_0 wall_0 secdoor_4 door_2 wall_2 door_6",
                [packCoord(2, 1)] = "tile burnt secdoor_0 door_4 wall_4 door_2 wall_2 door_6",
                [packCoord(1, 1)] = "tile burnt door_0 wall_0 door_2 wall_2 door_4 door_6",
            })
end

local function resetPrefabs()
    package.loaded["sim/prefabs/shared/prefabt"] = nil
end

return {
    resetPrefabs = resetPrefabs,
    patchEntryGuard = patchEntryGuard,
    patchBarrierLaser = patchBarrierLaser,
}
