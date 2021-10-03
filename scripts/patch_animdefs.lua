
local animdefs = include("animdefs")
local common_anims = include("common_anims")

local function updateAnimdefs()
	local ceo_def = animdefs.defs.kanim_business_man
	ceo_def.grp_anims = common_anims.male.grp_anims
end

local function resetAnimdefs()
	local ceo_def = animdefs.defs.kanim_business_man
	ceo_def.grp_anims = nil
end


return {
	updateAnimdefs = updateAnimdefs,
	resetAnimdefs = resetAnimdefs,
}
