
local market = {
    -- TODO WESD move wire attachment point to top right of market (currently just center, looks weird)
    type = "container",
    name = "science-market",
    destructible = false,
    minable_flag = false,
    max_health = 800,
    inventory_size = 48,
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    -- make completely invulnerable to damage
    resistances = {
        {
            type = "physical",
            percent = 100
        },
        {
            type = "impact",
            percent = 100
        },
        {
            type = "fire",
            percent = 100
        },
        {
            type = "acid",
            percent = 100
        },
        {
            type = "poison",
            percent = 100
        },
        {
            type = "explosion",
            percent = 100
        },
        {
            type = "laser",
            percent = 100
        },
        {
            type = "electric",
            percent = 100
        }
    },
    flags = {"placeable-neutral", "player-creation"},
    icon = "__base__/graphics/icons/market.png",
    icon_mipmaps = 4,
    icon_size = 64,
    order = "d-a-a",
    picture = {
        filename = "__base__/graphics/entity/market/market.png",
        height = 127,
        shift = {0.95, 0.2},
        width = 156
    },
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    subgroup = "other",
    -- circuit_wire_connection_point = circuit_connector_definitions["roboport"].points,
    -- circuit_connector_sprites = circuit_connector_definitions["roboport"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
    circuit_connector_definitions =
    {
      {
        connector_id = 1,
        -- Style the connector, for example, to look like a red wire attachment.
        back_patch = {
          picture = "__core__/graphics/circuit-connector-back-patch.png",
          tint = { r = 0.5, g = 0, b = 0, a = 0.5 }
        },
        point = {0.2, 0.2},
      },
      {
        connector_id = 2,
        -- Style the connector, for example, to look like a green wire attachment.
        back_patch = {
          picture = "__core__/graphics/circuit-connector-back-patch.png",
          tint = { r = 0, g = 0.5, b = 0, a = 0.5 }
        },
        point = {0.2, -0.2},
      },
    },
}

data:extend({market})
