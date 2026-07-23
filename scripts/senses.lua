-- patch to sim/btree/senses
local Senses = include("sim/btree/senses")
local simdefs = include("sim/simdefs")
local simquery = include("sim/simquery")
local cbf_util = include(SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util")
local array = include("modules/array")

local impassMemory = class()

function impassMemory:init(senses, sim, unit)
	self.senses = senses
	self.sim = sim
	self.unit = unit

	sim:addTrigger(simdefs.TRG_START_TURN, self).priority = 10
	sim:addTrigger(simdefs.TRG_UNIT_KO, self).priority = -10
	sim:addTrigger(simdefs.TRG_UNIT_APPEARED, self).priority = -10
	sim:addTrigger(simdefs.TRG_UNIT_DISAPPEARED, self).priority = -10
	sim:addTrigger(simdefs.TRG_UNIT_WARP, self).priority = -10

	-- don't call reset here, the processReactions can tick the brain before the brain has been fully setup
	self.impass = {}
end

function impassMemory:destroy()
	local sim = self.sim

	sim:removeTrigger(simdefs.TRG_START_TURN, self)
	sim:removeTrigger(simdefs.TRG_UNIT_KO, self)
	sim:removeTrigger(simdefs.TRG_UNIT_APPEARED, self)
	sim:removeTrigger(simdefs.TRG_UNIT_DISAPPEARED, self)
	sim:removeTrigger(simdefs.TRG_UNIT_WARP, self)
end

function impassMemory:reset()
	local hadImpass = next(self.impass) ~= nil
	self.impass = {}
	if self.sim:getCurrentPlayer() == self.unit:getPlayerOwner() then
		if not self.senses:checkDisabled() and self.unit:getSeenUnits() then
			for _, unit in ipairs(self.unit:getSeenUnits()) do
				self:updateUnit(unit, true)
			end
		end
	elseif hadImpass and self.unit:getPather() then
		self.unit:getPather():invalidatePath(self.unit)
		self.sim:getNPC():processReactions(self.unit)
	end
end

function impassMemory:updateUnit(unit, seen)
	if not unit:isValid() then
		return
	end
	if
		unit:getTraits().dynamicImpass
		and unit:getPlayerOwner() ~= self.unit:getPlayerOwner()
		and unit:getLocation()
	then
		local ux, uy = unit:getLocation()
		self.impass[unit:getID()] = { x = ux, y = uy, hard = seen }
	else
		self.impass[unit:getID()] = nil
	end
end

function impassMemory:onTrigger(sim, evType, evData)
	if evType == simdefs.TRG_START_TURN then
		self:reset()
		return
	end
	if
		sim:getCurrentPlayer() ~= self.unit:getPlayerOwner()
		or evData.unit == self.unit
		or self.senses:checkDisabled()
	then
		return
	end
	if evType == simdefs.TRG_UNIT_APPEARED then
		if sim:getUnit(evData.seerID) ~= self.unit then
			return
		end
		self:updateUnit(evData.unit, true)
	elseif evType == simdefs.TRG_UNIT_DISAPPEARED then
		if sim:getUnit(evData.seerID) ~= self.unit then
			return
		end
		local lastSeen = evData.unit:isValid() and self.impass[evData.unit:getID()]
		if
			lastSeen
			and sim:canUnitSee(self.unit, lastSeen.x, lastSeen.y)
			and self.unit:getLocation()
			and (not simquery.checkCover(sim, self.unit, lastSeen.x, lastSeen.y) or self.unit:getTraits().seesHidden)
		then
			self.impass[evData.unit:getID()] = nil
		end
	elseif evType == simdefs.TRG_UNIT_WARP or evType == simdefs.TRG_UNIT_KO then
		if self.unit:getSeenUnits() and array.find(self.unit:getSeenUnits(), evData.unit) then
			self:updateUnit(evData.unit, true)
		end
	end
end

local onSpawned = Senses.onSpawned
Senses.onSpawned = function(self, sim, unit, ...)
	onSpawned(self, sim, unit, ...)
	if cbf_util.simCheckFlag(sim, "cbf_disguisefix_pathing") then
		self.CBF_impassMemory = impassMemory(self, sim, unit)
	end
end

local onDespawned = Senses.onDespawned
Senses.onDespawned = function(self, ...)
	if self.CBF_impassMemory then
		self.CBF_impassMemory:destroy()
		self.CBF_impassMemory = nil
	end
	onDespawned(self, ...)
end

local oldAddInterest = Senses.addInterest
function Senses:addInterest(x, y, sense, reason, sourceUnit, ignoreDisguise, ...)
    local interest = oldAddInterest(self, x, y, sense, reason, sourceUnit, ignoreDisguise, ...)

    -- CBF: Update observed pathing when the guard's current interest moves.
    -- Reference equality check: Did addInterest just modify the interest object held by the brain?
    if interest and self.unit:getBrain():getInterest() and interest ==
            self.unit:getBrain():getInterest() then
        local sim = self.unit:getSim()
        local pathingOption = cbf_util.simCheckFlag(sim, "cbf_pathing")
        if pathingOption and pathingOption.reset_on_interest_moved and sim:getCurrentPlayer():isPC() then
            if sim:cbfHasPathingQueue() then
                sim:cbfAddToPathingQueue(self.unit)
			elseif self.unit:getPather() then
				self.unit:getPather():invalidatePath(self.unit)
            end
        end
    end

    return interest
end

local oldProcessAppearedTrigger = Senses.processAppearedTrigger
function Senses:processAppearedTrigger(sim, evData, ...)
    -- CBF: Don't re-investigate parts of a smoke cloud that we've already inspected.
    local smokeEdgeOption = cbf_util.simCheckFlag(sim, "cbf_smoke_rememberedges")
    if smokeEdgeOption and evData.unit:getTraits().smokeEdge and evData.unit.getActiveSmokeClouds then
        local canInvestigate = false
        for _, cloud in ipairs(evData.unit:getActiveSmokeClouds(sim)) do
            if not cloud:hasBeenSmokeInvestigated(self.unit) then
                canInvestigate = true
                break
            end
        end
        if not canInvestigate then
            -- Already investigated these clouds.
            return
        end
    end

    return oldProcessAppearedTrigger(self, sim, evData, ...)
end
