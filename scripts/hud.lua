local util = include("client_util")
local hud = include("hud/hud")
local alarm_states = include("sim/alarm_states")
local simdefs = include("sim/simdefs")

local oldCreateHud = hud.createHud
function hud.createHud(...)
    local hudObject = oldCreateHud(...)

    -- Parameterize the number of steps per alarm stage in the tooltip
    local ALARM_TOOLTIP = string.gsub(STRINGS.UI.ALARM_TOOLTIP, "5", "{1}")
    local ADVANCED_ALARM_TOOLTIP = string.gsub(STRINGS.UI.ADVANCED_ALARM_TOOLTIP, "5", "{1}")

    local oldSetTooltip = hudObject._screen.binder.alarm.setTooltip
    function hudObject._screen.binder.alarm:setTooltip(tip)
        local params = hudObject._game.params

        -- Use ALARM_TOOLTIP when appropriate, instead of always using ADVANCED_ALARM_TOOLTIP
        local newTip = nil
        if params.missionEvents and params.missionEvents.advancedAlarm then
            newTip = util.sformat(ADVANCED_ALARM_TOOLTIP, simdefs.TRACKER_INCREMENT)
        else
            newTip = util.sformat(ALARM_TOOLTIP, simdefs.TRACKER_INCREMENT)
        end
        tip = string.gsub(tip, STRINGS.UI.ADVANCED_ALARM_TOOLTIP, newTip)

        oldSetTooltip(self, tip)
    end

    return hudObject
end
