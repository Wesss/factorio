
local ticksPerCheck = 60

require("src.control.disable-labs-message")
local Order, LineItem = require("src.control.order")
local OrdersGUI = require("src.control.orders-gui")
local Markets = require("src.control.markets")

-- main loop
script.on_nth_tick(60, function(event)
    -- TODO WESD fetch orders, complete & generate new if needed
    local orders = Order.getOrders()
    -- TODO WESD have markets actually check current order
    Markets.checkMarkets()
    -- TODO WESD have GUID display current order
    OrdersGUI.updateOrdersGUI()
    Order.persist(orders)
end)
