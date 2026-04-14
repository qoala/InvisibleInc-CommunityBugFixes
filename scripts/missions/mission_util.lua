local mission_util = include("sim/missions/mission_util")
local util = include("client_util")
local simdefs = include("sim/simdefs")

-- the viz handler for the event also checks for pc:isNeutralized.
-- so simply retiring will not cause the prompt to appear
local oldinit = mission_util.campaign_mission.init
function mission_util.campaign_mission:init(scriptMgr, ...)
	oldinit(self, scriptMgr, ...)
	scriptMgr:addHook("CBF_GAMEOVER", function(script, sim)
		script:waitFor(util.extend(mission_util.PC_LOST)({ priority = 1 }))
		if sim:getTags().cbf_got_rewind_prompt ~= sim:getActionCount() then
			sim:dispatchEvent(simdefs.EV_SHOW_MODAL_REWIND)
		end
	end, true)
end