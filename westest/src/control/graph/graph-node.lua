
local inspect = require("src.util.inspect")

local GraphNodeGroup = {}
GraphNodeGroup.__index = GraphNodeGroup
script.register_metatable("GraphNodeGroup", GraphNodeGroup)

-- enum of node types for describing/aggregating dependencies
GraphNodeGroup.Types = {
    -- dependent on named node (naming NODE looks too similar to NONE)
    LEAF = "LEAF",
    -- dependent on all children being satisfied
    AND = "AND",
    -- dependent on at least one child being satisfied
    OR = "OR",
    -- no dependencies, always accessible
    NONE = "NONE"
}

function GraphNodeGroup:new(type)
    local instance = {}
    setmetatable(instance, GraphNodeGroup)

    instance.groupingType = type;
    -- if leaf dependency, these describe dependency node
    instance.leafNodeType = nil;
    instance.leafNodeName = nil;
    -- if and/or dependency, contains other dependency groups to aggregate
    instance.groupDependencies = {};

    return instance
end

local GraphNode = {}
GraphNode.__index = GraphNode
script.register_metatable("GraphNode", GraphNode)

-- enum of node types for describing/aggregating dependencies
GraphNode.Types = {
    -- represents a research that can be completed to unlock effects or recipes
    TECHNOLOGY = "TECHNOLOGY",
    -- represents a recipe to create items
    RECIPE = "RECIPE",
    -- represents a type of item (holdable by player, used in crafting/placing)
    ITEM = "ITEM",
    -- represents a type of fluid (not holdable/placable, used in crafting)
    FLUID = "FLUID",
    -- represents a raw resource the player can obtain through mining/pumping
    RESOURCE = "RESOURCE"
}

function GraphNode:new(nodeType, nodeName)
    local instance = {}
    setmetatable(instance, GraphNode)

    instance.nodeType = nodeType
    -- iron-plate, advanced-coal-processing, etc
    instance.nodeName = nodeName
    -- GraphNodeGroup - points to all graph nodes this node is dependent on
    instance.dependencies = nil

    return instance
end


return {
    GraphNode = GraphNode,
    GraphNodeGroup = GraphNodeGroup
}