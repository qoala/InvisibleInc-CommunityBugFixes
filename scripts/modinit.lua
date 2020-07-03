
local function earlyInit( modApi )
	modApi.requirements =
	{
		-- Core patches, that should generally load before anything else
		"Contingency Plan", "Sim Constructor", "Function Library",
		-- Escorts Fixed patches upvalues in mission_scoring.
		-- This needs to be done before any normal wrapping of the library.
		"Escorts Fixed",
	}
end

local function init( modApi )
	local scriptPath = modApi:getScriptPath()
	local constants = include( scriptPath .. "/constants" )
	-- Store script path for cross-file includes
	rawset(_G,"SCRIPT_PATHS",rawget(_G,"SCRIPT_PATHS") or {})
	SCRIPT_PATHS.qoala_commbugfix = scriptPath

	-- Fixes for nopatrol trait (Prefab Stationary Guards)
	modApi:addGenerationOption("nopatrol_fixfacing", STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_FIXFACING,  STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_FIXFACING_TIP, {noUpdate=true})
	modApi:addGenerationOption("nopatrol_nopatrolchange", STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_NOPATROLCHANGE, STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_NOPATROLCHANGE_TIP, {noUpdate=true})
	-- Fixes for IdleSituation guard behavior bugs.
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

	include( scriptPath .. "/engine" )
	include( scriptPath .. "/idle" )
	include( scriptPath .. "/mission_scoring" )
	include( scriptPath .. "/pcplayer" )
end

local function lateInit( modApi )
	local scriptPath = modApi:getScriptPath()

	-- nopatrol_nopatrolchange conditionally disables IdleSituation:generatePatrolPath.
	-- Override it in lateInit after any other mods have modified it in other ways.
	include( scriptPath .. "/idle_lateinit" )
end

local function load( modApi, options, params )
	if options["nopatrol_fixfacing"] and options["nopatrol_fixfacing"].enabled and params then
		params.cbf_nopatrol_fixfacing = true
	end
	if options["nopatrol_nopatrolchange"] and options["nopatrol_nopatrolchange"].enabled and params then
		params.cbf_nopatrol_nopatrolchange = true
	end
	if options["idle_fixfailedpatrolpath"] and params then
		params.cbf_idle_fixfailedpatrolpath = options["idle_fixfailedpatrolpath"].value
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
