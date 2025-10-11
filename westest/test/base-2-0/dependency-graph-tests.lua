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
    -- TODO WESD change all tests to use getNode instead
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

-- water resource edge case
function Tests.addWaterResource()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RESOURCE, "water")

    local expected = {
        nodeName = "water",
        nodeType = GraphNode.Types.RESOURCE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.NONE,
            groupDependencies = {}
        }
    }

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.resources["water"])
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

    return TestUtil.GraphNodeMatches(expected, dependencyGraph.fluids["water"])
end

-- pumpjack research
function Tests.addOilGatheringTechnology()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.TECHNOLOGY, "oil-gathering")
    local actual = dependencyGraph.technologies["oil-gathering"]

    local expected = {
        nodeName = "oil-gathering",
        nodeType = GraphNode.Types.TECHNOLOGY,
        dependencies = {
            groupDependencies = {},
            groupingType = GraphNodeGroup.Types.NONE,
        },
    }

    return TestUtil.GraphNodeMatches(expected, actual)
end

-- fluid resource from pumpjack
function Tests.addCrudeOilResource()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RESOURCE, "crude-oil")
    local actual = dependencyGraph.resources["crude-oil"]

    local expected = {
        nodeName = "crude-oil",
        nodeType = GraphNode.Types.RESOURCE,
        dependencies = {
            groupDependencies = {},
            groupingType = GraphNodeGroup.Types.LEAF,
            leafNodeName = "oil-gathering",
            leafNodeType = GraphNode.Types.TECHNOLOGY,
        },
    }

    return TestUtil.GraphNodeMatches(expected, actual)
end

-- fluid from resource
function Tests.addCrudeOilFluid()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.FLUID, "crude-oil")
    local actual = dependencyGraph.fluids["crude-oil"]

    local expected = {
        nodeName = "crude-oil",
        nodeType = GraphNode.Types.FLUID,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = { {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "crude-oil",
                leafNodeType = GraphNode.Types.RESOURCE,
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "empty-crude-oil-barrel",
                leafNodeType = GraphNode.Types.RECIPE,
            } },
        },
    }

    return TestUtil.GraphNodeMatches(expected, actual)
end

-- fluid from recipe
function Tests.addLubricant()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.FLUID, "lubricant")
    local actual = dependencyGraph.fluids["lubricant"]

    local expected = {
        nodeName = "lubricant",
        nodeType = GraphNode.Types.FLUID,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = { {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "lubricant",
                leafNodeType = GraphNode.Types.RECIPE,
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "empty-lubricant-barrel",
                leafNodeType = GraphNode.Types.RECIPE,
            } },
        },
    }

    return TestUtil.GraphNodeMatches(expected, actual)
end

-- resource mining using fluid
function Tests.addUraniumResource()
    local dependencyGraph = DependencyGraph:new()
    dependencyGraph:addNode(GraphNode.Types.RESOURCE, "uranium-ore")
    local actual = dependencyGraph.resources["uranium-ore"]

    local expected = {
        nodeName = "uranium-ore",
        nodeType = GraphNode.Types.RESOURCE,
        dependencies = {
            groupingType = GraphNodeGroup.Types.OR,
            groupDependencies = { {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "uranium-mining",
                leafNodeType = GraphNode.Types.TECHNOLOGY,
            }, {
                groupDependencies = {},
                groupingType = GraphNodeGroup.Types.LEAF,
                leafNodeName = "sulfuric-acid",
                leafNodeType = GraphNode.Types.ITEM,
            } },
        },
    }

    return TestUtil.GraphNodeMatches(expected, actual)
end

return Tests
