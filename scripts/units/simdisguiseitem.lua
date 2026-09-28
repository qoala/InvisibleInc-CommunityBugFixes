-- patch to sim/units/simdisguiseitem
local util = include("modules/util")
local simunit = include("sim/simunit")
local simdefs = include("sim/simdefs")
local simfactory = include("sim/simfactory")
local cdefs = include("client_defs")

local item_disguise = {ClassType = "item_disguise"}

function item_disguise:onSpawn(sim)
	sim:addTrigger(simdefs.TRG_UNIT_WARP, self)
	sim:addTrigger(simdefs.TRG_START_TURN, self)
	-- needs to go after Senses.processAppearedTrigger else the agent "appears" undisguised
	-- to the guard even when the guard can't see them anymore because of cover!
	sim:addTrigger(simdefs.TRG_UNIT_APPEARED, self).priority = -10
end

function item_disguise:onDespawn(sim)
	sim:removeTrigger(simdefs.TRG_UNIT_WARP, self)
	sim:removeTrigger(simdefs.TRG_START_TURN, self)
	sim:removeTrigger(simdefs.TRG_UNIT_APPEARED, self)
end

local function checkDisguiseReveal(sim, unitOwner, npcUnit, isWarp)
	local x0, y0 = unitOwner:getLocation()
	local x1, y1 = npcUnit:getLocation()
	if
		x0
		and x1
		and math.abs(x1 - x0) <= 1
		and math.abs(y1 - y0) <= 1
		and unitOwner:getTraits().disguiseOn
		and npcUnit:getTraits().isGuard
		and sim:canUnitSeeUnit(npcUnit, unitOwner)
	then
		unitOwner:setDisguise(false, nil, true)
		-- if the disguised agent disappears from vision behind cover, spawn an interest
		if not sim:canUnitSeeUnit(npcUnit, unitOwner) and npcUnit:getBrain() then
			npcUnit:getBrain():getSenses():addInterest(x0, y0, simdefs.SENSE_SIGHT, simdefs.REASON_NOTICED, unitOwner)
		end
		if unitOwner:canBeInterrupted() then
			unitOwner:interruptMove(sim)
			if unitOwner:getTraits().movePath and isWarp then
				-- process reactions here because moveUnit will bail out before reaching it when interrupted
				sim:processReactions(unitOwner)
			end
		end
	end
end

-- CBF/Disguise Fix: 
-- * Disguise no longer breaks on re-captured cameras. Now requires an NPC-owned guard/drone.
-- * More consistent behavior when multiple guards are in deactivation range.
-- * Don't crash if the disguise is on the ground.
-- * Also reveal disguise when the guard turns to the agent in front of them
function item_disguise:onTrigger(sim, evType, evData)
	if evType == simdefs.TRG_UNIT_WARP then
		local unitOwner = self:getUnitOwner()
		if unitOwner and unitOwner:getTraits().disguiseOn then
			if evData.unit == unitOwner then
				for _, npcUnit in ipairs(util.tdupe(sim:getNPC():getUnits())) do
					checkDisguiseReveal(sim, unitOwner, npcUnit, true)
				end
			elseif evData.unit:isNPC() then
				checkDisguiseReveal(sim, unitOwner, evData.unit, true)
			end
		end
	elseif evType == simdefs.TRG_UNIT_APPEARED then
		local unitOwner = self:getUnitOwner()
		-- defer to warp trigger during warps, else it will look like prism got revealed before the move even happened
		if evData.unit == unitOwner and unitOwner:getTraits().disguiseOn and not unitOwner:getTraits().isWarping then
			local npcUnit = sim:getUnit(evData.seerID)
			if npcUnit and npcUnit:isNPC() and not npcUnit:getTraits().isWarping then
				checkDisguiseReveal(sim, unitOwner, npcUnit)
			end
		end
    elseif evType == simdefs.TRG_START_TURN then
        local owner = self:getUnitOwner()
        if not owner then
            return
        end
        local player = owner:getPlayerOwner()
        if player and sim:getCurrentPlayer() == player and owner and owner:getTraits().disguiseOn then
            local x, y = owner:getLocation()
            if self:getTraits().CPUperTurn and (player:getCpus() >= self:getTraits().CPUperTurn) then
                player:addCPUs(-self:getTraits().CPUperTurn, sim, x, y)
                if self:getTraits().warning then
                    sim:dispatchEvent(
                            simdefs.EV_SHOW_WARNING, {
                                txt = util.sformat(
                                        self:getTraits().warning, self:getTraits().CPUperTurn),
                                color = cdefs.COLOR_PLAYER_WARNING,
                                sound = "SpySociety/Actions/mainframe_gainCPU",
                                icon = nil,
                            })
                end
            else
                owner:setDisguise(false)
            end
            if self:getTraits().disguise_duration and owner:getTraits().disguise_turns_active then
                owner:getTraits().disguise_turns_active =
                        owner:getTraits().disguise_turns_active + 1
                if owner:getTraits().disguise_turns_active >= self:getTraits().disguise_duration then
                    owner:setDisguise(false)
                end
            end
        end
    end
end

-----------------------------------------------------
-- Interface functions

local function createItem(unitData, sim)
    return simunit.createUnit(unitData, sim, item_disguise)
end

simfactory.register(createItem)

return {createItem = createItem}
