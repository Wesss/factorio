
local ticksPerCheck = 60

local Inspect = require("src.util.inspect")
local TestRunner = require("test.test-runner")

require("src.control.disable-labs-message")
require("src.control.spawn-markets")
local OrderQueue = require("src.control.order-queue")
local OrdersGUI = require("src.control.orders-gui")
local Markets = require("src.control.markets")
local DependencyGraph = require("src.control.graph.dependency-graph")

-- main loop
script.on_nth_tick(60, function(event)
    -- load state
    local orderQueue = storage["OrderQueue"]
    if orderQueue == nil then
        orderQueue = OrderQueue:new()
    end
    -- TODO WESD refactor this getting and setting of dependency graph into static method in module
    local dependencyGraph = storage["DependencyGraph"]
    if dependencyGraph == nil then
        dependencyGraph = DependencyGraph:new()
    end

    -- -- check markets
    local curOrder = orderQueue:getCurrentOrder(dependencyGraph)
    Markets.checkMarkets(curOrder, dependencyGraph)
    OrdersGUI.updateOrdersGUI(orderQueue)
    Markets.updateSignals(curOrder)

    -- TESTING
    -- TestRunner.run({dependencyGraph = dependencyGraph})
    
    -- persist state
    storage["OrderQueue"] = orderQueue
    storage["DependencyGraph"] = dependencyGraph
end)

--when finishing a research, add unlocked items as potential orders
script.on_event(defines.events.on_research_finished, function(event)
    -- TODO WESD refactor this getting and setting of dependency graph into static method in module
    local dependencyGraph = storage["DependencyGraph"]
    if dependencyGraph == nil then
        dependencyGraph = DependencyGraph:new()
    end

    OrderQueue.onResearchFinished(dependencyGraph, event.research)

    storage["DependencyGraph"] = dependencyGraph
end)

-- if mods changed, show warning to player
script.on_configuration_changed(function()
    -- TODO WESD v2 attempt to regenerate orders, market prices, etc
    game.print("MarketSience - mod configuration change detected! note that changing items/recipes mid-run may cause errors or imbalanced progression.")
end)
