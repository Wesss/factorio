-- create the recipe prototype from scratch
local recipe = {
  type = "recipe",
  name = "wes-test-recipe",
  enabled = true,
  energy_required = 8, -- time to craft in seconds (at crafting speed 1)
  ingredients = {
    {type = "item", name = "copper-plate", amount = 2}
  },
  results = {{type = "item", name = "steel-plate", amount = 1}}
}

data:extend{recipe}