
local inspect = require("src.util.inspect")

local DependencyGraph = require("src.control.graph.dependency-graph")
local graphModule = require("src.control.graph.graph-node")
local GraphNode = graphModule.GraphNode
local GraphNodeGroup = graphModule.GraphNodeGroup

local Tests = {}

function Tests.runTests(dependencyGraph)
    -- TODO WESD make this more dynamic? can probably have an array of methods, iterate each and print what we run as we go
    Tests.addCoalResource(dependencyGraph)
end

function Tests.addCoalResource(dependencyGraph)
    log("Running Tests.addCoalResource")
    dependencyGraph:AddNode(GraphNode.Types.RESOURCE, "coal")
    -- TODO WESD LAST print state, assert state, etc
end