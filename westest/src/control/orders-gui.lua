
local ordersGUI = {}

function ordersGUI.updateOrdersGUI()
    for index, player in pairs(game.players) do
        local main_frame = player.gui.left.orders_main_frame
        if main_frame == nil then
            main_frame = player.gui.left.add {
                type = "frame",
                name = "orders_main_frame",
                caption = "Orders"
            }
        end
        -- TODO WESD fill in rest of GUI
    end
end

return ordersGUI