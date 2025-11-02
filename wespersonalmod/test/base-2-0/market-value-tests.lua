local Inspect = require("src.util.inspect")
local TestUtil = require("test.test-util")

local DependencyGraph = require("src.control.graph.dependency-graph")
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup
local MarketValue = require("src.control.market-value")

local Tests = {}

-- basic minable item
function Tests.marketValueCoal()
    local dependencyGraph = DependencyGraph.new()
    local actual = MarketValue.GetValue("coal", dependencyGraph)

    if actual <= 0 then
        return {success = false, message = "Item value <= 0. value=" .. actual}
    end
    return {success = true}
end

-- recursive item (coal liquification takes heavy oil and produces heavy oil)
function Tests.marketValueHeavyOil()
    local dependencyGraph = DependencyGraph.new()

    -- testing
    dependencyGraph:getNode(GraphNode.Types.ITEM, "heavy-oil-barrel")
    log(Inspect.inspect(dependencyGraph))

    local actual = MarketValue.GetValue("heavy-oil-barrel", dependencyGraph)

    if actual <= 0 then
        return {success = false, message = "Item value <= 0. value=" .. actual}
    end
    return {success = true}
end

 -- TODO WESD add uranium ore test (goes through uranium mining, which need fluid mining)

-- requires mining with fluid
function Tests.marketValueUraniumOre()
    local dependencyGraph = DependencyGraph.new()

    -- testing
    -- dependencyGraph:getNode(GraphNode.Types.ITEM, "uranium-ore")
    -- log(Inspect.inspect(dependencyGraph))

    local actual = MarketValue.GetValue("uranium-ore", dependencyGraph)

    if actual <= 0 then
        return {success = false, message = "Item value <= 0. value=" .. actual}
    end
    return {success = true}
end

 -- TODO WESD LAST bug, unsure of issue atm
function Tests.marketValueUranium238()
    local dependencyGraph = DependencyGraph.new()

    -- testing
    dependencyGraph:getNode(GraphNode.Types.ITEM, "uranium-238")
    log(Inspect.inspect(dependencyGraph))

    local actual = MarketValue.GetValue("uranium-238", dependencyGraph)

    if actual <= 0 then
        return {success = false, message = "Item value <= 0. value=" .. actual}
    end
    return {success = true}
end

return Tests
