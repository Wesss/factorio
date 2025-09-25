-- local noise = require("noise")

-- local signals = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
-- signals.name = "market-signals"
-- signals.energy_source = {
--     type = "void"
-- }
-- signals.order = "zzz"
-- -- signals.draw_circuit_wires=false
-- signals.circuit_wire_max_distance = 1
-- signals.item_slot_count = 100
-- signals.flags = {
--     "not-repairable",
--     "not-on-map",
--     "not-blueprintable",
--     "not-deconstructable",
--     "no-copy-paste",
--     "not-selectable-in-game",
--     "hide-alt-info"
-- }
-- signals.alert_when_damaged = false
-- signals.selectable_in_game = false
-- signals.allow_copy_paste = false
-- signals.collision_mask = {}

local market = {
    -- TODO WESD v1 add signals showing market demand
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
    circuit_wire_connection_point = circuit_connector_definitions["roboport"].points,
    circuit_connector_sprites = circuit_connector_definitions["roboport"].sprites,
    circuit_wire_max_distance = default_circuit_wire_max_distance,
}

data:extend({market})
