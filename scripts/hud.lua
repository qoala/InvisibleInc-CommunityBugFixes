
local util = include( "client_util" )
local hud = include( "hud/hud" )
local alarm_states = include( "sim/alarm_states" )
local simdefs = include( "sim/simdefs" )

local oldCreateHud = hud.createHud
function hud.createHud( ... )
	local hudObject = oldCreateHud( ... )

	-- Parameterize the number of steps per alarm stage in the tooltip
	local ALARM_TOOLTIP = string.gsub(STRINGS.UI.ALARM_TOOLTIP, "5", "{1}")
	local ADVANCED_ALARM_TOOLTIP = string.gsub(STRINGS.UI.ADVANCED_ALARM_TOOLTIP, "5", "{1}")

	local function refreshAlarmTooltip( self, trackerNumber, ... )
		-- ====
		-- Modified copy of vanilla calculation from refreshTrackerAdvance. Changes at CBF.
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

	local oldRefreshHud = hudObject.refreshHud
	function hudObject:refreshHud( ... )
		oldRefreshHud( self, ... )
		refreshAlarmTooltip( self, self._game.simCore:getTracker() )
	end

	local function noOp()
	end

	local oldOnSimEvent = hudObject.onSimEvent
	function hudObject:onSimEvent( ev, ... )
		local oldSetTooltip = self._screen.binder.alarm.setTooltip
		if ev.eventType == simdefs.EV_ADVANCE_TRACKER and not ev.eventData.alarmOnly then
			self._screen.binder.alarm.setTooltip = noOp
		end

		local result = oldOnSimEvent( self, ev, ... )

		if ev.eventType == simdefs.EV_ADVANCE_TRACKER and not ev.eventData.alarmOnly then
			self._screen.binder.alarm.setTooltip = oldSetTooltip
			refreshAlarmTooltip( self, ev.eventData.tracker + ev.eventData.delta )
		end

		return result
	end

	return hudObject
end
