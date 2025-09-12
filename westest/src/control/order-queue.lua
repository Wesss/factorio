
local inspect = require("src.util.inspect")
local orderModule = require("src.control.order")
local Order = orderModule.Order
local LineItem = orderModule.LineItem

-- Handles generation and flow of orders for markets to fulfil
local OrderQueue = {}
OrderQueue.__index = OrderQueue

function OrderQueue:new()
    local instance = {}
    setmetatable(instance, OrderQueue)

    -- TODO WESD add a concept of the next order/upcoming queue to preview to players.
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
    if self.currentOrder == nil or self.currentOrder:isFulfilled() then
        self.currentOrder = OrderQueue._createNextOrder()
    end
    return self.currentOrder
end

-- generates the next order to fulfill
function OrderQueue._createNextOrder()
    local newOrder = Order:new()

    -- TODO WESD dynamically manage list of available items to create orders from
    local itemPool = {"iron-plate", "copper-plate", "iron-ore", "copper-ore"}
    local selectedItem = itemPool[math.random(1, #itemPool)]
    -- TODO WESD create notion of order value size, calculate cnts based on market values
    local cntPool = {100, 200, 500}
    local selectedCnt = cntPool[math.random(1, #cntPool)]
    local lineItem = LineItem:new(selectedItem, selectedCnt)
    table.insert(newOrder.lineItems, lineItem)
    return newOrder
end

-- notifies order queue that this recipe is unlocked. may add products to potential orders
function OrderQueue.updateUnlockState(recipe)
    for _, product in ipairs(recipe.products) do
        if product.type ~= "research-progress" then
            local itemName = product.name
            -- TODO WESD LAST dev this out
            -- OrderQueue._updateUnlockStateItem(itemName)
        end
    end
end

-- function OrderQueue._updateUnlockStateItem(itemName)
--     -- TODO WESD
-- end


return OrderQueue