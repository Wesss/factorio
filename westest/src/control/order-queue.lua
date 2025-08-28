-- local util = require("util")
local inspect = require("src.util.inspect")
local orderModule = require("src.control.order")
local Order = orderModule.Order
local LineItem = orderModule.LineItem
-- local table = require("__flib__/table")

-- Handles generation and flow of orders for markets to fulfil
local OrderQueue = {}
OrderQueue.__index = OrderQueue

function OrderQueue:new()
    local instance = {}
    setmetatable(instance, OrderQueue)

    instance.currentOrder = nil

    return instance
end

-- returns the order queue. If missing, generates a new one
function OrderQueue.load()
    -- TODO WESD load from storage
    local queue = nil
    if queue == nil then
        queue = OrderQueue:new()
    end
    return queue
end

-- persists the given order queue in storage
function OrderQueue:save()
    -- TODO WESD persist to storage
end

-- Returns the current order to fill. If fulfilled or missing, handles setting new active order.
function OrderQueue:getCurrentOrder()
    local curOrder = self.currentOrder
    if curOrder == nil or curOrder:isFullfilled() then
        curOrder = Order:new()
        self.currentOrder = curOrder
        -- TODO WESD implement actual order generation
        local lineItem = LineItem:new("iron-plate", 100)
        table.insert(curOrder.lineItems, lineItem)
    end

    return curOrder
end

return OrderQueue