-- patches for existing itemdefs
local array = include("modules/array")
local util = include("modules/util")
local commondefs = include("sim/unitdefs/commondefs")
local simdefs = include("sim/simdefs")
local mainitems = include("sim/unitdefs/itemdefs")

-- Vanilla was using keybits to check that Monst3r could use the mainframe lock,
-- but it also allows directly unlocking the final door. Remove them.
local updateEndingFinalDoor = function()
    mainitems.augment_final_level.traits.keybits = nil
end
local resetEndingFinalDoor = function()
    mainitems.augment_final_level.traits.keybits = simdefs.DOOR_KEYS.FINAL_LEVEL
end

local patchVentricularLanceRecharge = function(modApi)
    if not array.find(mainitems.item_defiblance.abilities, "recharge") then
        local defiblance = util.tcopy(mainitems.item_defiblance)
        table.insert(defiblance.abilities, 2, "recharge")
        modApi:addItemDef("item_defiblance", defiblance)
    end
end
local latePatchVentricularLanceRecharge = function(modApi)
    if mainitems.item_defiblance_shalem_drm and
            not array.find(mainitems.item_defiblance_shalem_drm.abilities, "recharge") then
        local defiblance = util.tcopy(mainitems.item_defiblance_shalem_drm)
        table.insert(defiblance.abilities, 2, "recharge")
        modApi:addItemDef("item_defiblance_shalem_drm", defiblance)
    end
end

local latePatchShirshScanGrenades = function(modApi)
    if mainitems.item_kpctech_scangrenade and mainitems.item_kpctech_scangrenade.traits.isAgent ~= nil then
        local scangrenade = util.tcopy(mainitems.item_kpctech_scangrenade)
        scangrenade.traits.isAgent = nil
        modApi:addItemDef("item_kpctech_scangrenade", scangrenade)
    end
    if mainitems.item_kpctech_scangrenade_true and mainitems.item_kpctech_scangrenade_true.traits.isAgent ~= nil then
        local scangrenade = util.tcopy(mainitems.item_kpctech_scangrenade_true)
        scangrenade.traits.isAgent = nil
        modApi:addItemDef("item_kpctech_scangrenade_true", scangrenade)
    end
end

return {
    updateEndingFinalDoor = updateEndingFinalDoor,
    resetEndingFinalDoor = resetEndingFinalDoor,
    patchVentricularLanceRecharge = patchVentricularLanceRecharge,
    latePatchVentricularLanceRecharge = latePatchVentricularLanceRecharge,
    latePatchShirshScanGrenades = latePatchShirshScanGrenades,
}
