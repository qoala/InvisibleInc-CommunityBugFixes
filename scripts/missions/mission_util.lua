local mission_util = include("sim/missions/mission_util")
local util = include("client_util")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")

-- the viz handler for the event also checks for pc:isNeutralized.
-- so simply retiring will not cause the prompt to appear
local oldinit = mission_util.campaign_mission.init
function mission_util.campaign_mission:init(scriptMgr, ...)
    oldinit(self, scriptMgr, ...)
    scriptMgr:addHook(
            "CBF_GAMEOVER", function(script, sim)
                script:waitFor(util.extend(mission_util.PC_LOST)({priority = 1}))
                if sim:getTags().cbf_got_rewind_prompt ~= sim:getActionCount() then
                    sim:dispatchEvent(simdefs.EV_SHOW_MODAL_REWIND)
                end
            end, true)
end

-- vanilla checks if the seer is a PC unit, but it doesn't trigger for hacked cameras because they could already see the unit before
-- wait for the pc player as seer instead and search for a pc seer unit if the trigger needs one
-- (this was also a bug with TRG_LOS_REFRESH not being fired for cameras but that one is fixed in simunit.setPlayerOwner)
mission_util.PC_SAW_UNIT = function(tag)
	return {
		trigger = simdefs.TRG_UNIT_APPEARED,
		fn = function(sim, evData)
			local seer = sim:getPlayerByID(evData.seerID)
			if not seer or not seer:isPC() then
				return false
			end

			if not tag or evData.unit:hasTag(tag) then
				local x, y = evData.unit:getLocation()
				if x then
					for _, seerUnit in ipairs(seer:getUnits()) do
						-- don't use sim:canUnitSeeUnit or unit:getSeenUnits
						-- sim:notifySeers updates units after players so they are not updated yet
						-- (sim:refreshUnitLOS does it in reverse order...)
						if sim:canUnitSee(seerUnit, x, y) and simquery.couldUnitSee(sim, seerUnit, evData.unit) then
							return evData.unit, seerUnit
						end
					end
				end
			end
			return false
		end,
	}
end
mission_util.PC_SAW_UNIT_WITH_MARKER = function(script, tag, marker)
	return {
		trigger = simdefs.TRG_UNIT_APPEARED,
		fn = function(sim, evData)
			local seer = sim:getPlayerByID(evData.seerID)
			if not seer or not seer:isPC() then
				return false
			end

			if (not tag or evData.unit:hasTag(tag)) and sim:getCurrentPlayer() == seer then
				local x, y = evData.unit:getLocation()
				script:queue({ type = "displayHUDInstruction", text = marker, x = x, y = y })
				return true
			else
				return false
			end
		end,
	}
end
mission_util.PC_SAW_UNIT_WITH_TRAIT = function(trait)
	return {
		trigger = simdefs.TRG_UNIT_APPEARED,
		fn = function(sim, evData)
			local seer = sim:getPlayerByID(evData.seerID)
			if not seer or not seer:isPC() then
				return false
			end

			if trait and evData.unit:getTraits()[trait] then
				local x, y = evData.unit:getLocation()
				if x then
					for _, seerUnit in ipairs(seer:getUnits()) do
						-- don't use sim:canUnitSeeUnit or unit:getSeenUnits
						-- sim:notifySeers updates units after players so they are not updated yet
						-- (sim:refreshUnitLOS does it in reverse order...)
						if sim:canUnitSee(seerUnit, x, y) and simquery.couldUnitSee(sim, seerUnit, evData.unit) then
							return evData.unit, seerUnit
						end
					end
				end
			end
			return false
		end,
	}
end
mission_util.SAW_SPECIAL_TAG = function(script, tag, text, subtext)
	return {
		trigger = simdefs.TRG_UNIT_APPEARED,
		fn = function(sim, evData)
			local seer = sim:getPlayerByID(evData.seerID)
			if not seer or not seer:isPC() then
				return false
			end

			if evData.unit:hasTag(tag) then
				evData.unit:createTab(text, subtext)
				return evData.unit
			else
				return nil
			end
		end,
	}
end
