local simdefs = include("sim/simdefs")

simdefs.DIRMASK_E = 1
simdefs.DIRMASK_NE = 2
simdefs.DIRMASK_N = 4
simdefs.DIRMASK_NW = 8
simdefs.DIRMASK_W = 16
simdefs.DIRMASK_SW = 32
simdefs.DIRMASK_S = 64
simdefs.DIRMASK_SE = 128

simdefs._DIRMASK_MAP = {
    [simdefs.DIR_E] = simdefs.DIRMASK_E,
    [simdefs.DIR_NE] = simdefs.DIRMASK_NE,
    [simdefs.DIR_N] = simdefs.DIRMASK_N,
    [simdefs.DIR_NW] = simdefs.DIRMASK_NW,
    [simdefs.DIR_W] = simdefs.DIRMASK_W,
    [simdefs.DIR_SW] = simdefs.DIRMASK_SW,
    [simdefs.DIR_S] = simdefs.DIRMASK_S,
    [simdefs.DIR_SE] = simdefs.DIRMASK_SE,
}
function simdefs:maskFromDir(dir)
    return self._DIRMASK_MAP[dir]
end
