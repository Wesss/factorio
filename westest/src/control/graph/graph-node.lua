
local inspect = require("src.util.inspect")

local GraphNodeGroup = {}
GraphNodeGroup.__index = GraphNodeGroup
script.register_metatable("GraphNodeGroup", GraphNodeGroup)

-- enum of node types for describing/aggregating dependencies
GraphNodeGroup.Types = {
    -- no dependencies, always accessible
    NONE = "NONE",
    -- dependent on named node (naming NODE looks too similar to NONE)
    LEAF = "LEAF",
    -- dependent on all children being satisfied
    AND = "AND",
    -- dependent on at least one child being satisfied
    OR = "OR"
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

function GraphNodeGroup:checkReachable(dependencyGraph)
    local groupingType = self.groupingType
    if groupingType == GraphNodeGroup.Types.NONE then
        return true
    elseif groupingType == GraphNodeGroup.Types.AND then
        for _, dependency in ipairs(self.groupDependenies) do
            if not dependency:checkReachable() then
                return false
            end
        end
        return true
    elseif groupingType == GraphNodeGroup.Types.OR then
        for _, dependency in ipairs(self.groupDependenies) do
            if dependency:checkReachable() then
                return true
            end
        end
        return false
    elseif groupingType == GraphNodeGroup.Types.LEAF then
        local graphNode = dependencyGraph:getNode(self.leafNodeType, self.leafNodeName)
        return graphNode:checkReachable(dependencyGraph)
    else
        error("MarketSience - ERROR GraphNodeGroup:checkReachable unknown groupingType=" .. groupingType)
    end
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

    -- checkReachable, if found to be reachable store state to not re-calc
    instance.foundReachable = false

    return instance
end

function GraphNode:checkReachable(dependencyGraph)
    if self.foundReachable then
        return true
    end

    local res = nil
    local nodeType = self.nodeType
    if (nodeType == GraphNode.Types.ITEM) then
        -- just check dependencies
    elseif (nodeType == GraphNode.Types.FLUID) then
        -- just check dependencies
    elseif (nodeType == GraphNode.Types.RECIPE) then
        -- return false if recipe is locked.
        local force = game.forces["player"]
        local recipe = force.recipes[self.nodeName]
        if not recipe.enabled then
            res = false
        end
    elseif (nodeType == GraphNode.Types.TECHNOLOGY) then
        -- return false if technolgy is not researched
        local force = game.forces["player"]
        local recipe = force.technologies[self.nodeName]
        if not recipe.researched then
            res = false
        end
    elseif (nodeType == GraphNode.Types.RESOURCE) then
        -- just check dependencies
    else
        error("MarketSience - ERROR GraphNode:checkReachable unknown nodeType=" .. nodeType)
    end

    if res ~= nil then
        self.foundReachable = res
        return res
    end
    
    -- check dependencies
    local res = self.dependencies.checkReachable()
    self.foundReachable = res
    return res
end

return {
    GraphNode = GraphNode,
    GraphNodeGroup = GraphNodeGroup
}