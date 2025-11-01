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

return Tests
