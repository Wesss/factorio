
local inspect = require("src.util.inspect")

local marketValue = {}

function marketValue.GetValue(itemName)
    return 10
    -- TODO WESD v1 implement actual calculation, data storage, etc
    -- https://lua-api.factorio.com/latest/classes/LuaRecipePrototype.html
    -- for name, recipe in pairs(data.raw.recipe) do
        
    -- end
end

function marketValue.GetTechnologyValue(technologyName)
    -- TODO WESD v1 implement actual calculation, data storage, etc
    return 10000;
end

return marketValue
