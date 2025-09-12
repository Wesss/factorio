
local inspect = require("src.util.inspect")

-- when a chunk is generated, place a market randomly
script.on_event(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    local area = event.area
    -- 1 in X change to spawn a market per chunk
    -- TODO WESD turn market frequency into a setting
    if math.random(1, 64) == 1 then
        -- pick random positions until the market can be placed. after X attempts, give up and don't place a market.
        for _ = 1, 50 do
            -- TODO WESD guarantee that 1 market is in starting area. then decrease spawn chance?
            -- TODO WESD also guarantee that only exactly 1 market spawns in the starting area?
            local x = math.random(area.left_top.x, area.right_bottom.x)
            local y = math.random(area.left_top.y, area.right_bottom.y)

            -- TODO WESD use prototypes api to use original collision checking (see links below)
                -- https://lua-api.factorio.com/latest/classes/LuaSurface.html#entity_prototype_collides
                -- https://lua-api.factorio.com/latest/classes/LuaPrototypes.html#get_item_filtered
            -- TODO WESD also check that market is not over an ore patch
            local position = surface.find_non_colliding_position_in_box(
                "science-market",
                -- just check the 'box' of a singular point
                {{x, y}, {x, y}},
                --precision - 1 tile as this is for a building
                1,
                --force_to_tile_center - snaps to tile center for building placement
                true
            )
            if position ~= nil then
                surface.create_entity{name = "science-market", position = position, force = "neutral"}
                break
            end
        end
    end
end)