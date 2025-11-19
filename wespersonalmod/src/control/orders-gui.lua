
local ordersGUI = {}

local curVersion = 2

function ordersGUI.updateOrdersGUI(orderQueue)
    local prevVersion = storage["ordersGUI.updateOrdersGUI-version"]
    storage["ordersGUI.updateOrdersGUI-version"] = curVersion

    for index, player in pairs(game.players) do
        local main_frame = player.gui.left.orders_main_frame

        if prevVersion ~= curVersion then
            main_frame.destroy()
            main_frame = nil
        end

        -- create or clear the main GUI frame
        if main_frame == nil then
            main_frame = player.gui.left.add {
                type = "frame",
                name = "orders_main_frame",
                caption = "Orders",
                direction = "vertical"
            }
        else
            main_frame.clear()
        end

        local order_frame = nil
        for idx, order in ipairs(orderQueue.orders) do
            -- create new frame for current/top of next, re-use remaining of next frames
            local caption = ""
            if (idx == 1) then
                caption = "Current Order"
            else
                caption = "Next"
            end

            if idx == 1 or idx == 2 then
                order_frame = main_frame.add {
                    type = "frame",
                    name = caption,
                    caption = caption,
                    direction = "vertical"
                }
                order_frame.style.bottom_margin = 5
            end

            -- display line items
            for i, lineItem in ipairs(order.lineItems) do
                local line = order_frame.add {
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
                    caption = lineItem.itemName .. ": "
                }
                
                local amount_label = line.add {
                    type = "label",
                    caption = lineItem.fulfilled .. "/" .. lineItem.amount
                }
            end
        end
    end
end

return ordersGUI