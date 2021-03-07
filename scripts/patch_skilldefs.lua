-- patches for existing skilldefs

local util = include( "modules/util" )
local skilldefs = include( "sim/skilldefs" )

local oldLookupSkill
local patchedSkills = {}

-- Called from lateLoad to apply after Flavorful agents' load/unload.
local updateSkills = function()
	oldLookupSkill = skilldefs.lookupSkill
	patchedSkills = {}

	skilldefs.lookupSkill = function( skillID )
		local skill = oldLookupSkill( skillID )

		if skillID == 'stealth' then
			if not patchedSkills[skill] then
				-- Cache a mapping from the underlying skill to the patched skill.
				patchedSkills[skill] = util.tcopy(skill)
				-- Also cache a mapping from the patched skill to itself. In case something goes wrong and the patcher is applied multiple times.
				patchedSkills[patchedSkills[skill]] = patchedSkills[skill]

				-- Patch speed5 upgrade. Vanilla accidentally uses hacking_bonus to calculate sprintBonus.
				local oldOnLearn = patchedSkills[skill][5].onLearn
				patchedSkills[skill][5].onLearn = function(sim, unit)
					local sprintBonus = unit:getTraits().sprintBonus or 0

					oldOnLearn(sim, unit)

					unit:getTraits().sprintBonus = sprintBonus + 1
				end
			end
			return patchedSkills[skill]
		end

		return skill
	end
end

-- Called from earlyLoad/earlyUnload to apply before Flavorful agents' load/unload.
local resetSkills = function()
	patchedSkills = {}

	if oldLookupSkill then
		skilldefs.lookupSkill = oldLookupSkill
		oldLookupSkill = nil
	end
end

return {
	updateSkills = updateSkills,
	resetSkills = resetSkills,
}
