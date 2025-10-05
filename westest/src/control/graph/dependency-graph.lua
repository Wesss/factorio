
local inspect = require("src.util.inspect")

local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup

-- represents various game components (recipes, technologies, items, resources, etc) and what other components are needed to obtain them.
local DependencyGraph = {}
DependencyGraph.__index = DependencyGraph

function DependencyGraph:new()
    local instance = {}
    setmetatable(instance, DependencyGraph)

    -- dict itemName -> GraphNode
    instance.items = {}
    -- dict fluidName -> GraphNode
    instance.fluids = {}
    -- dict recipeName -> GraphNode
    instance.recipes = {}
    -- dict technologyName -> GraphNode
    instance.technologies = {}
    -- dict resourceName -> GraphNode
    instance.resources = {}
    
    return instance
end

-- returns the graph node of the given type/name. nil if does not exist
function DependencyGraph:getNode(nodeType, nodeName)
    local dict = nil
    if (nodeType == GraphNode.Types.ITEM) then
        dict = self.items
    elseif (nodeType == GraphNode.Types.FLUID) then
        dict = self.fluids
    elseif (nodeType == GraphNode.Types.RECIPE) then
        dict = self.recipes
    elseif (nodeType == GraphNode.Types.TECHNOLOGY) then
        dict = self.technologies
    elseif (nodeType == GraphNode.Types.RESOURCE) then
        dict = self.resources
    else
        error("MarketSience - ERROR DependencyGraph:getNode unknown nodeType=" .. nodeType)
    end

    return dict[nodeName]
end

-- adds a node of the given type/name to the dependency graph & calculates dependencies
function DependencyGraph:addNode(nodeType, nodeName)
    if (nodeType == GraphNode.Types.ITEM) then
        self:_addItemNode(nodeName)
    elseif (nodeType == GraphNode.Types.FLUID) then
        self:_addFluidNode(nodeName)
    elseif (nodeType == GraphNode.Types.RECIPE) then
        self:_addRecipeNode(nodeName)
    elseif (nodeType == GraphNode.Types.TECHNOLOGY) then
        self:_addTechnologyNode(nodeName)
    elseif (nodeType == GraphNode.Types.RESOURCE) then
        self:_addResourceNode(nodeName)
    else
        error("MarketScience - ERROR DependencyGraph:getNode unknown nodeType=" .. nodeType)
    end
end

-- returns minable properties of the given item if its a minable resource. nil otherwise.
-- https://lua-api.factorio.com/latest/concepts/MineableProperties.html
function DependencyGraph._getMineableProperties(itemName)
    if (storage.minableResources == nil) then
        local minableResources = {}
        storage.minableResources = minableResources

        local resources = prototypes.get_entity_filtered({{filter = "type", type = "resource"}})
        for name, r in pairs(resources) do
            minableResources[name] = r.mineable_properties
        end
    end

    return storage.minableResources[itemName]
end

-- adds the given resource by name to the dependency graph
function DependencyGraph:_addResourceNode(resourceName)
    local node = GraphNode:new()
    self.resources[resourceName] = node
    node.nodeType = GraphNode.Types.RESOURCE
    node.nodeName = resourceName

    local dependencies = GraphNodeGroup:new()
    node.dependencies = dependencies

    -- special case water, it is not mineable. assume it to be available.
    -- TODO WESD water should depend on availability of offshore pump or other way to produce.
    if (resourceName == "water") then
        dependencies.groupingType = GraphNodeGroup.Types.NONE
        return
    end

    local mineable = DependencyGraph._getMineableProperties(resourceName)
    if (#mineable.products > 1) then
        error("Unhandled case: multiple mining products. resourceName=" .. resourceName)
    elseif (#mineable.products < 1) then
        error("attempting to add resource that is un-mineable. resourceName=" .. resourceName)
    end

    -- TODO WESD figure this out more dynamically. make each minable entity dependent on
    -- OR(unlock of simplest miner, incl. player intrinsicly)
    local product = mineable.products[1]
    if (product.type == "fluid") then
        -- TODO WESD "oil-gathering" for pumpjacks is hardcoded here.
        -- rework to dynamically figure out if gatherer (pumpjack or otherwise) is available.
        dependencies.groupingType = GraphNodeGroup.Types.LEAF
        dependencies.leafNodeType = GraphNode.Types.TECHNOLOGY
        dependencies.leafNodeName = "oil-gathering"
    elseif (mineable.required_fluid ~= nil) then
        -- fluid mining requires technology unlock + access to required fluid
        dependencies.groupingType = GraphNodeGroup.Types.OR
        -- TODO WESD "uranium-mining" for mining with fluid input is hardcoded here.
        -- rework to dynamically figure out if fluid mining is available.
        local techDependency = GraphNodeGroup:new()
        table.insert(dependencies.groupDependencies, techDependency)
        techDependency.groupingType = GraphNodeGroup.Types.LEAF
        techDependency.leafNodeType = GraphNode.Types.TECHNOLOGY
        techDependency.leafNodeName = "uranium-mining"
        
        -- add dependency on the fluid
        local fluidDependency = GraphNodeGroup:new()
        table.insert(dependencies.groupDependencies, fluidDependency)
        fluidDependency.groupingType = GraphNodeGroup.Types.LEAF
        fluidDependency.leafNodeType = GraphNode.Types.ITEM
        fluidDependency.leafNodeName = mineable.required_fluid
    else
        -- otherwise, assume we're able to mine without issue from the start of the game.
        dependencies.groupingType = GraphNodeGroup.Types.NONE
    end
end

-- adds the given item by name to the dependency graph
function DependencyGraph:_addItemNode(itemName)
    local node = GraphNode:new()
    self.items[itemName] = node
    node.nodeType = GraphNode.Types.ITEM
    node.nodeName = itemName
    node.dependencies = DependencyGraph._getItemFluidDependencies(itemName, false)
end

-- adds the given fluid by name to the dependency graph
function DependencyGraph:_addFluidNode(fluidName)
    local node = GraphNode:new()
    self.fluids[fluidName] = node
    node.nodeType = GraphNode.Types.FLUID
    node.nodeName = fluidName
    node.dependencies = DependencyGraph._getItemFluidDependencies(fluidName, true)
end

-- gets graph dependencies of the given item/fluid
function DependencyGraph._getItemFluidDependencies(itemName, isFluid)
    local dependencies = GraphNodeGroup:new()

    -- item depends on only 1 of possibly many ways to obtain the item
    dependencies.groupingType = GraphNodeGroup.Types.OR

    -- check if a base resource
    local mineable = DependencyGraph._getMineableProperties(itemName)

    if (mineable ~= nil or itemName == "water") then
        local mineableDependency = GraphNodeGroup:new()
        table.insert(dependencies.groupDependencies, mineableDependency)
        mineableDependency.groupingType = GraphNodeGroup.Types.LEAF
        mineableDependency.leafNodeType = GraphNode.Types.RESOURCE
        mineableDependency.leafNodeName = itemName
    end

    -- check recipes
    -- https://lua-api.factorio.com/latest/classes/LuaRecipePrototype.html
    local filter = "has-product-item"
    if isFluid then
        filter = "has-product-fluid"
    end
    local recipes = prototypes.get_recipe_filtered{{filter = filter, elem_filters = {{filter = "name", name = itemName}}}}
    for _, recipe in pairs(recipes) do
        local recipeDependency = GraphNodeGroup:new()
        table.insert(dependencies.groupDependencies, recipeDependency)
        recipeDependency.groupingType = GraphNodeGroup.Types.LEAF
        recipeDependency.leafNodeType = GraphNode.Types.RECIPE
        recipeDependency.leafNodeName = recipe.name
    end

    return dependencies;
end

-- adds the given recipe by name to the dependency graph
function DependencyGraph:_addRecipeNode(recipeName)
    local node = GraphNode:new()
    self.recipes[recipeName] = node
    node.nodeType = GraphNode.Types.RECIPE
    node.nodeName = recipeName

    -- TODO WESD make dependent on a recipe crafter being available. ex. player? or a more advanced machine high up on tech tree?
    local dependencies = GraphNodeGroup:new()
    node.dependencies = dependencies
    -- https://lua-api.factorio.com/latest/classes/LuaRecipePrototype.html
    local recipe = prototypes.recipe[recipeName]
    if (recipe == nil) then
        error("MarketScience - unable to find recipe to add to dependency graph name=" .. recipeName)
    end
    local ingredients = recipe.ingredients
    if (ingredients == nil or #ingredients == 0) then
        dependencies.groupingType = GraphNodeGroup.Types.NONE
    else
        -- AND each item ingredient
        dependencies.groupingType = GraphNodeGroup.Types.AND
        for _, ingredient in ipairs(ingredients) do
            local dependency = GraphNodeGroup:new()
            table.insert(dependencies.groupDependencies, dependency)
            dependency.groupingType = GraphNodeGroup.Types.LEAF
            dependency.leafNodeType = GraphNode.Types.ITEM
            dependency.leafNodeName = ingredient.name
        end
    end
end

-- adds the given technology by name to the dependency graph
function DependencyGraph:_addTechnologyNode(technologyName)
    local node = GraphNode:new()
    self.technologies[technologyName] = node
    node.nodeType = GraphNode.Types.TECHNOLOGY
    node.nodeName = technologyName

    local dependencies = GraphNodeGroup:new()
    node.GraphNodeGroup = dependencies

    -- this mod doesn't care about the tree part of the tech tree, we just need to check if some enabling techs are unlocked or not
    -- (ex. ability to add liquid into mining drills)
    -- as such, we don't bother with adding any dependencies to the techs themselves
    dependencies.groupingType = GraphNodeGroup.Type.NONE
end

return DependencyGraph