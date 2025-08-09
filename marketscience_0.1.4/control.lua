-- Remove items from certain mods (like textplates) from the pool
-- Can get stuck on barrels if you reverse the research to generate the fluid
DEFAULT_ORDER_SIZE = 300

local item_scores = require("production-score")

local function getRandomInt(lower, upper)
    if lower > upper then
        return 1
    else
        return math.floor(math.random(lower, upper) + 0.5)
    end
end

local function generate_excluded_ingredients()
    -- TODO WESD feature - hard coded exclusion of wood from considered items for orders
    local woodrecipes = game.get_filtered_recipe_prototypes({{
        filter = "has-product-item",
        elem_filters = {{
            filter = "name",
            name = "wood"
        }}
    }})
    if #woodrecipes < 1 then
        local include = true
        for index, value in ipairs(global.excluded_ingredients) do
            if value == "wood" then
                include = false
                break
            end
        end
        if include then
            table.insert(global.excluded_ingredients, "wood")
        end
    end
end

local function unlock_item(force_index, name)
    local include = true
    for index, value in ipairs(global.market_data[force_index].unlocked_items) do
        if name == value then
            include = false
            break
        end
    end
    if include then
        table.insert(global.market_data[force_index].unlocked_items, name)
    end
end

-- If there are multiple recipe it is counted multiple times
local function calculate_order_size(force_index)
    order_size = DEFAULT_ORDER_SIZE
    for name, prototype in pairs(game.get_filtered_recipe_prototypes({{
        filter = "has-product-item",
        mode = "and",
        elem_filters = {{
            filter = "type",
            type = "tool"
        }}
    }})) do
        if game.forces[force_index].recipes[name].enabled then
            order_size = order_size + global.item_values[prototype.main_product.name] * 10
        end
    end
    global.market_data[force_index].order_size = order_size
end

local function validate_recipe(force_index, proto_recipe)
    recipe = game.forces[force_index].recipes[proto_recipe.name]
    if recipe.enabled and not recipe.hidden then
        if proto_recipe.main_product ~= nil then
            if proto_recipe.main_product.type ~= "fluid" then
                if game.item_prototypes[proto_recipe.main_product.name].type == "tool" then
                    calculate_order_size(force_index)
                end
                if recipe.name:sub(-#"-barrel") ~= "-barrel" then
                    unlock_item(force_index, proto_recipe.main_product.name)
                end
            elseif game.item_prototypes[proto_recipe.main_product.name .. "-barrel"] ~= nil then
                for barrel_recipe_name, barrel_recipe in pairs(
                    game.get_filtered_recipe_prototypes({{
                        filter = "has-product-item",
                        elem_filters = {{
                            filter = "name",
                            name = proto_recipe.main_product.name .. "-barrel"
                        }}
                    }})) do
                    if game.forces[force_index].recipes[barrel_recipe_name].enabled then
                        unlock_item(force_index, proto_recipe.main_product.name .. "-barrel")
                        break
                    end
                end
            end
        end
    end
end

local function newOrders(force_index)
    -- TODO WESD feature - generate new orders
    local total = 0
    local orders = {}
    while total < global.market_data[force_index].order_size do
        local index = getRandomInt(1, #global.market_data[force_index].unlocked_items)
        local item_name = global.market_data[force_index].unlocked_items[index]
        local amount = math.floor(0.5 + getRandomInt(1, (global.market_data[force_index].order_size - total) /
            global.item_values[global.market_data[force_index].unlocked_items[index]]))
        if orders[item_name] ~= nil then
            orders[item_name] = orders[item_name] + amount
        else
            orders[item_name] = amount
        end
        total = total + global.item_values[global.market_data[force_index].unlocked_items[index]] * amount
    end
    global.market_data[force_index].orders = {}
    for name, value in pairs(orders) do
        table.insert(global.market_data[force_index].orders, {
            name = name,
            count = value
        })
    end
end

local function regenerate_unlocked_items(force_index)
    global.market_data[force_index].unlocked_items = {}
    for name, proto_recipe in pairs(game.get_filtered_recipe_prototypes({{
        filter = "has-ingredient-item",
        mode = "and",
        invert = true,
        elem_filters = {{
            filter = "name",
            name = global.excluded_ingredients
        }}
    }})) do
        validate_recipe(force_index, proto_recipe)
    end
end

local function UpdateSignals(force_index)
    for _, sender in pairs(global.market_data[force_index].markets) do
        if sender.signal.valid then
            for i = 1, game.entity_prototypes["market-signals"].item_slot_count, 1 do
                local order = global.market_data[force_index].orders[i]
                if order ~= nil then
                    sender.signal.get_or_create_control_behavior().set_signal(i, {
                        signal = {
                            type = "item",
                            name = order.name
                        },
                        count = order.count * -1
                    })
                else
                    sender.signal.get_or_create_control_behavior().set_signal(i, nil)
                end
            end
        end
    end
end

local function UpdateOrdersGUI()
    for i, player in pairs(game.players) do
        local main_frame = player.gui.left.orders_main_frame
        if main_frame ~= nil then
            main_frame.clear()
            local content_frame = main_frame.add {
                type = "frame",
                name = "content_frame",
                direction = "vertical"
            }
            for j, order in ipairs(global.market_data[player.force.index].orders) do
                local line = content_frame.add {
                    type = "flow"
                }
                line.style.vertical_align = "center"
                local sprite = line.add {
                    type = "sprite",
                    sprite = "item/" .. order.name,
                    tooltip = {"?", {"", {"item-name." .. order.name}}, {"entity-name." .. order.name}}
                } -- {"?", {{"item-name." .. order.name}, {"entity-name." .. order.name}}}}
                sprite.style.right_margin = 5
                line.add {
                    type = "label",
                    caption = order.count
                }
            end
        end
    end
end

local function clean_orders()
    for force_index, data in pairs(global.market_data) do
        for i, order in ipairs(data.orders) do
            local included = false
            for j, item in ipairs(global.market_data[force_index].unlocked_items) do
                if order.name == item then
                    included = true
                    break
                end
            end
            if not included then
                newOrders(force_index)
                UpdateOrdersGUI()
                break
            end
        end
    end
end

local function create_market_data(force_index)
    global.market_data[force_index] = {}
    global.market_data[force_index].order_size = DEFAULT_ORDER_SIZE
    global.market_data[force_index].markets = {}
    global.market_data[force_index].orders = {}
    global.market_data[force_index].market_limit = 1
    regenerate_unlocked_items(force_index)
    if #game.get_filtered_recipe_prototypes({{
        filter = "enabled"
    }, {
        filter = "has-product-item",
        mode = "and",
        elem_filters = {{
            filter = "name",
            name = "lab"
        }}
    }}) > 0 then
        table.insert(global.market_data[force_index].orders, {
            name = "lab",
            count = 1
        })
    end
end

local function market_build(event)
    local force = event.created_entity.force
    -- TODO WESD feature - prevent building of markets over the limit
    if #global.market_data[force.index].markets < global.market_data[force.index].market_limit then
        local market_signal = event.created_entity.surface.create_entity {
            name = "market-signals",
            position = event.created_entity.position,
            force = force
        }
        market_signal.connect_neighbour {
            target_entity = event.created_entity,
            wire = defines.wire_type.red,
            source_circuit_id = 1
        }
        market_signal.connect_neighbour {
            target_entity = event.created_entity,
            wire = defines.wire_type.green,
            source_circuit_id = 1
        }
        market_signal.destructible = false
        table.insert(global.market_data[force.index].markets, {
            market = event.created_entity,
            signal = market_signal
        })

        local main_frame = game.get_player(event.player_index).gui.left.orders_main_frame
        if main_frame == nil then
            main_frame = game.get_player(event.player_index).gui.left.add {
                type = "frame",
                name = "orders_main_frame",
                caption = "Orders"
            }
            UpdateOrdersGUI()
        end
        UpdateSignals(force.index)
    else
        game.get_player(event.player_index).print({"lab-restriction", global.market_data[force.index].market_limit}, {
            r = 1
        })
        event.created_entity.surface.create_entity {
            name = "item-on-ground",
            stack = {
                name = "science-market"
            },
            position = event.created_entity.position
        }
        event.created_entity.destroy()
    end
end

local function market_removed(event)
    for i, market in ipairs(global.market_data[event.entity.force.index].markets) do
        if event.entity.unit_number == market.market.unit_number then -- Do I just remove unit_number?
            market.signal.destroy()
            table.remove(global.market_data[event.entity.force.index].markets, i)
        end
    end
end

script.on_init(function()
    global.item_values = item_scores.generate_price_list()
    global.excluded_ingredients = {}
    generate_excluded_ingredients()
    global.market_data = {}
    create_market_data(game.forces.player.index)
end)

script.on_configuration_changed(function()
    generate_excluded_ingredients()
    global.item_values = item_scores.generate_price_list()
    for force_index, data in pairs(global.market_data) do
        regenerate_unlocked_items(force_index)
    end
    clean_orders()
end)

script.on_event(defines.events.on_robot_built_entity, market_build, {{
    filter = "name",
    name = "science-market"
}})
script.on_event(defines.events.on_built_entity, market_build, {{
    filter = "name",
    name = "science-market"
}})

script.on_event(defines.events.on_entity_died, market_removed, {{
    filter = "name",
    name = "science-market"
}})
script.on_event(defines.events.on_robot_mined_entity, market_removed, {{
    filter = "name",
    name = "science-market"
}})
script.on_event(defines.events.on_player_mined_entity, market_removed, {{
    filter = "name",
    name = "science-market"
}})

script.on_nth_tick(60, function(event)
    -- TODO WESD feature - fulfil orders 1x a second
    for force_index, data in pairs(global.market_data) do
        if #data.orders == 0 then
            newOrders(force_index)
        end
        for i, market in ipairs(data.markets) do
            local technology = game.forces[force_index].current_research -- market.market.force.current_research
            if technology ~= nil then
                local inventory = market.market.get_inventory(defines.inventory.chest)
                local score = 0
                for j = #data.orders, 1, -1 do
                    local order = data.orders[j]
                    local amount = inventory.get_item_count(order.name)
                    if amount > 0 then
                        inventory.remove({
                            name = order.name,
                            count = order.count
                        })
                        score = score + math.min(amount, order.count) * global.item_values[order.name]
                        order.count = order.count - math.min(amount, order.count)
                        if order.count < 1 then
                            table.remove(data.orders, j)
                            if #data.orders == 0 then
                                newOrders(force_index)
                            end
                        end
                    end
                end
                if score > 0 then
                    market.market.surface.create_entity {
                        name = "flying-text",
                        position = market.market.position,
                        text = "+" .. math.floor(score + 0.5),
                        color = {
                            g = 1
                        }
                    }
                    local multiplier = 0
                    for j, science in ipairs(technology.research_unit_ingredients) do
                        multiplier = multiplier + global.item_values[science.name]
                    end
                    game.forces[force_index].research_progress =
                        math.min(1, market.market.force.research_progress + score / technology.research_unit_count /
                            multiplier)
                    UpdateSignals(force_index)
                end
            end
        end
    end
    UpdateOrdersGUI()
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    -- TODO WESD feature - show/hide orders UI
    if event.prototype_name == "toggle-orders" then
        local player = game.get_player(event.player_index)
        if player ~= nil then
            local main_frame = player.gui.left.orders_main_frame
            if main_frame == nil then
                main_frame = player.gui.left.add {
                    type = "frame",
                    name = "orders_main_frame",
                    caption = "Orders"
                }
                UpdateOrdersGUI()
            else
                main_frame.destroy()
            end
        end
    end
end)

-- Remove items if no other recipes are enabled
script.on_event(defines.events.on_research_reversed, function(event)
    local force_index = event.research.force.index
    if string.match(event.research.name, "market%-limit") ~= nil then
        global.market_data[event.research.force.index].market_limit = global.market_data[force_index].market_limit - 1
    end
    for i, effect in ipairs(event.research.effects) do
        if effect.type == "unlock-recipe" then
            local recipe = game.recipe_prototypes[effect.recipe]
            if recipe.main_product ~= nil then
                if recipe.main_product.type == "item" then
                    local all_recipes = game.get_filtered_recipe_prototypes({{
                        filter = "has-product-item",
                        elem_filters = {{
                            filter = "name",
                            name = recipe.main_product.name
                        }}
                    }})
                    local enabled = false
                    for recipe_name, _ in pairs(all_recipes) do
                        if game.forces[force_index].recipes[recipe_name].enabled then
                            enabled = true
                            break
                        end
                    end
                    if not enabled then
                        if game.item_prototypes[recipe.main_product.name].type == "tool" then
                            calculate_order_size(force_index)
                        end
                        for j, item in ipairs(global.market_data[force_index].unlocked_items) do
                            if item == recipe.main_product.name then
                                table.remove(global.market_data[force_index].unlocked_items, j)
                                clean_orders()
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    local force_index = event.research.force.index
    -- TODO WESD feature - market limit research
    if string.match(event.research.name, "market%-limit") ~= nil then
        global.market_data[force_index].market_limit = global.market_data[force_index].market_limit + 1
    end
    for i, effect in ipairs(event.research.effects) do
        if effect.type == "unlock-recipe" then
            local recipe = game.recipe_prototypes[effect.recipe]
            validate_recipe(force_index, recipe)
        end
    end
    UpdateOrdersGUI()
end)

script.on_event(defines.events.on_force_created, function(event)
    create_market_data(event.force.index)
end)

script.on_event(defines.events.on_research_started, function(event)
    UpdateOrdersGUI()
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.gui_type == defines.gui_type.entity then
        if event.entity.type == "lab" then
            game.get_player(event.player_index).print({"science-restriction"}, {
                r = 1
            })
        end
    end
end)

commands.add_command("market", nil, function(command)
    if command.player_index ~= nil then
        if command.parameter == "clean" then
            game.get_player(command.player_index).print("Cleaned if neccesary!")
            clean_orders()
        end
    end
end)
