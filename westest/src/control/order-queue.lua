
local inspect = require("src.util.inspect")
local orderModule = require("src.control.order")
local Order = orderModule.Order
local LineItem = orderModule.LineItem

-- Handles generation and flow of orders for markets to fulfil
local OrderQueue = {}
OrderQueue.__index = OrderQueue
--https://lua-api.factorio.com/latest/classes/LuaBootstrap.html#register_metatable
script.register_metatable("OrderQueue", OrderQueue)

function OrderQueue:new()
    local instance = {}
    setmetatable(instance, OrderQueue)

    instance.storageState = {}
    instance.currentOrder = nil
    -- TODO WESD add a concept of the next order/upcoming queue to preview to players.

    return instance
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

    -- TODO WESD v1 dynamically manage list of available items to create orders from
    local itemPool = {"iron-plate", "copper-plate", "iron-ore", "copper-ore"}
    local selectedItem = itemPool[math.random(1, #itemPool)]
    -- TODO WESD v1 create notion of order value size, calculate cnts based on market values
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
            -- TODO WESD v1 dev this out, hook into dependecy graph generation
            -- OrderQueue._updateUnlockStateItem(itemName)
        end
    end
end


return OrderQueue