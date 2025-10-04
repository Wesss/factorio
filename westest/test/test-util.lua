
local Inspect = require("src.util.inspect")

local TestUtil = {}

-- given two GraphNodes (or GraphNode-like tables), assert they match
-- returns {success=bool, message=string}
function TestUtil.GraphNodeMatches(expected, actual)
    local errorMsgPrefix = "GraphNodes do not match: "
    --[[
    {
        nodeName = "coal",
        nodeType = GraphNode.Types.RESOURCE,
        dependencies = {
            groupingType = "NONE",
            groupDependencies = {}
        }
    }
    ]]
    -- nil checks
    if expected == nil and actual == nil then
        return {success = true}
    end
    if expected == nil and actual ~= nil then
        return {success = false, message = errorMsgPrefix .. "expected is nil, actual is not nil"}
    end
    if expected ~= nil and actual == nil then
        return {success = false, message = errorMsgPrefix .. "expected is not nil, actual is nil"}
    end

    -- node checks
    if expected.nodeType ~= actual.nodeType then
        return {success = false, message = errorMsgPrefix .. "expected.nodeType=" .. (expected.nodeType or "") .. " actual.nodeType=" .. (actual.nodeType or "")}
    end
    if expected.nodeName ~= actual.nodeName then
        return {success = false, message = errorMsgPrefix .. "expected.nodeName=" .. (expected.nodeName or "") .. " actual.nodeName=" .. (actual.nodeName or "")}
    end
    local depRes = TestUtil.GraphNodeGroupMatches(expected.dependencies, actual.dependencies)
    if not depRes.success then
        depRes.message = errorMsgPrefix .. " dependencies do not match.\n" .. (depRes.message or "")
        return depRes
    end
    
    return {success = true}
end

-- given two GraphNodeGroups (or GraphNodeGroups-like tables), assert they match
-- returns {success=bool, message=string}
function TestUtil.GraphNodeGroupMatches(expected, actual)
    local errorMsgPrefix = "GraphNodeGroups do not match: "
    --[[
    {
        groupingType = "NONE",
        groupDependencies = {}
    }
    ]]
    -- nil checks
    if expected == nil and actual == nil then
        return {success = true}
    end
    if expected == nil and actual ~= nil then
        return {success = false, message = errorMsgPrefix .. "expected is nil, actual is not nil"}
    end
    if expected ~= nil and actual == nil then
        return {success = false, message = errorMsgPrefix .. "expected is not nil, actual is nil"}
    end

    -- node group checks
    if expected.groupingType ~= actual.groupingType then
        return {success = false, message = errorMsgPrefix .. "expected.groupingType=" .. (expected.groupingType or "") .. " actual.groupingType=" .. (actual.groupingType or "")}
    end
    if expected.leafNodeType ~= actual.leafNodeType then
        return {success = false, message = errorMsgPrefix .. "expected.leafNodeType=" .. (expected.leafNodeType or "") .. " actual.leafNodeType=" .. (actual.leafNodeType or "")}
    end
    if expected.leafNodeName ~= actual.leafNodeName then
        return {success = false, message = errorMsgPrefix .. "expected.leafNodeName=" .. (expected.leafNodeName or "") .. " actual.leafNodeName=" .. (actual.leafNodeName or "")}
    end
    local groupRes = TestUtil.ArrayMatches(expected.groupDependencies, actual.groupDependencies, TestUtil.GraphNodeGroupMatches)
    if not groupRes.success then
        groupRes.message = errorMsgPrefix .. " groupDependencies do not match.\n" .. (groupRes.message or "")
        return groupRes;
    end

    return {success = true}
end

-- Compares two arrays of elements.
-- @param comparator function (Optional) A function that takes two array elements and returns a test result obj.
function TestUtil.ArrayMatches(expected, actual, comparator)
    local errorMsgPrefix = "Arrays do not match: "
    -- array checks
    if type(expected) ~= "table" then
        return {success = false, message = errorMsgPrefix .. " expected is not a table"}
    end
    if type(actual) ~= "table" then
        return {success = false, message = errorMsgPrefix .. " actual is not a table"}
    end
    if #expected ~= #actual then
        return {success = false, message = errorMsgPrefix .. " #expected= " .. #expected .. " #actual=" .. #actual}
    end
    

    for i = 1, #actual do
        local elemRes
        if comparator then
            elemRes = comparator(expected[i], actual[i])
        else
            if expected[i] == actual[i] then
                elemRes = {success = true, message = ""}
            else
                elemRes = {success = false, message = "Array element does not match. expected["..i.."]=" .. tostring(expected[i]) .. " actual["..i.."]=" .. tostring(actual[i])}
            end
        end
        
        if not elemRes.success then
            elemRes.message = errorMsgPrefix .. " elements at "..i.." do not match.\n" .. (elemRes.message or "")
            return elemRes
        end
    end

    return {success = true}
end

return TestUtil