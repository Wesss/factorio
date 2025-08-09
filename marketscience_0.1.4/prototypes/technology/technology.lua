data:extend({{
    type = "technology",
    name = "market-limit-1",
    icon_size = 256,
    icon_mipmaps = 4,
    icon = "__base__/graphics/technology/radar.png",
    effects = {{
        type = "nothing",
        effect_description = {"market-limit"}
    }},
    unit = {
        count = 200,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1}},
        time = 10
    },
    upgrade = true,
    order = "d-d",
    prerequisites = {"chemical-science-pack"}
}, {
    type = "technology",
    name = "market-limit-2",
    icon_size = 256,
    icon_mipmaps = 4,
    icon = "__base__/graphics/technology/radar.png",
    effects = {{
        type = "nothing",
        effect_description = {"market-limit"}
    }},
    unit = {
        count = 500,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
                       {"production-science-pack", 1}, {"utility-science-pack", 1}},
        time = 30
    },
    upgrade = true,
    order = "d-d",
    prerequisites = {"market-limit-1", "production-science-pack", "utility-science-pack"}
}, {
    type = "technology",
    name = "market-limit-3",
    icon_size = 256,
    icon_mipmaps = 4,
    icon = "__base__/graphics/technology/radar.png",
    effects = {{
        type = "nothing",
        effect_description = {"effect.market-limit"}
    }},
    unit = {
        count = 1000,
        ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
                       {"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1}},
        time = 60
    },
    upgrade = true,
    order = "d-d",
    prerequisites = {"market-limit-2", "space-science-pack"}
}})
