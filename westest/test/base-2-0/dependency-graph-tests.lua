
local Inspect = require("src.util.inspect")
local TestUtil = require("test.test-util")

local DependencyGraph = require("src.control.graph.dependency-graph")
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup

local Tests = {}

-- no dependencies; minable from start of game
function Tests.addCoalResource()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RESOURCE, "coal")

    local expected = {
        nodeName = "coal",
        nodeType = GraphNode.Types.RESOURCE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.NONE,
            groupDependencies = {}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.resources["coal"])
end

-- comes from resource
function Tests.addCoalItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "coal")

    local expected = {
        nodeName = "coal",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {
                {
                    groupingType = GraphNodeGroup.Types.LEAF,
                    leafNodeName = "coal",
                    leafNodeType = GraphNode.Types.RESOURCE,
                    groupDependencies = {},
                }
            }
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["coal"])
end

-- single smelting recipe
function Tests.addIronPlateItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "iron-plate")

    local expected = {
        nodeName = "iron-plate",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {
                {
                    groupDependencies = {},
                    groupingType = GraphNodeGroup.Types.LEAF,
                    leafNodeName = "iron-plate",
                    leafNodeType = GraphNode.Types.RECIPE,
                }
            },
        },
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["iron-plate"])
end

-- single input to recipe
function Tests.addIronGearRecipe()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RECIPE, "iron-gear-wheel")

    local expected = {
        nodeName = "iron-gear-wheel",
        nodeType = GraphNode.Types.RECIPE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.AND,
            groupDependencies = {
                {
                    groupDependencies = {},
                    groupingType = GraphNodeGroup.Types.LEAF,
                    leafNodeName = "iron-plate",
                    leafNodeType = GraphNode.Types.ITEM,
                }
            }
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.recipes["iron-gear-wheel"])
end

-- single crafting recipe
function Tests.addIronGearItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "iron-gear-wheel")

    local expected = {
        nodeName = "iron-gear-wheel",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {
                {
                    groupDependencies = {},
                    groupingType = GraphNodeGroup.Types.LEAF,
                    leafNodeName = "iron-gear-wheel",
                    leafNodeType = GraphNode.Types.RECIPE,
                }
            },
        },
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["iron-gear-wheel"])
end

return Tests
