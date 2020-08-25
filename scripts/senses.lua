-- patch to sim/btree/senses

local Senses = include("sim/btree/senses")

local oldAddInterest = Senses.addInterest

function Senses:addInterest( x, y, sense, reason, sourceUnit, ignoreDisguise, ... )
	local interest = oldAddInterest( self, x, y, sense, reason, sourceUnit, ignoreDisguise, ... )

	-- Reference equality check: Did addInterest just modify the interest object held by the brain?
	if interest and self.unit:getBrain():getInterest() and interest == self.unit:getBrain():getInterest() then
		local sim = self.unit:getSim()
		local pathingOption = sim:getParams().difficultyOptions.cbf_pathing
		if pathingOption and pathingOption.reset_on_interest_moved and sim:getCurrentPlayer():isPC() then
			-- It's odd to call Brain:reset from here, but Brain is a base class, and the class system doesn't propagate overrides to subclasses.
			-- Just in case, we've checked we only trigger this during the player turn.
			self.unit:getBrain():reset()
		end
	end

	return interest
end
