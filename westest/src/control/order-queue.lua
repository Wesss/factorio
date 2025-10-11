
local inspect = require("src.util.inspect")
local orderModule = require("src.control.order")
local Order = orderModule.Order
local LineItem = orderModule.LineItem
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup

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
function OrderQueue:getCurrentOrder(dependencyGraph)
    if self.currentOrder == nil or self.currentOrder:isFulfilled() then
        self.currentOrder = OrderQueue._createNextOrder(dependencyGraph)
    end
    return self.currentOrder
end

-- generates the next order to fulfill
function OrderQueue._createNextOrder(dependencyGraph)
    local newOrder = Order:new()


    local itemsReachable = storage["OrderQueue.itemsReachable"]
    if itemsReachable == nil then
        -- init order item pool
        OrderQueue._checkReachable(dependencyGraph, nil)
    end
    local itemsReachable = storage["OrderQueue.itemsReachable"]

    -- pick a random item
    local itemArray = {}
    for i, _ in pairs(itemsReachable) do
        table.insert(itemArray, i)
    end
    local idx = math.random(1, #itemArray)
    local selectedItem = itemArray[idx]

    -- TODO WESD v1 create notion of order value size, calculate cnts based on market values
    local cntPool = {100, 200, 500}
    local selectedCnt = cntPool[math.random(1, #cntPool)]
    local lineItem = LineItem:new(selectedItem, selectedCnt)
    table.insert(newOrder.lineItems, lineItem)
    return newOrder
end

-- react to a finished research (https://lua-api.factorio.com/latest/classes/LuaTechnology.html)
function OrderQueue.onItemRecipeUnlock(dependencyGraph, research)
    OrderQueue._checkReachable(dependencyGraph, research)
end

function OrderQueue._checkReachable(dependencyGraph, newResearch)
    local itemsUnlocked = storage["OrderQueue.itemsUnlocked"]
    if itemsUnlocked == nil then
        itemsUnlocked = OrderQueue._initItemsUnlocked()
    end

    local itemsReachable = storage["OrderQueue.itemsReachable"]
    if itemsReachable == nil then
        itemsReachable = {}
    end

    -- add all unlocked recipe's products to unlocked items set
    if newResearch ~= nil then
        for _, effect in ipairs(newResearch.effects) do
            if effect.type == "unlock-recipe" then
                local recipe = prototypes.recipe[effect.recipe]
                for _, product in ipairs(recipe.products) do
                    if product.type == "item" then
                        local itemName = product.name
                        itemsUnlocked[itemName] = true
                    end
                end
            end
        end
    end

    for itemName, _ in itemsUnlocked do
        local graphNode = dependencyGraph:getNode(GraphNode.Types.ITEM, itemName)
        local isReachable = graphNode:checkReachable(dependencyGraph)
        if isReachable then
            itemsUnlocked[itemName] = nil
            itemsReachable[itemName] = true
        end
    end

    -- save state
    storage["OrderQueue.itemsUnlocked"] = itemsUnlocked
    storage["OrderQueue.itemsReachable"] = itemsReachable
end

-- returns set of all products of all unlocked recipes
function OrderQueue._initItemsUnlocked()
    local itemsUnlocked = {}
    local force = game.forces["player"]
    for _, recipe in pairs(force.recipes) do
        if recipe.enabled then
            for _, product in ipairs(recipe.products) do
                if product.type == "item" then
                    local itemName = product.name
                    itemsUnlocked[itemName] = true
                end
            end
        end
    end
    return itemsUnlocked
end

return OrderQueue