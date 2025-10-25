
local combEntity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
combEntity.name = "market-combinator"
combEntity.icons = {
    {
        icon = combEntity.icon,
        icon_size = combEntity.icon_size,
        tint = {r=0.5, g=1, b=0.2, a=1}
    },
    -- TODO WESD make un-editable by player?
}

local combItem = table.deepcopy(data.raw["item"]["constant-combinator"])
combItem.name = "market-combinator"
combItem.icons = combEntity.icons
combItem.place_result = "market-combinator"

local combRecipe = {
    type = "recipe",
    name = "market-combinator",
    enabled = false,
    energy_required = 0.5,
    ingredients = {
        {type = "item", name = "constant-combinator", amount = 1},
        {type = "item", name = "electronic-circuit", amount = 2},
    },
    results = {
        {type = "item", name = "market-combinator", amount = 1}
    }
}

local combTech = {
    type = "technology",
    name = "market-combinator-research",
    -- Use the vanilla constant combinator icon
    icon = "__base__/graphics/icons/constant-combinator.png",
    icon_size = 64,
    icon_mipmaps = 4,
    tint = combEntity.icons.tint,
    prerequisites = {"circuit-network"}, 
    
    -- This is the research cost
    unit = {
        count = 50,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 30
    },
    order = "c-a-c",
    effects = {{ type = "unlock-recipe", recipe = combRecipe.name }}
}

data:extend{combEntity, combItem, combRecipe, combTech}
