local rand = include("modules/rand")

---

local function genNext(self)
    -- http://remus.rutgers.edu/~rhoads/Code/random.c
    -- LUA:
    -- Our assumption is that double-precision is encoded with 64 bits (according to IEEE 754)
    -- We have enough precision to handle all 32 bit unsigned integer representations, and calculate
    -- modulo 2^32 to generate single-point precision random values.

    local a, m, q, r1, r2 = 1588635695, 4294967291, 2, 17054, 44957
    local s1, s2 = math.floor(self._seed / (2^17)), (math.floor(self._seed / 2) % (2^16))
    local p = (r2 * s2) + (2^16) * r1 * s2 + (2^16) * r2 * s1 -- r1 * s1 are MSB and discarded
    self._seed = a*(self._seed % q) - p
    self._seed = self._seed % (2^32)
    return self._seed / m
end

---

local oldCreateGenerator = rand.createGenerator

-- CBF: 'forceLegacy' restores vanilla behavior if true.
-- All non-simengine calls are irrelevant for save-compatibility, so apply fix by default.
-- simengine will pass true/false based on campaign flags.
function rand.createGenerator(seed, forceLegacy)
    local gen = oldCreateGenerator(seed)

    if not forceLegacy then
        gen.next = genNext
	else
		simlog("QDBG: old rand")
    end

    return gen
end

