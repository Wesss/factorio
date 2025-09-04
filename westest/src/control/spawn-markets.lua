
-- when a chunk is generated, place a market randomly
script.on_event(defines.events.on_chunk_generated, function(event)
    local surface = event.surface
    local area = event.area
    -- TODO WESD implement randomness. this needs to be deterministic/the 'factorio' way to support multiplayer
    -- if math.random() < 0.1 then
        -- local x = math.random(area.left_top.x, area.right_bottom.x)
        -- local y = math.random(area.left_top.y, area.right_bottom.y)
        local x = area.left_top.x + 5
        local y = area.left_top.y + 5
        -- TODO WESD check if entity is legal at this point (player starting position, over trees/water/cliffs, over resources)
        surface.create_entity{name = "science-market", position = {x, y}, force = "neutral"}
    -- end
end)