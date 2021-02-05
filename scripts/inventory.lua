-- patch to sim/inventory

local simdefs = include("sim/simdefs")
local inventory = include("sim/inventory")

local oldGiftUnit = inventory.giftUnit

function getLastInventoryItem( unit )
	local lastItem = nil
	for _, childUnit in ipairs(unit:getChildren()) do
		if childUnit:hasAbility("carryable") and (not childUnit:getTraits().augment or not childUnit:getTraits().installed) then
			lastItem = childUnit
		end
	end
	return lastItem
end

function inventory.giftUnit( sim, unit, itemTemplate, showModal, ... )

	if itemTemplate == "item_incognita" and unit:getInventoryCount() >= 8 then
		local lastItem = getLastInventoryItem(unit)
		inventory.dropItem(sim, unit, lastItem)
		local x0, y0 = unit:getLocation()
		sim:emitSound(simdefs.SOUND_ITEM_PUTDOWN, x0, y0, unit)
		sim:dispatchEvent(simdefs.EV_UNIT_PICKUP, { unitID = unit:getID() })
	end

	return oldGiftUnit( sim, unit, itemTemplate, showModal, ... )
end
