
-- When player opens lab, print message that science is disabled
script.on_event(defines.events.on_gui_opened, function(event)
    if event.gui_type == defines.gui_type.entity then
        if event.entity.type == "lab" then
            game.get_player(event.player_index).print({"science-restriction"}, {r = 1})
        end
    end
end)
