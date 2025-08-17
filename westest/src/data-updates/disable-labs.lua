-- disable research
for key, lab in pairs(data.raw["lab"]) do
    lab.researching_speed = 0
    -- this causes error "there is no lab that will accept all of the science packs this technology requires"
    -- lab.inputs = {}
end