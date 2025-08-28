
local marketValue = require("src.control.market-value")

local markets = {}

-- iterate all markets and fulfil orders
function markets.checkMarkets(currentOrder)
    -- TODO WESD actual check and fulfil currentOrder
    game.print("checkMarkets!")
    
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
    game.print("researchValue=" .. researchValue .. " researchValueRemaining=" .. researchValueRemaining)

    local fulfilledValue = 0
    for _, surface in pairs(game.surfaces) do
        local markets = surface.find_entities_filtered({name = "science-market"})
        for _, market in pairs(markets) do
            local inventory = market.get_inventory(defines.inventory.chest)
            local valueFulfilled = currentOrder:fulfill(inventory, researchValueRemaining)
            researchValueRemaining = researchValueRemaining - valueFulfilled
            game.print("valueFulfilled=" .. valueFulfilled)

            fulfilledValue = fulfilledValue + valueFulfilled
        end
    end

    -- advance research based on order fulfilment
    local progress = fulfilledValue / researchValue
    game.print("fulfilledValue=" .. fulfilledValue .. " progress=" .. progress)
    force.research_progress = math.min(1, force.research_progress + progress)
end

-- function markets.progressResearch(amount)
-- end

return markets