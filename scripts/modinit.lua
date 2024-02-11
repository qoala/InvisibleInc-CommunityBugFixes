local MOD_VERSION = "1.14.0"

-- ===

local function findModByName(name)
    for i, modData in ipairs(mod_manager.mods) do
        if name and modData.name == name then
            return modData
        end
    end
end

-- ===

local function earlyInit(modApi)
    modApi.requirements = {
        -- Core patches, that should generally load before anything else
        "Contingency Plan",
        "Sim Constructor",
        "Function Library",
        -- Escorts Fixed patches upvalues in mission_scoring.
        -- This needs to be done before any normal wrapping of the library.
        "Escorts Fixed", -- Items Evacutation overwrites the "escape" ability.
        "Items Evacuation", -- AGP overwrites Senses:addInterest, line_of_sight:calculateUnitLOS.
        "Advanced Guard Protocol",
        -- Talkative Agents adds event handlers to mission_panel:processEvent in lateInit.
        "Talkative Agents",
    }
end

local function init(modApi)
    local scriptPath = modApi:getScriptPath()
    local constants = include(scriptPath .. "/constants")
    -- Store script path for cross-file includes
    rawset(_G, "SCRIPT_PATHS", rawget(_G, "SCRIPT_PATHS") or {})
    SCRIPT_PATHS.qoala_commbugfix = scriptPath

    -- General Fixes
    modApi:addGenerationOption(
            "generalfixes", STRINGS.COMMBUGFIX.OPTIONS.GENERALFIXES,
            STRINGS.COMMBUGFIX.OPTIONS.GENERALFIXES_TIP,
            {noUpdate = true, masks = {{mask = "mask_cbf_generalfixes", requirement = true}}})
    modApi:addGenerationOption(
            "autoupdate", STRINGS.COMMBUGFIX.OPTIONS.AUTOUPDATE,
            STRINGS.COMMBUGFIX.OPTIONS.AUTOUPDATE_TIP, {
                noUpdate = true,
                requirements = {{mask = "mask_cbf_generalfixes", requirement = true}},
            })
    -- Configurable Fixes
    modApi:addGenerationOption(
            "escorts_remove_owned_items", STRINGS.COMMBUGFIX.OPTIONS.ESCORTS_ITEMS,
            STRINGS.COMMBUGFIX.OPTIONS.ESCORTS_ITEMS_TIP, {
                noUpdate = true,
                requirements = {{mask = "mask_cbf_generalfixes", requirement = true}},
            })
    modApi:addGenerationOption(
            "missiondetcenter_spawnagent", STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT,
            STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_TIP, {
                noUpdate = true,
                values = {
                    constants.MISSIONDETCENTER_SPAWNAGENT.ALWAYS,
                    constants.MISSIONDETCENTER_SPAWNAGENT.VANILLA,
                    constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT,
                    constants.MISSIONDETCENTER_SPAWNAGENT.FIFTYFIFTY,
                },
                value = constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT,
                strings = {
                    STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_ALWAYS,
                    STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_VANILLA,
                    STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_FIRSTAGENT,
                    STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_FIFTYFIFTY,
                },
            })
    modApi:addGenerationOption(
            "holowallsounds", STRINGS.COMMBUGFIX.OPTIONS.HOLOWALLSOUNDS,
            STRINGS.COMMBUGFIX.OPTIONS.HOLOWALLSOUNDS_TIP, {
                noUpdate = true,
                values = {
                    constants.HOLOWALLSOUNDS.VANILLA,
                    constants.HOLOWALLSOUNDS.NOTICE,
                    constants.HOLOWALLSOUNDS.IGNORE,
                },
                value = constants.HOLOWALLSOUNDS.NOTICE,
                strings = {
                    STRINGS.COMMBUGFIX.OPTIONS.HOLOWALLSOUNDS_VANILLA,
                    STRINGS.COMMBUGFIX.OPTIONS.HOLOWALLSOUNDS_NOTICE,
                    STRINGS.COMMBUGFIX.OPTIONS.HOLOWALLSOUNDS_IGNORE,
                },
            })

    local dataPath = modApi:getDataPath()
    KLEIResourceMgr.MountPackage(dataPath .. "/gui.kwad", "data")

    include(scriptPath .. "/include")
    include(scriptPath .. "/cbf_util")
    include(scriptPath .. "/rand")
    include(scriptPath .. "/simdefs")
    include(scriptPath .. "/engine")

    -- Extract upvalue after Function Library potentially replaces the target function entirely.
    include(scriptPath .. "/mission_scoring_upvalues")

    include(scriptPath .. "/simplayer")
    include(scriptPath .. "/pcplayer")

    include(scriptPath .. "/hud")
    include(scriptPath .. "/hunt")
    include(scriptPath .. "/idle")
    include(scriptPath .. "/inventory")
    include(scriptPath .. "/investigate")
    include(scriptPath .. "/items_panel")
    include(scriptPath .. "/laser")
    include(scriptPath .. "/mission_scoring")
    include(scriptPath .. "/simactions")
    include(scriptPath .. "/simquery")
    include(scriptPath .. "/simunit")
    include(scriptPath .. "/senses")
    include(scriptPath .. "/smokerig")
    include(scriptPath .. "/state-map-screen")
    include(scriptPath .. "/missions/mission_detention_centre")
    include(scriptPath .. "/missions/mission_vault")
    include(scriptPath .. "/units/cbf_smoke_edge")
    include(scriptPath .. "/units/simdisguiseitem")
    include(scriptPath .. "/units/smoke_cloud")

    -- Ability patches. (Abilities are NOT reloaded on load)
    include(scriptPath .. "/abilities/open_detention_cells").patchAbility()
    include(scriptPath .. "/abilities/open_security_boxes").patchAbility()
    include(scriptPath .. "/abilities/peek").patchPeek()

end

local function lateInit(modApi)
    local scriptPath = modApi:getScriptPath()

    -- nopatrol_nopatrolchange conditionally disables IdleSituation:generatePatrolPath.
    -- Override it in lateInit after any other mods have modified it in other ways.
    include(scriptPath .. "/idle_lateinit")

    -- AGP overrides line_of_sight:calculateUnitLOS during lateInit.
    include(scriptPath .. "/line_of_sight")

    -- Conditionally pauses the event queue. Needs to wrap after Talkative Agents adds additional event handlers.
    include(scriptPath .. "/mission_panel")
end

local function earlyUnload(modApi)
    local scriptPath = modApi:getScriptPath()

    local patch_animdefs = include(scriptPath .. "/patch_animdefs")
    patch_animdefs.resetAnimdefs()

    local patch_itemdefs = include(scriptPath .. "/patch_itemdefs")
    patch_itemdefs.resetEndingFinalDoor()

    local patch_skilldefs = include(scriptPath .. "/patch_skilldefs")
    patch_skilldefs.resetSkills()
end

local function earlyLoad(modApi, options, params)
    earlyUnload(modApi)
end

local firstTimeLoad = true
local function load(modApi, options, params, mod_options)
    local scriptPath = modApi:getScriptPath()
    local constants = include(scriptPath .. "/constants")

    if firstTimeLoad then
        firstTimeLoad = false
        local dlc = findModByName("Contingency Plan")
        if dlc then
            -- Abilities are not reset by load, but DLC adds them at load time.
            include(scriptPath .. "/abilities/activate_refit_drone").patchAbility()
            include(scriptPath .. "/abilities/databank_hack").patchAbility()
            include(scriptPath .. "/abilities/multiUnlock").patchAbility()
            include(scriptPath .. "/abilities/transformer_terminal").patchAbility()
            include(scriptPath .. "/abilities/transformer_terminal_buy_PWR").patchAbility()
        end
    end

    -- -----
    -- Options Handling
    -- -----

    if params then
        params.cbf_params = {}

        -- Fixes that should never need to be disabled, but respect if the mod is disabled. Just in case.
        params.cbf_params.cbf_inventory_recheckoverwatchondrop = true
    end

    local legacyMode = not options["generalfixes"] -- Loading a save that predates cbf_params.
    local generalFixesEnabled = options["generalfixes"] and options["generalfixes"].enabled

    -- Write a table into this mod's campaign options.
    -- params are accessible in-game, but not during earlyLoad/load/lateLoad when loading an existing save.
    -- This helps ensure params and associated conditional patches are kept in sync across mod updates.
    if params then
        options.cbf_params = {}

        params.cbf_params.cbf_version = MOD_VERSION
        options.cbf_params.cbf_version = MOD_VERSION

        log:write("CBF loading for new save: v%s", MOD_VERSION)
    elseif options.cbf_params then
        log:write(
                "CBF loading for existing save: running=v%s original=v%s", MOD_VERSION,
                options.cbf_params.cbf_version)
    elseif legacyMode then
        log:write("CBF loading for existing save: running=v%s original=[legacy]", MOD_VERSION)
    end

    if generalFixesEnabled and params then
        params.cbf_params.cbf_rand = true

        -- Mission Bugs
        params.cbf_params.cbf_ending_finaldoor = true
        options.cbf_params.cbf_ending_finaldoor = true
        params.cbf_params.cbf_ending_incognitadrop = true
        params.cbf_params.cbf_ending_remotehacking = true
        params.cbf_params.cbf_missionvault_hackresponse = true

        -- Guard Bugs
        params.cbf_params.cbf_nopatrol_fixfacing = true
        params.cbf_params.cbf_idle_fixfailedpatrolpath =
                constants.IDLE_FIXFAILEDPATROLPATH.REGENERATE
        params.cbf_params.cbf_ignoresleepingtag = true
        params.cbf_params.cbf_fixmagicsight = true
        params.cbf_params.cbf_pulsereact = true
        params.cbf_params.cbf_disguisefix_pathing = true
        params.cbf_params.cbf_smoke_dynamicedges = true
        params.cbf_params.cbf_smoke_rememberedges = true
        params.cbf_params.cbf_fixsharedinterest = true

        -- Pathing Bugs
        params.cbf_params.cbf_pathing = {}
        -- Update pathing immediately when the current interest moves (instead of waiting until the guard turn's full reprocessing)
        -- Fixes observed guard path not updating past the initial distraction when running/in peripheral vision for multiple tiles.
        params.cbf_params.cbf_pathing.reset_on_interest_moved = true
        -- During moveUnit on the PC turn, queue up pathing updates and only calculate the last update for each observing unit.
        -- Prevents lag from reset_on_interest_moved when moving multiple tiles past many guards.
        -- DISABLED: AGP recalculates paths continuously without ill effect. Delayed update queue may be unnecessary.
        params.cbf_params.cbf_pathing.use_pathing_queue = false

        -- Agent-related Bugs
        params.cbf_params.cbf_agent_drillmodtrait = true
        options.cbf_params.cbf_agent_speed5 = true
        params.cbf_params.cbf_flurry_reset = true

        -- Program-related Bugs
        params.cbf_params.cbf_cycletiming = true

        -- Misc Bugs
        params.cbf_params.cbf_laserdragsymmetry = true
        params.cbf_params.cbf_laserdaemons = true

        -- Escorts Fixed
        local externalEscortsFixed = false
        do
            local ef = findModByName("Escorts Fixed")
            if ef and mod_options[ef.id] then
                local efOptions = mod_options[ef.id]
                if efOptions.enabled and efOptions.options["escort_fix"] and
                        efOptions.options["escort_fix"].enabled then
                    -- Disable CBF Escorts Fixed, to avoid interference with the original Escorts Fixed mod.
                    externalEscortsFixed = true
                end
            end
        end
        if not externalEscortsFixed then
            params.cbf_params.cbf_escorts_fixed = true
            options.cbf_params.cbf_escorts_fixed = true
            params.cbf_params.cbf_escorts_remove_owned_items =
                    options["escorts_remove_owned_items"] and
                            options["escorts_remove_owned_items"].enabled
            options.cbf_params.cbf_escorts_remove_owned_items = params.cbf_params
                                                                        .cbf_escorts_remove_owned_items
        end
    end

    if options["autoupdate"] and params then
        params.cbf_params.cbf_autoupdate = options["autoupdate"].enabled
    end
    if options["missiondetcenter_spawnagent"] and params then
        params.cbf_params.cbf_detention_spawnagent = options["missiondetcenter_spawnagent"].value
    end
    if options["holowallsounds"] and params then
        params.cbf_params.cbf_holowallsounds = options["holowallsounds"].value
    end

    -- -----
    -- Patching/Loading
    -- -----

    if options.cbf_params or legacyMode then
        -- Always-enabled fixes / fixes that can check params at runtime

        local escape_mission = include(scriptPath .. "/missions/escape_mission")
        modApi:addEscapeScripts(escape_mission)

        modApi:addAbilityDef(
                "activate_final_console", scriptPath .. "/abilities/activate_final_console")
        modApi:addAbilityDef(
                "activate_locked_console", scriptPath .. "/abilities/activate_locked_console")
        modApi:addAbilityDef("carryable", scriptPath .. "/abilities/carryable")
        modApi:addAbilityDef("disarmtrap", scriptPath .. "/abilities/disarmtrap")
        modApi:addAbilityDef("doorMechanism", scriptPath .. "/abilities/doorMechanism")
        modApi:addAbilityDef("escape", scriptPath .. "/abilities/escape")
        modApi:addAbilityDef("jackin_root_console", scriptPath .. "/abilities/jackin_root_console")
        modApi:addAbilityDef("prime_emp", scriptPath .. "/abilities/prime_emp")

        local patch_animdefs = include(scriptPath .. "/patch_animdefs")
        patch_animdefs.updateAnimdefs()
    end

    if options.cbf_params and options.cbf_params.cbf_escorts_fixed then
        local patch_upgradedefs = include(scriptPath .. "/patch_upgradedefs")
        patch_upgradedefs.addEscortsFixed()

        -- Other mods look for these to see that Escorts Fixed is enabled
        modApi:addGuardDef("ef_dummy", {name = "Dummy", traits = {}})
        modApi:addGuardDef("ef_memory", {name = "Dummy", traits = {}})
        if options.cbf_params.cbf_escorts_remove_owned_items then
            modApi:addGuardDef("ef_pilfer", {name = "Dummy", traits = {}})
        end
    end

    -- Check for legacy option, in case of a save predating cbf_params
    local patch_itemdefs = include(scriptPath .. "/patch_itemdefs")
    if (options.cbf_params and options.cbf_params.cbf_ending_finaldoor) or
            (legacyMode and options["ending_finaldoor"] and options["ending_finaldoor"].enabled) then
        patch_itemdefs.updateEndingFinalDoor()
    else
        patch_itemdefs.resetEndingFinalDoor()
    end

    patch_itemdefs.patchVentricularLanceRecharge(modApi)
end

local function initStrings(modApi)
    local dataPath = modApi:getDataPath()
    local scriptPath = modApi:getScriptPath()

    local MOD_STRINGS = include(scriptPath .. "/strings")
    modApi:addStrings(dataPath, "COMMBUGFIX", MOD_STRINGS)

    include(scriptPath .. "/patch_strings")
end

local function lateLoad(modApi, options, params)
    local scriptPath = modApi:getScriptPath()

    if options.cbf_params and options.cbf_params.cbf_agent_speed5 then
        local patch_skilldefs = include(scriptPath .. "/patch_skilldefs")
        patch_skilldefs.updateSkills()
    end

    local patch_itemdefs = include(scriptPath .. "/patch_itemdefs")
    patch_itemdefs.latePatchVentricularLanceRecharge(modApi)
    patch_itemdefs.latePatchShirshScanGrenades(modApi)

    for name, def in pairs(include(scriptPath .. "/propdefs").createLateDefs()) do
        modApi:addPropDef(name, def, false)
    end
end

return {
    earlyInit = earlyInit,
    init = init,
    lateInit = lateInit,
    earlyLoad = earlyLoad,
    earlyUnload = earlyUnload,
    load = load,
    lateLoad = lateLoad,
    initStrings = initStrings,
}
