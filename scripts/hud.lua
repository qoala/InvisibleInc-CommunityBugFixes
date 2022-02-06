
local util = include( "client_util" )
local hud = include( "hud/hud" )
local alarm_states = include( "sim/alarm_states" )
local simdefs = include( "sim/simdefs" )

-- Extract a local variable from the given function's upvalues
function extractUpvalue( fn, name )
	local i = 1
	while true do
		local n, v = debug.getupvalue(fn, i)
		assert(n, string.format( "Could not find upvalue: %s", name ) )
		if n == name then
			return v, i
		end
		i = i + 1
	end
end

local oldCreateHud = hud.createHud
function hud.createHud( ... )
	local hudObject = oldCreateHud( ... )

	local oldRefreshTrackerAdvance, i = extractUpvalue( hudObject.refreshHud, "refreshTrackerAdvance" )
	local callRefreshTrackerAdvance = function ( self, number, ... ) return self:refreshTrackerAdvance( number, ... ) end
	debug.setupvalue( hudObject.refreshHud, i, callRefreshTrackerAdvance)

	-- Parameterize the number of steps per alarm stage in the tooltip
	local ALARM_TOOLTIP = string.gsub(STRINGS.UI.ALARM_TOOLTIP, "5", "{1}")
	local ADVANCED_ALARM_TOOLTIP = string.gsub(STRINGS.UI.ADVANCED_ALARM_TOOLTIP, "5", "{1}")

	function hudObject:refreshTrackerAdvance( trackerNumber, ... )
		oldRefreshTrackerAdvance( self, trackerNumber, ... )

		-- ====
		-- Modified copy of vanilla calculation for the tooltip. Changes at CBF.
		-- ====
		local stage = self._game.simCore:getTrackerStage( math.min( simdefs.TRACKER_MAXCOUNT, trackerNumber ))
		local params = self._game.params

		-- CBF: default to ALARM_TOOLTIP, not ADVANCED_ALARM_TOOLTIP
		-- CBF: use paramaterized versions of the tooltips
		local tip = util.sformat( ALARM_TOOLTIP, simdefs.TRACKER_INCREMENT )
		if params.missionEvents and params.missionEvents.advancedAlarm then
			tip = util.sformat( ADVANCED_ALARM_TOOLTIP, simdefs.TRACKER_INCREMENT )
		end

		local alarmList = self._game.simCore:getAlarmTypes()
		local next_alarm = simdefs.ALARM_TYPES[alarmList][stage+1]

		if next_alarm then
			tip = tip .. alarm_states.alarm_level_tips[next_alarm]
		else
			tip = tip .. STRINGS.UI.ALARM_NEXT_AFTER_SIX
		end

		self._screen.binder.alarm:setTooltip(tip)
	end

	return hudObject
end
