
local Inspect = require("src.util.inspect")
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup

local MarketValue = {}

 -- TODO WESD refactor away this file? should just be able to use dependency graph
function MarketValue.GetValue(itemName, dependencyGraph)
    local node = dependencyGraph:getNode(GraphNode.Types.ITEM, itemName)
    return node:getValue(dependencyGraph)
end

function MarketValue.GetTechnologyValue(technologyName, dependencyGraph)
    -- https://lua-api.factorio.com/latest/classes/LuaTechnologyPrototype.html
    local technology = prototypes.technology[technologyName]
    local value = 0
    local unitCount = technology.research_unit_count
    for _, ingredient in pairs(technology.research_unit_ingredients) do
        local node = dependencyGraph:getNode(GraphNode.Types.ITEM, ingredient.name)
        local itemVal = node:getValue(dependencyGraph)
        value = value + (itemVal * ingredient.amount * unitCount)
    end
    return value
end

return MarketValue
