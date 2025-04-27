-- patch to sim/mazegen
local mazegen = include("sim/mazegen")
local simdefs = include( "sim/simdefs" )

-- Saves a debug PNG of the map on mission load, if enabled by flag.
--
-- Enable by setting `SAVE_MAP_PNGS = true` in `main.lua` in the install folder.
--
-- Overwrite-patch provided by wodzu_93
-- * Re-enable/repair broken vanilla behavior.
-- * More details, such as doors and some unit/prop types
-- * Output is now stored to a lvl/ subfolder of the game install directory.
function mazegen.saveMazePNG( cxt, filename )
    local WALL_WIDTH, CELL_SIZE = 1, 10
    local xmin, ymin, xmax, ymax = cxt:getBounds()
    local w, h = (xmax - xmin) * CELL_SIZE + CELL_SIZE, (ymax - ymin) * CELL_SIZE + CELL_SIZE
    local t = 0.5

    log:write( "saveMapPNG( %s ) - %d x %d", filename, w, h )
    local image = MOAIImage.new()
    image:init( w, h )
    image:fillRect( 0, 0, w, h, 0, 0.05, 0.2, 1 )

    for i, room in pairs ( cxt.board ) do
        if type(room) == "table" then
            for j, tile in pairs ( room ) do
                if tile.x and tile.y then
                    local x0, y0 = (tile.x-1) * CELL_SIZE, (tile.y-1) * CELL_SIZE
                    local x1, y1 = tile.x * CELL_SIZE, tile.y * CELL_SIZE
                    image:fillRect( w - x0, y0, w - x1, y1, t, t, t, 1 )

                    x0, y0 = (tile.x - 1) * CELL_SIZE + WALL_WIDTH, (tile.y - 1) * CELL_SIZE + WALL_WIDTH
                    x1, y1 = tile.x * CELL_SIZE - WALL_WIDTH, tile.y * CELL_SIZE - WALL_WIDTH
                    if tile.impass then
                        image:fillRect( w - x0, y0, w - x1, y1, t+0.1, t+0.1, t+0.1, 1 )
                    elseif tile.deployIndex then
                        image:fillRect( w - x0, y0, w - x1, y1, t, t+0.2, t, 1 )
                    elseif tile.exitID then
                        image:fillRect( w - x0, y0, w - x1, y1, t, t+0.2, t, 1 )
                    end

                    for k=0, 6, 2 do
                        if tile.sides and tile.sides[k] then
                            x0, y0, x1, y1 = tile.x * CELL_SIZE, tile.y * CELL_SIZE, tile.x * CELL_SIZE, tile.y * CELL_SIZE
                            if k == simdefs.DIR_E then
                                x0, y0 = x0 - WALL_WIDTH, y0 - CELL_SIZE
                            elseif k == simdefs.DIR_N then
                                x0, y0 = x0 - CELL_SIZE, y0 - WALL_WIDTH
                            elseif k == simdefs.DIR_W then
                                x0, y0, x1 = x0 - CELL_SIZE, y0 - CELL_SIZE, x1 - CELL_SIZE + WALL_WIDTH
                            elseif k == simdefs.DIR_S then
                                x0, y0, y1 = x0 - CELL_SIZE, y0 - CELL_SIZE, y1 - CELL_SIZE + WALL_WIDTH
                            end

                            if tile.sides[k].door and (tile.sides[k].locked or tile.sides[k].guarddoor) then
                                image:fillRect( w - x0, y0, w - x1, y1, 1, 0, 0, 1 )
                            elseif tile.sides[k].door then
                                image:fillRect( w - x0, y0, w - x1, y1, 1, 1, 0, 1 )
                            else
                                image:fillRect( w - x0, y0, w - x1, y1, t+0.1, t+0.1, t+0.1, 1 )
                            end
                        end
                    end
                end
            end
        end
    end

    for i, unit in pairs ( cxt.units ) do
        local x0, y0 = (unit.x - 1) * CELL_SIZE + WALL_WIDTH, (unit.y - 1) * CELL_SIZE + WALL_WIDTH
        local x1, y1 = unit.x * CELL_SIZE - WALL_WIDTH, unit.y * CELL_SIZE - WALL_WIDTH

        if unit.template == "console" then
            image:fillRect( w - x0, y0, w - x1, y1, 0, 0, 1, 1 )
        elseif unit.template == "lab_safe" or unit.template == "lab_safe_tier2" or unit.template == "guard_locker" or unit.template == "vault_safe_1" or unit.template == "vault_safe_2" or unit.template == "vault_safe_3" or unit.template == "power_core" then
            image:fillRect( w - x0, y0, w - x1, y1, 0, 1, 0, 1 )
        elseif unit.template == "security_camera_1x1" or unit.template == "security_soundBug_1x1" or unit.template == "turret" or unit.template == "turret_generator" then
            image:fillRect( w - x0, y0, w - x1, y1, 1, 0, 0, 1 )
        elseif unit.template == "detention_processor" or unit.template == "public_terminal" or unit.template == "vault_processor" or unit.template == "research_processor" or unit.template == "data_node" or unit.template == "transformer_terminal" or unit.template == "diagnostic_terminal" or unit.template == "research_security_processor" or unit.template == "ending_jackin" or unit.template == "yellow_level_console" then
            image:fillRect( w - x0, y0, w - x1, y1, 1, 1, 0, 1 )
        elseif unit.template == "item_store" or unit.template == "item_store_large" or unit.template == "augment_grafter" or unit.template == "augment_drill" or unit.template == "server_terminal" or unit.template == "mini_server_terminal" then
            image:fillRect( w - x0, y0, w - x1, y1, 0, 1, 1, 1 )
        else
            image:fillRect( w - x0, y0, w - x1, y1, 1, 0, 1, 1 )
        end
    end

    image:writePNG( "lvl/" .. filename )
end
