local Inspect = require("src.util.inspect")
local TestUtil = require("test.test-util")

local DependencyGraph = require("src.control.graph.dependency-graph")
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup

local Tests = {}

-- resource no dependencies; minable from start of game
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

-- item from resource
function Tests.addCoalItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "coal")

    local expected = {
        nodeName = "coal",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {{
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "coal",
                leafNodeType = GraphNode.Types.RESOURCE,
                groupDependencies = {}
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["coal"])
end

-- recipe using smelting
function Tests.addIronPlateRecipe()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RECIPE, "iron-plate")

    local expected = {
        nodeName = "iron-plate",
        nodeType = GraphNode.Types.RECIPE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.AND,
            groupDependencies = {{
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "iron-ore",
                leafNodeType = GraphNode.Types.ITEM
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.recipes["iron-plate"])
end

-- item from smelting
function Tests.addIronPlateItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "iron-plate")

    local expected = {
        nodeName = "iron-plate",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {{
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "iron-plate",
                leafNodeType = GraphNode.Types.RECIPE
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["iron-plate"])
end

-- recipe with single input
function Tests.addIronGearRecipe()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RECIPE, "iron-gear-wheel")

    local expected = {
        nodeName = "iron-gear-wheel",
        nodeType = GraphNode.Types.RECIPE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.AND,
            groupDependencies = {{
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "iron-plate",
                leafNodeType = GraphNode.Types.ITEM
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.recipes["iron-gear-wheel"])
end

-- item with single recipe
function Tests.addIronGearItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "iron-gear-wheel")

    local expected = {
        nodeName = "iron-gear-wheel",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {{
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "iron-gear-wheel",
                leafNodeType = GraphNode.Types.RECIPE
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["iron-gear-wheel"])
end

-- recipe with multiple item inputs
function Tests.addCircuitRecipe()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RECIPE, "electronic-circuit")

    local expected = {
        nodeName = "electronic-circuit",
        nodeType = GraphNode.Types.RECIPE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.AND,
            groupDependencies = {{
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "iron-plate",
                leafNodeType = GraphNode.Types.ITEM
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "copper-cable",
                leafNodeType = GraphNode.Types.ITEM
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.recipes["electronic-circuit"])
end

-- item with multiple recipes
function Tests.addSolidFuelItem()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.ITEM, "solid-fuel")

    local expected = {
        nodeName = "solid-fuel",
        nodeType = GraphNode.Types.ITEM,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = {{
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "solid-fuel-from-petroleum-gas",
                leafNodeType = GraphNode.Types.RECIPE
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "solid-fuel-from-light-oil",
                leafNodeType = GraphNode.Types.RECIPE
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "solid-fuel-from-heavy-oil",
                leafNodeType = GraphNode.Types.RECIPE
            }}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.items["solid-fuel"])
end

-- water fluid edge case
function Tests.addWaterFluid()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.FLUID, "water")

    local expected = {
        nodeName = "water",
        nodeType = GraphNode.Types.FLUID,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = { {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "water",
                leafNodeType = GraphNode.Types.RESOURCE,
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "empty-water-barrel",
                leafNodeType = GraphNode.Types.RECIPE,
            } },
        },
    }

    log(Inspect.inspect(dependencyGraph.fluids["water"]))
    return TestUtil.GraphNodeMatches(expected, dependencyGraph.fluids["water"])
end

-- TODO WESD LAST water resource edge case
-- TODO WESD fluid from resource
-- TODO WESD fluid from recipe
-- TODO WESD resource mining from pumpjack
-- TODO WESD resource mining using fluid input
-- TODO WESD technology

return Tests
