-- patch to sim/simactions
local simactions = include('sim/simactions')
local inventory = include("sim/inventory")
local simdefs = include('sim/simdefs')
local simquery = include('sim/simquery')

-- Overwrite lootItem. Change at '-- CBF:'/'-- FuncLib:' below.
function simactions.lootItem(sim, unitID, itemID)
    local unit = sim:getUnit(unitID)
    local item = sim:getUnit(itemID)
    assert(unit:getPlayerOwner() == sim:getCurrentPlayer())

    local cell = sim:getCell(item:getLocation())
    if cell then
        if item:hasAbility("carryable") then
            inventory.pickupItem(sim, unit, item)
            sim:emitSound(simdefs.SOUND_ITEM_PICKUP, cell.x, cell.y, unit)

        elseif item:getTraits().cashOnHand then

            local credits = math.floor(
                    simquery.calculateCashOnHand(sim, item) *
                            (1 + (unit:getTraits().stealBonus or 0)))
            sim._resultTable.credits_gained.pickpocket =
                    sim._resultTable.credits_gained.pickpocket and
                            sim._resultTable.credits_gained.pickpocket + credits or credits
            unit:getPlayerOwner():addCredits(credits, sim, cell.x, cell.y)
            item:getTraits().cashOnHand = nil
            sim:dispatchEvent(simdefs.EV_PLAY_SOUND, simdefs.SOUND_CREDITS_PICKUP.path)

        elseif item:getTraits().credits then

            local credits = item:getTraits().credits
            sim._resultTable.credits_gained.safes =
                    sim._resultTable.credits_gained.safes and sim._resultTable.credits_gained.safes +
                            credits or credits
            unit:getPlayerOwner():addCredits(credits, sim, cell.x, cell.y)
            item:getTraits().credits = nil
            sim:dispatchEvent(simdefs.EV_PLAY_SOUND, simdefs.SOUND_CREDITS_PICKUP.path)

        elseif item:getTraits().PWROnHand then
            local PWR = simquery.calculatePWROnHand(sim, item)
            unit:getPlayerOwner():addCPUs(PWR, sim, cell.x, cell.y)
            item:getTraits().PWROnHand = nil
            sim:dispatchEvent(simdefs.EV_PLAY_SOUND, "SpySociety/Actions/item_pickup")
        end
    else
        local itemOwner = item:getUnitOwner()
        inventory.giveItem(itemOwner, unit, item)

        local itemDef = item:getUnitData()
        if itemDef.traits.showOnce then
            local dialogParams = {
                STRINGS.UI.ITEM_ACQUIRED,
                itemDef.name,
                itemDef.desc,
                itemDef.profile_icon_100,
            }
            sim:dispatchEvent(
                    simdefs.EV_SHOW_DIALOG, {
                        showOnce = itemDef.traits.showOnce,
                        dialog = "programDialog",
                        dialogParams = dialogParams,
                    })
        end
    end

    item:getTraits().anarchySpecialItem = nil
    item:getTraits().largeSafeMapIntel = nil

    inventory.autoEquip(unit)

    -- CBF: custom recheckAllAiming only resets ambush/overwatch if it's no longer available.
    if unit.recheckAllAiming then
        unit:recheckAllAiming()
    else
        -- This shouldn't happen
        simlog(
                "CBF: unit did not define recheckAllAiming. Falling back to resetAllAiming. %s [%d]",
                unit:getName(), unit:getID())
        unit:resetAllAiming()
    end

    unit:checkOverload(sim)

    sim:dispatchEvent(simdefs.EV_ITEMS_PANEL) -- Triggers refresh.
    -- FuncLib: modded trigger
    sim:triggerEvent("FUNCLIB-ITEM-STOLEN", {unit = unit, targetUnit = item})
end

-- Overwrite useDoorAction. Change at '-- CBF:' below.
function simactions.useDoorAction(sim, exitOp, unitID, x0, y0, facing)
    local player = sim:getCurrentPlayer()
    local unit = sim:getUnit(unitID)
    local cell = sim:getCell(x0, y0)

    assert(
            unit:getPlayerOwner() == player,
            unit:getName() .. "," .. tostring(unit:getPlayerOwner()) .. "," .. tostring(exitOp))
    assert(cell)
    if sim:isVersion("0.17.5") then
        assert(simquery.canModifyExit(unit, exitOp, cell, facing))
    end
    assert(simquery.canReachDoor(unit, cell, facing))

    -- face the door correctly if it's not in the same cell
    local vizFacing = facing
    local x1, y1 = unit:getLocation()
    if x0 ~= x1 or y0 ~= y1 then
        vizFacing = simquery.getDirectionFromDelta(x0 - x1, y0 - y1)
    end

    -- CBF: Skip the facing update if the unit is in a multi-turn hacking animation.
    -- We want the agent to return to their existing facing at the end of the door anim.
    if not simquery.cbfAgentHasStickyFacing(unit) then
        unit:setFacing(vizFacing)
    end

    if not unit:getTraits().noDoorAnim then
        sim:dispatchEvent(
                simdefs.EV_UNIT_USEDOOR, {unitID = unitID, facing = vizFacing, exitOp = exitOp})
    end
    sim:modifyExit(cell, facing, exitOp, unit, unit:getTraits().sneaking)
    if unit:isValid() then
        if not unit:getTraits().noDoorAnim then
            sim:dispatchEvent(
                    simdefs.EV_UNIT_USEDOOR_PST,
                    {unitID = unitID, facing = vizFacing, exitOp = exitOp})
        end
        if exitOp == simdefs.EXITOP_BREAK_DOOR and not unit:getTraits().interrupted then
            sim:dispatchEvent(simdefs.EV_UNIT_GUNCHECK, {unit = unit, facing = vizFacing})
        end
    end
    unit:getTraits().interrupted = nil
end
