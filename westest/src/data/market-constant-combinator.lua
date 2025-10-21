
local combEntity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
combEntity.name = "market-constant-combinator"
combEntity.icons = {
    -- TODO WESD can we just edit tint in place?
    -- TODO WESD v1 finess icon tint
    {
        icon = combEntity.icon,
        icon_size = combEntity.icon_size,
        tint = {r=0,g=1,b=0,a=0.3}
    },
    -- TODO WESD v1 add localization text for player display
    -- TODO WESD make un-editable by player?
}

local combItem = table.deepcopy(data.raw["item"]["constant-combinator"])
combItem.name = "market-constant-combinator"
combItem.icons = combEntity.icons
combItem.place_result = "market-constant-combinator"

local combRecipe = {
    type = "recipe",
    name = "market-constant-combinator",
    enabled = true,
    -- seconds to craft at default crafting speed
    energy_required = 1,
    ingredients = {
        -- TODO WESD v1 properly balance
        {type = "item", name = "coal", amount = 1}
    },
    results = {
        {type = "item", name = "market-constant-combinator", amount = 1}
    }
}

data:extend{combEntity, combItem, combRecipe}
