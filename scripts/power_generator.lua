-- patch to sim/units/power_generator
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local power_generator = include("sim/units/power_generator")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

-- sim/units/laser doesn't export the class, unlike most unit class files, and the exported function was registered as a local, so can't be appended.
-- Use debug.getupvalue to extract the class table
if not power_generator.turret_generator then
    power_generator.turret_generator = cbf_util.extractUpvalue(
            power_generator.createTurretGenerator, "turret_generator")
end
if not power_generator.laser_generator then
    power_generator.laser_generator = cbf_util.extractUpvalue(
            power_generator.createLaserGenerator, "laser_generator")
end
if not power_generator.power_generator then
    power_generator.power_generator = power_generator.laser_generator and
                                              power_generator.laser_generator._base
end
