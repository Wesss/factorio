
local Inspect = require("src.util.inspect")

local GraphNodeGroup = {}
GraphNodeGroup.__index = GraphNodeGroup

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

function GraphNodeGroup.new(type)
    local instance = {}
    setmetatable(instance, GraphNodeGroup)

    instance.groupingType = type
    -- if and/or dependency, contains other dependency groups to aggregate
    instance.groupDependencies = {}
    -- if leaf dependency, these describe dependency node
    instance.leafNodeType = nil
    instance.leafNodeName = nil
    -- relative number of this dependency needed to satisfy node. ex. ingredients/products per recipe.
    instance.leafNodeScalar = 1

    return instance
end

function GraphNodeGroup:checkReachable(dependencyGraph)
    local groupingType = self.groupingType
    if groupingType == GraphNodeGroup.Types.NONE then
        return true
    elseif groupingType == GraphNodeGroup.Types.AND then
        for _, dependency in ipairs(self.groupDependencies) do
            if not dependency:checkReachable(dependencyGraph) then
                return false
            end
        end
        return true
    elseif groupingType == GraphNodeGroup.Types.OR then
        for _, dependency in ipairs(self.groupDependencies) do
            if dependency:checkReachable(dependencyGraph) then
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

function GraphNodeGroup:getValue(dependencyGraph)
    local groupingType = self.groupingType
    if groupingType == GraphNodeGroup.Types.NONE then
        return 0
    elseif groupingType == GraphNodeGroup.Types.AND then
        local sum = 0
        for _, dependency in ipairs(self.groupDependencies) do
            sum = sum + dependency:getValue(dependencyGraph)
        end
        return sum
    elseif groupingType == GraphNodeGroup.Types.OR then
        local min = nil
        for _, dependency in ipairs(self.groupDependencies) do
            local val = dependency:getValue(dependencyGraph)
            if min == nil then
                min = val
            end
            if val < min then
                min = val
            end
        end
        return min
    elseif groupingType == GraphNodeGroup.Types.LEAF then
        local graphNode = dependencyGraph:getNode(self.leafNodeType, self.leafNodeName)
        return self.leafNodeScalar * graphNode:getValue(dependencyGraph)
    else
        error("MarketSience - ERROR GraphNodeGroup:checkReachable unknown groupingType=" .. groupingType)
    end
end

 -- TODO WESD split this into its own file
local GraphNode = {}
GraphNode.__index = GraphNode

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

function GraphNode.new(nodeType, nodeName)
    local instance = {}
    setmetatable(instance, GraphNode)

    instance.nodeType = nodeType
    -- iron-plate, advanced-coal-processing, etc
    instance.nodeName = nodeName
    -- GraphNodeGroup - points to all graph nodes this node is dependent on
    instance.dependencies = nil

    -- checkReachable, if found to be reachable store state to not re-calc
    instance.foundReachable = false
    -- getValue, store previously computed value to not re-calc
    instance.computedValue = nil

    return instance
end

-- returns true if the dependency referenced by this node is reachable to the player.
function GraphNode:checkReachable(dependencyGraph)
    if self.foundReachable then
        return true
    end

    local res = nil
    local nodeType = self.nodeType
    if (nodeType == GraphNode.Types.ITEM) then
        -- TODO WESD handle this generically, any item that doesn't come from a minable source shouldn't be reachable
        -- note: I think this is handled properly already as it isn't a resource. I typo'd self.nodename but wood was still never reachable.
        -- special case wood, its not a minable resource
        if self.nodeName == "wood" then res = false end
        -- otherwise just check dependencies
    elseif (nodeType == GraphNode.Types.FLUID) then
        -- just check dependencies
    elseif (nodeType == GraphNode.Types.RECIPE) then
        -- return false if recipe is locked.
        local force = game.forces["player"]
        local recipe = force.recipes[self.nodeName]
        if not recipe.enabled then
            res = false
        end

        -- TODO WESD handle loop resolution generically
        -- special case recursive recipes, just don't consider them
        if self.nodeName == "coal-liquefaction" or self.nodeName == "kovarex-enrichment-process" then
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
    local res = self.dependencies:checkReachable(dependencyGraph)
    self.foundReachable = res
    return res
end

-- returns the relative value of this node.
function GraphNode:getValue(dependencyGraph)
    if self.computedValue ~= nil then
        return self.computedValue
    end
    log("TODO WESD flag GraphNode:getValue START type=" .. self.nodeType .. " name=" .. self.nodeName)

    local nodeVal = 0
    local nodeType = self.nodeType
    if (nodeType == GraphNode.Types.ITEM) then
        -- no intrinsic value, value purely from dependencies
    elseif (nodeType == GraphNode.Types.FLUID) then
        -- no intrinsic value, value purely from dependencies
    elseif (nodeType == GraphNode.Types.RECIPE) then
        -- add value equal to crafting time
        local recipe = prototypes.recipe[self.nodeName]
        log("TODO WESD flag GraphNode:getValue recipe value check energy=" .. recipe.energy)
        nodeVal = recipe.energy * (1.0 / 5.0)
        
        -- TODO WESD handle loop resolution generically
        -- special case recursive recipes, just don't consider them
        if self.nodeName == "coal-liquefaction" or self.nodeName == "kovarex-enrichment-process" then
            self.computedValue = 9999
            return self.computedValue
        end
    elseif (nodeType == GraphNode.Types.TECHNOLOGY) then
        -- no intrinsic value, just needs an unlock
    elseif (nodeType == GraphNode.Types.RESOURCE) then
        -- majority of value depends on number of raw resources consumed
        nodeVal = 1
        -- special case water as incredibly cheap
        if self.nodeName == "water" then
            nodeVal = 0.1
        end
    else
        error("MarketSience - ERROR GraphNode:getValue unknown nodeType=" .. (nodeType or ""))
    end

    local depValue = self.dependencies:getValue(dependencyGraph)
    local res = depValue + nodeVal
    self.computedValue = res
    log("TODO WESD flag GraphNode:getValue END type=" .. self.nodeType .. " name=" .. self.nodeName .. " value=" .. res)
    return res
end

script.register_metatable("MarketScience-GraphNode", GraphNode)
script.register_metatable("MarketScience-GraphNodeGroup", GraphNodeGroup)

return {
    GraphNode = GraphNode,
    GraphNodeGroup = GraphNodeGroup
}