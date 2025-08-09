for key, lab in pairs(data.raw["lab"]) do
    lab.researching_speed = 0
    lab.inputs = {}
end
data.raw["technology"]["circuit-network"].prerequisites = {"electronics"}
data.raw["technology"]["circuit-network"].unit = {
    count = 30,
    ingredients = {{"automation-science-pack", 1}},
    time = 15
}
