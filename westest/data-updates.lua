-- disable research by making them unable to progress or have any inputs
for key, lab in pairs(data.raw["lab"]) do
    lab.researching_speed = 0
    lab.inputs = {}
end
