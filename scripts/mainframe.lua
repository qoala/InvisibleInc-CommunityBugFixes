local mainframe = include("sim/mainframe")

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")

local oldRevertIce = mainframe.revertIce
function mainframe.revertIce(sim, unit)
    oldRevertIce(sim, unit, ...)

    local fixEnabled = cbf_util.simCheckFlag(self:getSim(), "cbf_laserdragsymmetry")
    if not fixEnabled or not unit:isNPC() then
        return
    end
    if unit:getTraits().powerGrid and unit:getTraits().laser_gen then
        for i, u in pairs(sim:getAllUnits()) do
            if u ~= unit and u:getTraits().powerGrid then
                local owner = u:getPlayerOwner()
                if u:getTraits().powerGrid == unit:getTraits().powerGrid and not u:isNPC() then
                    u:takeControl(sim:getNPC())
                    player:glimpseUnit(sim, u:getID())
                end
            end
        end
    end
end
