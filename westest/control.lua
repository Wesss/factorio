
local ticksPerCheck = 60

local inspect = require("src.util.inspect")
local TestRunner = require("test.test-runner")

require("src.control.disable-labs-message")
require("src.control.spawn-markets")
local OrderQueue = require("src.control.order-queue")
local OrdersGUI = require("src.control.orders-gui")
local Markets = require("src.control.markets")
local DependencyGraph = require("src.control.graph.dependency-graph")

-- -- TODO WESD on game start, add all unlocked items to the order queue
-- script.on_event(defines.events.on_init, function(event)
--     -- TODO WESD if more than default forces exist, print an error message to players
--     local force = game.forces["player"]

--     for name, recipe in pairs(force.recipes) do
--         -- Check if the recipe is not already enabled (optional, but good practice)
--         if recipe.enabled then
--             OrderQueue.updateUnlockState(recipe)
--         end
--     end
-- end)

-- main loop
script.on_nth_tick(60, function(event)
    -- load state
    local orderQueue = storage["OrderQueue"]
    if orderQueue == nil then
        orderQueue = OrderQueue:new()
    end
    local dependencyGraph = storage["DependencyGraph"]
    if dependencyGraph == nil then
        dependencyGraph = DependencyGraph:new()
    end

    -- -- check markets
    -- local curOrder = orderQueue:getCurrentOrder()
    -- Markets.checkMarkets(curOrder)
    -- OrdersGUI.updateOrdersGUI(orderQueue)

    -- TESTING
    TestRunner.run({dependencyGraph = dependencyGraph})
    
    -- persist state
    storage["OrderQueue"] = orderQueue
    storage["DependencyGraph"] = dependencyGraph
end)

-- when finishing a research, add unlocked items as potential orders
-- script.on_event(defines.events.on_research_finished, function(event)
--     for _, effect in ipairs(research.effects) do
--         if effect.type == "unlock-recipe" then
--             OrderQueue.updateUnlockState(effect.recipe)
--         end
--     end
-- end)

-- if mods changed, show warning to player
script.on_configuration_changed(function()
    -- TODO WESD attempt to regenerate orders, market prices, etc
    game.print("Science Markets - mod configuration change detected! note that changing items/recipes mid-run may cause errors or imbalanced progression.")
end)