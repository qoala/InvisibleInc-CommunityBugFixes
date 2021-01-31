-- patch to client/hud/mission_panel

local util = include( "modules/util" )
local items_panel = include( "hud/items_panel" )

local loot_panel = items_panel.loot
local pickup_panel = items_panel.pickup

local oldLootRefreshUserItem = loot_panel.refreshUserItem

function loot_panel:refreshUserItem( unit, item, widget, i, ... )
	oldLootRefreshUserItem( self, unit, item, widget, i, ... )

	if item ~= nil and self._hud._game.simCore:getParams().difficultyOptions.cbf_ending_incognitadrop then
		local enabled, reason = true, nil

		local recipient;
		if unit == self._unit then
			-- Check ability to transfer from SELF to OTHER.
			recipient = self._targetUnit
		else
			-- Check ability to transfer from OTHER to SELF.
			recipient = self._unit
		end

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

local oldPickupRefreshUserItem = pickup_panel.refreshUserItem

function pickup_panel:refreshUserItem( unit, item, widget, i, ... )
	oldPickupRefreshUserItem( self, unit, item, widget, i, ... )

	if item ~= nil and self._hud._game.simCore:getParams().difficultyOptions.cbf_ending_incognitadrop then
		local enabled, reason = true, nil

		local recipient;
		if unit == self._unit then
			-- Check ability to transfer from SELF to OTHER.
			recipient = self._targetUnit
		else
			-- Check ability to transfer from OTHER to SELF.
			recipient = self._unit
		end

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
