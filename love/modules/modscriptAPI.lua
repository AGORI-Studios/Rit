local msa = {}
-- Modscript API

msa.graphics = {}
msa.drawLayers = {}
msa.file = false

function msa.loadScript(path)
    msa.file = file
    tryExcept(
        function()
            love.filesystem.load(path .. "/mod.lua")()

            debug.print("Loaded modscript at " .. path)

            msa.file = true
        end,
        function(err)
            debug.print("Error loading modscript at " .. path .. "/mod.lua")
            debug.print(err)

            msa.file = false
        end
    )
end

return msa