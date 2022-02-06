
local hud = include( "hud/hud" )
local alarm_states = include( "sim/alarm_states" )
local simdefs = include( "sim/simdefs" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

local oldCreateHud = hud.createHud
function hud.createHud( ... )
	local hudObject = oldCreateHud( ... )

	local oldRefreshTrackerAdvance, i = cbf_util.extractUpvalue( hudObject.refreshHud, "refreshTrackerAdvance" )
	local callRefreshTrackerAdvance = function ( self, number, ... ) return self:refreshTrackerAdvance( number, ... ) end
	debug.setupvalue( hudObject.refreshHud, i, callRefreshTrackerAdvance)

	function hudObject:refreshTrackerAdvance( trackerNumber, ... )
		oldRefreshTrackerAdvance( self, trackerNumber, ... )

		-- ====
		-- Modified copy of vanilla calculation for the tooltip
		-- ====
		local stage = self._game.simCore:getTrackerStage( math.min( simdefs.TRACKER_MAXCOUNT, trackerNumber ))
		local params = self._game.params

		-- CBF: default to ALARM_TOOLTIP, not ADVANCED_ALARM_TOOLTIP
		local tip = STRINGS.UI.ALARM_TOOLTIP
		if params.missionEvents and params.missionEvents.advancedAlarm then
			tip =STRINGS.UI.ADVANCED_ALARM_TOOLTIP
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
