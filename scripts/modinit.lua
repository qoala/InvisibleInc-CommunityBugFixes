
local function earlyInit( modApi )
	modApi.requirements = { "Contingency Plan", "Sim Constructor", "Function Library" }
end

local function init( modApi )
	local scriptPath = modApi:getScriptPath()

	-- Fixes for nopatrol trait (Prefab Stationary Guards)
	modApi:addGenerationOption("nopatrol_fixfacing", STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_FIXFACING,  STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_FIXFACING_TIP, {noUpdate=true})
	modApi:addGenerationOption("nopatrol_nopatrolchange", STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_NOPATROLCHANGE, STRINGS.COMMBUGFIX.OPTIONS.NOPATROL_NOPATROLCHANGE_TIP, {noUpdate=true})

	include( scriptPath .. "/engine" )
end

local function lateInit( modApi )
	local scriptPath = modApi:getScriptPath()

	-- nopatrol_nopatrolchange conditionally disables IdleSituation:generatePatrolPath.
	-- Override it in lateInit after any other mods have modified it in other ways.
	include( scriptPath .. "/idle" )
end

local function load( modApi, options, params )
	if options["nopatrol_fixfacing"] and options["nopatrol_fixfacing"].enabled and params then
		params.cbf_nopatrol_fixfacing = true
	end
	if options["nopatrol_nopatrolchange"] and options["nopatrol_nopatrolchange"].enabled and params then
		params.cbf_nopatrol_nopatrolchange = true
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
