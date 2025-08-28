
local ticksPerCheck = 60

require("src.control.disable-labs-message")
local OrderQueue = require("src.control.order-queue")
local OrdersGUI = require("src.control.orders-gui")
local Markets = require("src.control.markets")

-- main loop
script.on_nth_tick(60, function(event)
    local orderQueue = OrderQueue.load()
    Markets.checkMarkets(orderQueue:getCurrentOrder())
    OrdersGUI.updateOrdersGUI(orderQueue)
    orderQueue:save()
end)
