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

-- persists the given order queue in storage
function OrderQueue:save()
    storage.orderQueue = self:toStorageFormat()
end

-- returns a table representation of this that can be written to storage. does not contain metatable (cant call class functions)
function OrderQueue:toStorageFormat()
    return {
        currentOrder = self.currentOrder:toStorageFormat()
    }
end

-- returns the order queue. If missing, generates a new one
function OrderQueue.load()
    return OrderQueue.fromStorageFormat(storage.orderQueue)
end

-- returns an instance of this, initialized from its storage table
function OrderQueue.fromStorageFormat(storageOrderQueue)
    local orderQueue = OrderQueue:new()

    if storageOrderQueue ~= nil then
        orderQueue.currentOrder = Order.fromStorageFormat(storageOrderQueue.currentOrder)
    end

    return orderQueue
end

-- Returns the current order to fill. If fulfilled or missing, handles setting new active order.
function OrderQueue:getCurrentOrder()
    local curOrder = self.currentOrder
    if curOrder == nil or curOrder:isFulfilled() then
        curOrder = Order:new()
        self.currentOrder = curOrder
        -- TODO WESD implement actual order generation
        local lineItem = LineItem:new("iron-plate", 100)
        table.insert(curOrder.lineItems, lineItem)
    end

    return curOrder
end

return OrderQueue