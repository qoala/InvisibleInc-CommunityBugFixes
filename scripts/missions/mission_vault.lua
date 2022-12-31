-- patch to sim/missions/mission_vault.lua
local array = include("modules/array")
local util = include("modules/util")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cdefs = include("client_defs")
local mission_util = include("sim/missions/mission_util")
local escape_mission = include("sim/missions/escape_mission")
local simfactory = include("sim/simfactory")
local unitdefs = include("sim/unitdefs")
local itemdefs = include("sim/unitdefs/itemdefs")
local mission_vault = include("sim/missions/mission_vault")
local SCRIPTS = include('client/story_scripts')

local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")
local constants = include(SCRIPT_PATHS.qoala_commbugfix .. "/constants")

local oldInit = mission_vault.init

-- Vault-device fully hacked by any source
local HACK_VAULT_ANY = {
    trigger = simdefs.TRG_ICE_BROKEN,
    fn = function(sim, evData)
        local unit = evData.unit
        if not unit or not unit:hasTag("vault") then
            return false
        end

        if unit:getTraits().mainframe_ice <= 0 then
            return unit
        end
    end,
}

-- Replacement hook for security response when a vault device has been completely hacked
local function hackvault(script, sim, mission)
    local _, vault = script:waitFor(HACK_VAULT_ANY)

    mission.hacked_vault = true
    -- spawn an enforcer
    sim:dispatchEvent(simdefs.EV_SCRIPT_EXIT_MAINFRAME)
    local x, y = vault:getLocation()
    local newGuards = sim:getNPC():spawnGuards(sim, simdefs.TRACKER_SPAWN_UNIT_ENFORCER, 1)
    for i, newUnit in ipairs(newGuards) do
        newUnit:getBrain():spawnInterest(x, y, simdefs.SENSE_RADIO, simdefs.REASON_REINFORCEMENTS)
    end

    script:waitFrames(1.0 * cdefs.SECONDS)

    script:queue({type = "pan", x = x, y = y})
    script:waitFrames(.25 * cdefs.SECONDS)

    script:queue(
            {
                script = SCRIPTS.INGAME.AFTERMATH.VAULT[sim:nextRand(
                        1, #SCRIPTS.INGAME.AFTERMATH.VAULT)],
                type = "newOperatorMessage",
            })
end

local function removeHookByName(scriptMgr, name)
    for i, hook in ipairs(scriptMgr.hooks) do
        if hook.name == name then
            scriptMgr:removeHook(hook)
            break
        end
    end
end

function mission_vault:init(scriptMgr, sim)
    oldInit(self, scriptMgr, sim)

    local hackResponseOption = cbf_util.simCheckFlag(
            sim, "cbf_missionvault_hackresponse", constants.MISSIONVAULT_HACKRESPONSE.VANILLA)
    if hackResponseOption ~= constants.MISSIONVAULT_HACKRESPONSE.VANILLA then
        removeHookByName(scriptMgr, "VAULT-LOOT")
        scriptMgr:addHook("VAULT-HACK-FIXED", hackvault, nil, self)
    end
end
