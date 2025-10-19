
local inspect = require("src.util.inspect")
local MarketValue = require("src.control.market-value")

local Markets = {}

-- iterate all markets and fulfil orders
function Markets.checkMarkets(currentOrder, dependencyGraph)    
    -- check for active research
    -- TODO WESD if more than default forces exist, print an error message to players
    local force = game.forces["player"]
    local technology = force.current_research
    if technology == nil then
        return
    end
    
    -- find maximum remaining research
    local researchValue = MarketValue.GetTechnologyValue(technology.name, dependencyGraph)
    local researchValueRemaining = math.ceil((1.0 - force.research_progress) * researchValue)

    local fulfilledValue = 0
    for _, surface in pairs(game.surfaces) do
        local markets = surface.find_entities_filtered({name = "science-market"})
        for _, market in pairs(markets) do
            local inventory = market.get_inventory(defines.inventory.chest)
            local valueFulfilled = currentOrder:fulfill(inventory, researchValueRemaining, dependencyGraph)
            researchValueRemaining = researchValueRemaining - valueFulfilled

            fulfilledValue = fulfilledValue + valueFulfilled
            
            -- print value floating text over the market
            local roundedValue = math.floor(fulfilledValue + 0.5);
            if roundedValue > 0 then
                for _, player in pairs(force.players) do
                    player.create_local_flying_text({
                        text = "+" .. math.floor(fulfilledValue + 0.5),
                        position = market.position,
                        surface = market.surface,
                        color = {
                            g = 1
                        }
                    })
                end
            end
        end
    end

    -- advance research based on order fulfilment
    local progress = fulfilledValue / researchValue
    force.research_progress = math.min(1, force.research_progress + progress)
end

-- updates the signals produced by each market
function Markets.updateSignals(linkedCombinators, curOrder)
    for _, surface in pairs(game.surfaces) do
        local markets = surface.find_entities_filtered({name = "science-market"})
        for _, market in pairs(markets) do
            -- TODO WESD can this crash? probably add more checks here
            local combinator = game.get_entity_by_unit_number(linkedCombinators[market.unit_number])

            -- TODO WESD v1 LAST update symbols based on order
            local custom_signals = {
                {signal = {type="item", name="iron-plate"}, count = 999}
            }
            combinator.control_behavior.parameters = custom_signals
        end
    end
end

-- when market is built, hook up combinator to emit custom signals
function Markets.onBuild(linkedCombinators, market)
    local surface = market.surface
    local pos = market.position
    local force = market.force

    -- Create a combinator for custom signals
    local custom_combinator = surface.create_entity({
        name = "constant-combinator",
        position = {pos.x + 1, pos.y + 1},
        force = force,
        -- don't play built sound? haven't tested this
        raise_built = false
    })

    -- link to market
    linkedCombinators[market.unit_number] = custom_combinator.unit_number
end

-- cleanup
function Markets.onRemove(linkedCombinators, market)
    local marketUnitNum = market.unit_number
    if linkedCombinators[marketUnitNum] then
        local combinator = game.get_entity_by_unit_number(linkedCombinators[marketUnitNum])

        -- destroy combinator
        if combinator then
            combinator.destroy()
        end

        -- unlink
        linkedCombinators[entity_id] = nil
    end
end

return Markets