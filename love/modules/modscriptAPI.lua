local msa = {}
-- Modscript API

msa.graphics = {}
msa.drawLayers = {}
msa.file = false

function msa.loadScript(path)
    msa.file = file
    success = pcall(function() love.filesystem.load(path .. "/mod.lua")() end)
    if not success then
        debug.print("No modscript found at " .. path)
        -- stop loading the modscript
        return
    end
    debug.print("Loaded modscript at " .. path)

    -- actually load the script
    love.filesystem.load(path .. "/mod.lua")()

    msa.file = true
end

return msa