local Senses = include("sim/btree/senses")
local simquery = include("sim/simquery")
local mathutil = include("modules/mathutil")
local simdefs = include("sim/simdefs")

function Senses:processInterestShared(sim, evData)
	if evData.range and mathutil.dist2d(evData.x, evData.y, self.unit:getLocation()) > evData.range then
		return
	end

	if evData.interest.sourceUnit == self.unit then
		return
	end

	if evData.target then
		if self:hasTarget(evData.target) or self.currentTarget then
			return
		end

		if
			simquery.couldUnitSee(sim, self.unit, evData.target)
			-- new: instead of only raycast, also check if interest cell is in vision range.
			-- (simquery.couldUnitSeeCell does both)
			and evData.target:getLocation()
			and simquery.couldUnitSeeCell(sim, self.unit, sim:getCell(evData.target:getLocation()))
		then
			self:addTarget(evData.target)
			return
		end
	end
	self:addInterest(
		evData.interest.x,
		evData.interest.y,
		simdefs.SENSE_RADIO,
		evData.interest.reason or simdefs.REASON_SHARED,
		evData.interest.sourceUnit
	)
end

function Senses:processSoundTrigger(sim, evData)
	if evData.sourceUnit and evData.sourceUnit:getPlayerOwner() == self.unit:getPlayerOwner() then
		return
	end

	if not self.unit:getTraits().hasHearing then
		return
	end

	if
		evData.sourceUnit
		and sim:canUnitSeeUnit(self.unit, evData.sourceUnit)
		-- check if we can actually react to the target (crybaby passes the checks before this)
		-- optimally would just check for evData.ignoreSight but nobody uses this
		and simquery.isEnemyTarget(self.unit:getPlayerOwner(), evData.sourceUnit)
	then
		return
	end

	if sim:canUnitSee(self.unit, evData.x, evData.y) and evData.ignoreSight == nil then
		if self.unit:getTraits().seesHidden or not simquery.checkCover(sim, self.unit, evData.x, evData.y) then
			return
		end
	end

	if mathutil.dist2d(evData.x, evData.y, self.unit:getLocation()) > evData.range then
		return
	end

	self:addInterest(evData.x, evData.y, simdefs.SENSE_HEARING, simdefs.REASON_NOISE, evData.sourceUnit)
end

