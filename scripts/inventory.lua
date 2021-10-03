-- patch to sim/inventory

local simdefs = include("sim/simdefs")
local inventory = include("sim/inventory")

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

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

local oldTrashItem = inventory.trashItem

function inventory.trashItem( sim, unit, item, ... )

	if cbf_util.simCheckFlag(sim, "cbf_agent_drillmodtrait") and item:getTraits().installed and item:getTraits().modTrait then
		for i,trait in ipairs(item:getTraits().modTrait)do
			-- Reverse both the value applied by installing the mod
			-- and the value from the broken vanilla trashItem.
			unit:getTraits()[trait[1]] = unit:getTraits()[trait[1]] - trait[2] - trait[2]
		end
	end

	return oldTrashItem( sim, unit, item, ...)
end
