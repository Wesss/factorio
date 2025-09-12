
local inspect = require("src.util.inspect")
local marketValue = require("src.control.market-value")

local markets = {}

-- iterate all markets and fulfil orders
function markets.checkMarkets(currentOrder)
    game.print("wesd flag1 checkMarkets!")
    
    -- check for active research
    -- TODO WESD if more than default forces exist, print an error message to players
    local force = game.forces["player"]
    local technology = force.current_research
    if technology == nil then
        return
    end
    
    -- find maximum remaining research
    local researchValue = marketValue.GetTechnologyValue(technology.name)
    local researchValueRemaining = math.ceil((1.0 - force.research_progress) * researchValue)

    local fulfilledValue = 0
    for _, surface in pairs(game.surfaces) do
        local markets = surface.find_entities_filtered({name = "science-market"})
        for _, market in pairs(markets) do
            local inventory = market.get_inventory(defines.inventory.chest)
            local valueFulfilled = currentOrder:fulfill(inventory, researchValueRemaining)
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
    game.print("wesd flag3 checkMarketEnd fulfilledValue=" .. fulfilledValue .. " progress=" .. progress)
    force.research_progress = math.min(1, force.research_progress + progress)
end

return markets