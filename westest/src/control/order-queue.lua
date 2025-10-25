
local Inspect = require("src.util.inspect")
local orderModule = require("src.control.order")
local Order = orderModule.Order
local LineItem = orderModule.LineItem
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup
local MarketValue = require("src.control.market-value")

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

    -- used to scale order counts
    instance.ordersCreated = 0

    return instance
end

-- Returns the current order to fill. If fulfilled or missing, handles setting new active order.
function OrderQueue:getCurrentOrder(dependencyGraph)
    if self.currentOrder == nil or self.currentOrder:isFulfilled() then
        self.currentOrder = self:_createNextOrder(dependencyGraph)
    end
    return self.currentOrder
end

-- generates the next order to fulfill
function OrderQueue:_createNextOrder(dependencyGraph)
    local newOrder = Order:new()

    local itemsReachable = storage["OrderQueue.itemsReachable"]
    if itemsReachable == nil then
        -- init order item pool
        OrderQueue._checkReachable(dependencyGraph, nil)
    end
    local itemsReachable = storage["OrderQueue.itemsReachable"]

    local selectedItem = nil
    if (self.ordersCreated == 0) then
        -- have first order be a lab
        selectedItem = "lab"
    else
        -- pick a random item
        local itemArray = {}
        for i, _ in pairs(itemsReachable) do
            table.insert(itemArray, i)
        end
        local idx = math.random(1, #itemArray)
        selectedItem = itemArray[idx]
    end

    -- calculate order size
    -- TODO WESD take into account science multiplier
    -- make first order be the cost of a single lab
    local orderValMaxBase = MarketValue.GetValue("lab", dependencyGraph)
    -- 1 / 50 means it takes 50 orders for order size to first double
    local scalingFactor = 1 / 50
    local orderValMax = orderValMaxBase * (1 + ((self.ordersCreated * scalingFactor) ^ 1.5))
    local itemValue = MarketValue.GetValue(selectedItem, dependencyGraph)
    -- TODO WESD snap this to a 'nice' number
    local selectedCnt = math.floor(orderValMax / itemValue)

    local lineItem = LineItem:new(selectedItem, selectedCnt)
    table.insert(newOrder.lineItems, lineItem)

    self.ordersCreated = self.ordersCreated + 1
    return newOrder
end

-- react to a finished research (https://lua-api.factorio.com/latest/classes/LuaTechnology.html)
function OrderQueue.onResearchFinished(dependencyGraph, research)
    OrderQueue._checkReachable(dependencyGraph, research)
end

-- check for any additional reachable items. if newResearch is present, check all new products as well.
function OrderQueue._checkReachable(dependencyGraph, newResearch)
    local itemsToCheck = storage["OrderQueue.itemsToCheck"]
    if itemsToCheck == nil then
        itemsToCheck = OrderQueue._initItemsToCheck()
    end

    local itemsReachable = storage["OrderQueue.itemsReachable"]
    if itemsReachable == nil then
        itemsReachable = {}
    end

    if newResearch ~= nil then
        -- add all unlocked recipe's products to unlocked items set
        for _, effect in pairs(newResearch.prototype.effects) do
            if effect.type == "unlock-recipe" then
                local recipe = prototypes.recipe[effect.recipe]
                for _, product in ipairs(recipe.products) do
                    if product.type == "item" then
                        local itemName = product.name
                        itemsToCheck[itemName] = true
                    end
                end
            end
        end
    end

    for itemName, _ in pairs(itemsToCheck) do
        local graphNode = dependencyGraph:getNode(GraphNode.Types.ITEM, itemName)
        local isReachable = graphNode:checkReachable(dependencyGraph)
        if isReachable then
            itemsToCheck[itemName] = nil
            itemsReachable[itemName] = true
        end
    end

    -- save state
    log("TODO WESD OrderQueue._checkReachable " .. Inspect.inspect({itemsToCheck = itemsToCheck, itemsReachable = itemsReachable}))
    storage["OrderQueue.itemsToCheck"] = itemsToCheck
    storage["OrderQueue.itemsReachable"] = itemsReachable
end

-- returns set of all products of all unlocked recipes
function OrderQueue._initItemsToCheck()
    local itemsToCheck = {}
    local force = game.forces["player"]
    for _, recipe in pairs(force.recipes) do
        if recipe.enabled then
            for _, product in ipairs(recipe.products) do
                if product.type == "item" then
                    local itemName = product.name
                    itemsToCheck[itemName] = true
                end
            end
        end
    end
    -- add resources to set to check.
    -- it may be wasteful to check advanced resources such as uranium a bit, but it shouldn't be too bad.
    local resources = prototypes.get_entity_filtered({{filter = "type", type = "resource"}})
    for _, resource in pairs(resources) do
        for _, product in ipairs(resource.mineable_properties.products) do
            itemsToCheck[product.name] = true
        end
    end

    return itemsToCheck
end

return OrderQueue