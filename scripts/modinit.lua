
local function earlyInit( modApi )
	modApi.requirements =
	{
		-- Core patches, that should generally load before anything else
		"Contingency Plan", "Sim Constructor", "Function Library",
		-- Escorts Fixed patches upvalues in mission_scoring.
		-- This needs to be done before any normal wrapping of the library.
		"Escorts Fixed",
		-- Items Evacutation overwrites the "escape" ability.
		"Items Evacuation",
		-- AGP overwrites Senses:addInterest.
		"Advanced Guard Protocol",
	}
end

local function init( modApi )
	local scriptPath = modApi:getScriptPath()
	local constants = include( scriptPath .. "/constants" )
	-- Store script path for cross-file includes
	rawset(_G,"SCRIPT_PATHS",rawget(_G,"SCRIPT_PATHS") or {})
	SCRIPT_PATHS.qoala_commbugfix = scriptPath

	-- Fixes for Mission-specific bugs.
	modApi:addGenerationOption("missiondetcenter_spawnagent", STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT,  STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_TIP, {
		noUpdate=true,
		values={
			constants.MISSIONDETCENTER_SPAWNAGENT.VANILLA,
			constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT,
			constants.MISSIONDETCENTER_SPAWNAGENT.FIFTYFIFTY,
		},
		value=constants.MISSIONDETCENTER_SPAWNAGENT.FIRSTAGENT,
		strings={
			STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_VANILLA,
			STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_FIRSTAGENT,
			STRINGS.COMMBUGFIX.OPTIONS.MISSIONDETCENTER_SPAWNAGENT_FIFTYFIFTY,
		}
	})
	modApi:addGenerationOption("missionvault_hackresponse", STRINGS.COMMBUGFIX.OPTIONS.MISSIONVAULT_HACKRESPONSE,  STRINGS.COMMBUGFIX.OPTIONS.MISSIONVAULT_HACKRESPONSE_TIP, {
		noUpdate=true,
		values={
			constants.MISSIONVAULT_HACKRESPONSE.VANILLA,
			constants.MISSIONVAULT_HACKRESPONSE.ANYHACK,
		},
		value=constants.MISSIONVAULT_HACKRESPONSE.ANYHACK,
		strings={
			STRINGS.COMMBUGFIX.OPTIONS.MISSIONVAULT_HACKRESPONSE_VANILLA,
			STRINGS.COMMBUGFIX.OPTIONS.MISSIONVAULT_HACKRESPONSE_ANYHACK,
		}
	})
	modApi:addGenerationOption("ending_remotehacking", STRINGS.COMMBUGFIX.OPTIONS.ENDING_REMOTEHACKING,  STRINGS.COMMBUGFIX.OPTIONS.ENDING_REMOTEHACKING_TIP, {noUpdate=true})
	-- Fixes for nopatrol trait (Prefab Stationary Guards)
	modApi:addGenerationOption("nopatrol_fixfacing", STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_FIXFACING,  STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_FIXFACING_TIP, {noUpdate=true})
	modApi:addGenerationOption("nopatrol_nopatrolchange", STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_NOPATROLCHANGE, STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_NOPATROLCHANGE_TIP, {noUpdate=true, enabled=false})
	-- Fixes for guard behavior bugs.
	modApi:addGenerationOption("idle_fixfailedpatrolpath", STRINGS.COMMBUGFIX.OPTIONS.IDLE_FIXFAILEDPATROLPATH, STRINGS.COMMBUGFIX.OPTIONS.IDLE_FIXFAILEDPATROLPATH_TIP, {
		noUpdate=true,
		values={
			constants.IDLE_FIXFAILEDPATROLPATH.DISABLED,
			constants.IDLE_FIXFAILEDPATROLPATH.STATIONARY,
			constants.IDLE_FIXFAILEDPATROLPATH.REGENERATE
		},
		value=constants.IDLE_FIXFAILEDPATROLPATH.REGENERATE,
		strings={
			STRINGS.COMMBUGFIX.OPTIONS.IDLE_FIXFAILEDPATROLPATH_DISABLED,
			STRINGS.COMMBUGFIX.OPTIONS.IDLE_FIXFAILEDPATROLPATH_STATIONARY,
			STRINGS.COMMBUGFIX.OPTIONS.IDLE_FIXFAILEDPATROLPATH_REGENERATE
		}
	})
	modApi:addGenerationOption("pathing_updateobserved", STRINGS.COMMBUGFIX.OPTIONS.PATHING_UPDATEOBSERVED,  STRINGS.COMMBUGFIX.OPTIONS.PATHING_UPDATEOBSERVED_TIP, {noUpdate=true})

	include( scriptPath .. "/include" )
	include( scriptPath .. "/engine" )
	include( scriptPath .. "/idle" )
	include( scriptPath .. "/mission_scoring" )
	include( scriptPath .. "/pcplayer" )
	include( scriptPath .. "/simactions" )
	include( scriptPath .. "/senses" )
	include( scriptPath .. "/missions/mission_detention_centre" )
	include( scriptPath .. "/missions/mission_vault" )
end

local function lateInit( modApi )
	local scriptPath = modApi:getScriptPath()

	-- nopatrol_nopatrolchange conditionally disables IdleSituation:generatePatrolPath.
	-- Override it in lateInit after any other mods have modified it in other ways.
	include( scriptPath .. "/idle_lateinit" )
end

local function load( modApi, options, params )
	local scriptPath = modApi:getScriptPath()

	local escape_mission = include( scriptPath .. "/missions/escape_mission" )
	modApi:addEscapeScripts(escape_mission)

	modApi:addAbilityDef( "activate_final_console", scriptPath .."/abilities/activate_final_console" )
	modApi:addAbilityDef( "activate_locked_console", scriptPath .."/abilities/activate_locked_console" )
	modApi:addAbilityDef( "escape", scriptPath .."/abilities/escape" )
	modApi:addAbilityDef( "jackin_root_console", scriptPath .."/abilities/jackin_root_console" )

	if options["ending_remotehacking"] and options["ending_remotehacking"].enabled and params then
		params.cbf_ending_remotehacking = true
	end
	if options["missiondetcenter_spawnagent"] and params then
		params.cbf_detention_spawnagent = options["missiondetcenter_spawnagent"].value
	end
	if options["missionvault_hackresponse"] and options["missionvault_hackresponse"].enabled and params then
		params.cbf_missionvault_hackresponse = true
	end
	if options["nopatrol_fixfacing"] and options["nopatrol_fixfacing"].enabled and params then
		params.cbf_nopatrol_fixfacing = true
	end
	if options["nopatrol_nopatrolchange"] and options["nopatrol_nopatrolchange"].enabled and params then
		params.cbf_nopatrol_nopatrolchange = true
	end
	if options["idle_fixfailedpatrolpath"] and params then
		params.cbf_idle_fixfailedpatrolpath = options["idle_fixfailedpatrolpath"].value
	end
	-- Store pathing flags in a single table, mapping a few user-visible options to potentially multiple fixes.
	-- If a suboption needs to be manually disabled in a save, set 'LOCK=true' to prevent game load from changing them.
	if params and (not params.cbf_pathing or not params.cbf_pathing.LOCK) then
		params.cbf_pathing = {}
		-- Cases where the guard path already updates when the guard's brain is fully evaluated (such as when acting during the guard turn).
		-- The player sees these as "the observed path lies about what will happen", not "the performed path makes no sense", even though the bug affects planned paths whether or not the player has observed those paths.
		if not options["pathing_updateobserved"] or options["pathing_updateobserved"].enabled then
			-- Update pathing immediately when the current interest moves (instead of waiting until the guard turn's full reprocessing)
			-- Fixes observed guard path not updating past the initial distraction when running/in peripheral vision for multiple tiles.
			params.cbf_pathing.reset_on_interest_moved = true
			-- During moveUnit on the PC turn, queue up pathing updates and only calculate the last update for each observing unit.
			-- Prevents lag from reset_on_interest_moved when moving multiple tiles past many guards.
			params.cbf_pathing.use_pathing_queue = true
		end
	end
end

local function initStrings( modApi )
	local dataPath = modApi:getDataPath()
	local scriptPath = modApi:getScriptPath()

	local MOD_STRINGS = include( scriptPath .. "/strings" )
	modApi:addStrings( dataPath, "COMMBUGFIX", MOD_STRINGS)
end

return {
    earlyInit = earlyInit,
    init = init,
	lateInit = lateInit,
    load = load,
    initStrings = initStrings,
}
