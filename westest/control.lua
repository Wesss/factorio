
local ticksPerCheck = 60

local inspect = require("src.util.inspect")

require("src.control.disable-labs-message")
require("src.control.spawn-markets")
-- TODO WESD on mod/config change, emit error that things may break?
local OrderQueue = require("src.control.order-queue")
local OrdersGUI = require("src.control.orders-gui")
local Markets = require("src.control.markets")

-- main loop
script.on_nth_tick(60, function(event)
    local orderQueue = OrderQueue.load()
    local curOrder = orderQueue:getCurrentOrder()
    Markets.checkMarkets(curOrder)
    OrdersGUI.updateOrdersGUI(orderQueue)
    orderQueue:save()
end)
