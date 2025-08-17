
local ticksPerCheck = 60

require("src.control.disable-labs-message")
local ordersGUI = require("src.control.orders-gui")
local markets = require("src.control.markets")

-- main loop
script.on_nth_tick(60, function(event)
    markets.checkMarkets()
    ordersGUI.updateOrdersGUI()
    for _, force in game.forces do
        -- TODO WESD resume here, get each force's technology? only look through player's force
        -- and say not supporting multiplayer?
        -- https://lua-api.factorio.com/latest/classes/LuaGameScript.html
    end
end)
