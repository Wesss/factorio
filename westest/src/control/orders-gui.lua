
local ordersGUI = {}

function ordersGUI.updateOrdersGUI(orderQueue)
    -- TODO WESD display orderQueue contents
    for index, player in pairs(game.players) do
        local main_frame = player.gui.left.orders_main_frame
        if main_frame == nil then
            main_frame = player.gui.left.add {
                type = "frame",
                name = "orders_main_frame",
                caption = "Orders"
            }
        end
    end
end

return ordersGUI