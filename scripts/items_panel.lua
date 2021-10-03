-- patch to client/hud/mission_panel

local util = include( "modules/util" )
local items_panel = include( "hud/items_panel" )
local inventory = include( "sim/inventory" )

local cbf_util = include( SCRIPT_PATHS.qoala_commbugfix .. "/cbf_util" )

local loot_panel = items_panel.loot
local pickup_panel = items_panel.pickup

local oldLootRefreshItem = loot_panel.refreshItem

function getCarryableItemByIndex(unit, targetUnit, i)
	for _, childUnit in ipairs(targetUnit:getChildren()) do
		if (not childUnit:getTraits().augment or not childUnit:getTraits().installed) and inventory.canCarry(unit, childUnit) then
			i = i - 1
			if i == 0 then
				return childUnit
			end
		end
	end
	return nil
end

function loot_panel:refreshItem( widget, i, ... )
	local res = oldLootRefreshItem( self, widget, i, ... )

	if res and cbf_util.simCheckFlag(self._hud._game.simCore, "cbf_ending_incognitadrop") then
		local item = getCarryableItemByIndex(self._unit, self._targetUnit, i)
		if item ~= nil then
			local enabled, reason = true, nil

			-- Check ability to transfer from OTHER to SELF.
			local recipient = self._unit

			if item:getTraits().pickupOnly and (not recipient or not recipient:hasTag(item:getTraits().pickupOnly)) then
				enabled = false
				reason = util.sformat(STRINGS.UI.TOOLTIPS.PICK_UP_CONDITION_DESC, util.toupper(item:getTraits().pickupOnly))
			end

			if reason then
				widget.binder.btn:setDisabled(not enabled)
				widget.binder.btn:setTooltip(reason)
			end
		end
	end

	return res
end

local oldLootRefreshUserItem = loot_panel.refreshUserItem

function loot_panel:refreshUserItem( unit, item, widget, i, ... )
	oldLootRefreshUserItem( self, unit, item, widget, i, ... )

	if item ~= nil and cbf_util.simCheckFlag(self._hud._game.simCore, "cbf_ending_incognitadrop") then
		local enabled, reason = true, nil

		-- Check ability to transfer from SELF to OTHER.
		local recipient = self._targetUnit

		if item:getTraits().pickupOnly and (not recipient or not recipient:hasTag(item:getTraits().pickupOnly)) then
			enabled = false
			reason = util.sformat(STRINGS.UI.TOOLTIPS.PICK_UP_CONDITION_DESC, util.toupper(item:getTraits().pickupOnly))
		end

		if reason then
			widget.binder.btn:setDisabled(not enabled)
			widget.binder.btn:setTooltip(reason)
		end
	end
end

-- pickup_panel.refreshItem already checks pickupOnly.

local oldPickupRefreshUserItem = pickup_panel.refreshUserItem

function pickup_panel:refreshUserItem( unit, item, widget, i, ... )
	oldPickupRefreshUserItem( self, unit, item, widget, i, ... )

	if item ~= nil and cbf_util.simCheckFlag(self._hud._game.simCore, "cbf_ending_incognitadrop") then
		local enabled, reason = true, nil

		-- Check ability to transfer from SELF to OTHER.
		local recipient = self._targetUnit

		if item:getTraits().pickupOnly and (not recipient or not recipient:hasTag(item:getTraits().pickupOnly)) then
			enabled = false
			reason = util.sformat(STRINGS.UI.TOOLTIPS.PICK_UP_CONDITION_DESC, util.toupper(item:getTraits().pickupOnly))
		end

		if reason then
			widget.binder.btn:setDisabled(not enabled)
			widget.binder.btn:setTooltip(reason)
		end
	end
end
