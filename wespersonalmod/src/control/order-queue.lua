
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

local curVersion = 2

function OrderQueue:new()
    local instance = {}
    setmetatable(instance, OrderQueue)
    instance.version = curVersion

    instance.orders = {}

    -- used to scale order counts
    instance.ordersCreated = 0

    return instance
end

-- Returns the current order to fill. If fulfilled or missing, handles setting new active order.
function OrderQueue:getCurrentOrder(dependencyGraph)
    -- TODO WESD delete? this is to migrate old queues
    if self.version ~= curVersion then
        self.orders = {}
        self.version = curVersion
    end

    if #self.orders == 0 or self.orders[1]:isFulfilled() then
        table.remove(self.orders, 1)
    end

    while #self.orders < 3 do
        local nextOrder = self:_createNextOrder(dependencyGraph)
        table.insert(self.orders, nextOrder)
    end

    return self.orders[1]
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

    -- calculate order size
    -- TODO WESD v2 take into account science multiplier
    -- make first order be the cost of a single lab
    local orderValMaxBase = MarketValue.GetValue("lab", dependencyGraph)
    -- order, scaling
    -- 0, 1
    -- 50, 2
    -- 100, 5
    -- 150, 10
    -- 200, 17
    local scalingFactor = 1 / 50
    local orderCountScaling = 1 + ((self.ordersCreated * scalingFactor) ^ 2)
    local orderValMax = orderValMaxBase * (1 + orderCountScaling)
    log("TODO WESD _createNextOrder-valmax orderNum=" .. self.ordersCreated .. " scalingval=" .. orderCountScaling .. " orderValMax=" .. orderValMax)

    -- select item
    local selectedItem = nil
    if (self.ordersCreated == 0) then
        -- have first order be a lab
        selectedItem = "lab"
    else
        -- pick a random item
        local itemArray = {}
        for item, _ in pairs(itemsReachable) do
            -- don't pick items that are more expensive than order maximum
            local val = MarketValue.GetValue(item, dependencyGraph)
            if (val < orderValMax) then
                table.insert(itemArray, item)
            end
        end
        local idx = math.random(1, #itemArray)
        selectedItem = itemArray[idx]
    end
    local itemValue = MarketValue.GetValue(selectedItem, dependencyGraph)
    
    local initCnt = orderValMax / itemValue
    -- avoid huge counts of cheaper items.
    local logScaled = logScale(initCnt)
    -- snap to a nice number
    local roundedCnt = roundNice(logScaled)
    log("TODO WESD _createNextOrder-roundedCnt item=" .. selectedItem .. " itemValue=" .. itemValue .. " initCnt=" .. initCnt .. " logScaled=" .. logScaled .. " roundedCnt=" .. roundedCnt)

    local lineItem = LineItem:new(selectedItem, roundedCnt)
    table.insert(newOrder.lineItems, lineItem)

    self.ordersCreated = self.ordersCreated + 1
    -- TODO WESD v2 play a sound
    return newOrder
end

-- rounds to a 'nice' number, relative to scale of the number.
-- step in
-- 1    1
-- 1    3
-- 1    10
-- 5    30
-- 10   100
-- 25   300
-- 50   1000
-- 100  3000
-- 250  10000
-- 500  30000
function roundNice(x)
    x = math.floor(x)
    if x < 20 then
        -- step of 1
        return x
    end
    if x < 30 then
        -- step of 2
        return math.floor(x * 2) / 2
    end

    local log10 = math.floor(math.log10(x))
    local leftDigit = tonumber(tostring(x):sub(1, 1))
    local at3 = 0
    if leftDigit >= 3 then
        at3 = 1
    end

    local scale = (log10 * 2) - 4 + at3
    local vals = {10, 25, 50}
    local base = vals[(scale % 3) + 1]
    local exp = math.floor(scale / 3)
    local step = base * (10 ^ exp)

    return math.floor(x / step) * step
end

 -- todo wesd doc/integrate this
local LOG_BASE = math.log(1.01)
-- https://www.desmos.com/calculator/mjlgsmwpaf
-- linear to 100, then a very stretched out logarithmic growth
function logScale(x)
    if x < 100 then return x end
    local argument = x + 13

    local result = (math.log(argument) / LOG_BASE) - 375
    
    return result
end

-- react to a finished research (https://lua-api.factorio.com/latest/classes/LuaTechnology.html)
function OrderQueue.onResearchFinished(dependencyGraph, research)
    OrderQueue._checkReachable(dependencyGraph, research)
end

-- check for any additional reachable items. if newResearch is present, check all new products as well.
function OrderQueue._checkReachable(dependencyGraph, newResearch)
    -- TODO WESD v2 slowly introduce new recipes in order of complexity/dependency
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
        
        -- TODO WESD unwind safe pcall?
        local ok, result = pcall(function() return graphNode:checkReachable(dependencyGraph) end)
        if not ok then
            -- test call ran into an error
            error("error checking if item is reachable. item=" .. itemName .. " msg=" .. result)
        end
        local isReachable = result
        
        if isReachable then
            itemsToCheck[itemName] = nil
            itemsReachable[itemName] = true
        end
    end

    -- save state
    log("TODO WESD OrderQueue._checkReachable newResearch=" .. (newResearch or {name=""}).name .. " checkstate=" .. Inspect.inspect({itemsToCheck = itemsToCheck, itemsReachable = itemsReachable}))
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
            if product.type == "item" then
                itemsToCheck[product.name] = true
            end
        end
    end

    return itemsToCheck
end

--https://lua-api.factorio.com/latest/classes/LuaBootstrap.html#register_metatable
script.register_metatable("MarketScience-OrderQueue", OrderQueue)

return OrderQueue