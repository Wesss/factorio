
local markets = {}

-- iterate markets and fulfil orders
function markets.checkMarkets()
    game.print("checkMarkets!")
    for _, surface in pairs(game.surfaces) do
        local markets = surface.find_entities_filtered({name = "science-market"})
        for _, market in pairs(markets) do

            -- TODO WESD implement order fulfilment
            local inventory = market.get_inventory(defines.inventory.chest)
            local amount = inventory.get_item_count("iron-plate")
            game.print("iron-plate amount:" .. amount);
        end
    end
end

function markets.progressResearch(amount)
    -- TODO WESD implement this
    -- asdf
end

return markets