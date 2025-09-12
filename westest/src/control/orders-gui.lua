
local ordersGUI = {}

function ordersGUI.updateOrdersGUI(orderQueue)
    local curOrder = orderQueue.currentOrder

    for index, player in pairs(game.players) do
        local main_frame = player.gui.left.orders_main_frame
        if main_frame == nil then
            main_frame = player.gui.left.add {
                type = "frame",
                name = "orders_main_frame",
                caption = "Orders"
            }
        end

        main_frame.clear()
        local content_frame = main_frame.add {
            type = "frame",
            name = "content_frame",
            direction = "vertical"
        }
        for i, lineItem in ipairs(curOrder.lineItems) do
            local line = content_frame.add {
                type = "flow"
            }
            line.style.vertical_align = "center"
            local sprite = line.add {
                type = "sprite",
                sprite = "item/" .. lineItem.itemName,
                tooltip = {"?", {"", {"item-name." .. lineItem.itemName}}, {"entity-name." .. lineItem.itemName}}
            }
            sprite.style.right_margin = 5
            line.add {
                type = "label",
                caption = lineItem.itemName
            }
            line.add {
                type = "label",
                caption = lineItem.fulfilled .. "/" .. lineItem.amount
            }
        end
    end
end

return ordersGUI