
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
function Markets.updateSignals(curOrder)
    for _, surface in pairs(game.surfaces) do
        local constcombs = surface.find_entities_filtered({name = "market-constant-combinator"})
        for _, constcomb in pairs(constcombs) do
            if constcomb.valid then
                -- TODO WESD v1 set signals to be equal to current order. don't forget to clear slots before re-adding
                local behavior = constcomb.get_or_create_control_behavior()
                if (behavior.sections_count == 0) then behavior.add_section() end
                local section = behavior.get_section(1)

                -- looks like a low pri bug from factorio. need to set quality to normal.
                local count = 1
                local name = "coal"
                local signalfilter = {}
                signalfilter.type = "item"
                signalfilter.name = name
                signalfilter.quality = "normal" 
                signalfilter.comparator = nil
                local logisticfilter = {}
                logisticfilter.value = signalfilter
                logisticfilter.min = count
                logisticfilter.max = count
                section.set_slot(1, logisticfilter)
            end
        end
    end
end

return Markets