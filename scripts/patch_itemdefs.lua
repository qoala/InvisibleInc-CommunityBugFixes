-- patches for existing itemdefs
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

return {updateEndingFinalDoor = updateEndingFinalDoor, resetEndingFinalDoor = resetEndingFinalDoor}
