local msa = {}
-- Modscript API

msa.graphics = {}
msa.drawLayers = {}
msa.file = false

function msa.loadScript(path)
    msa.file = false
    tryExcept(
        function()
            love.filesystem.load(path .. "/mod/mod.lua")()

            debug.print("info", "Loaded modscript at " .. path)

            msa.file = true
        end,
        function(err)
            debug.print("error", "Error loading modscript at " .. path .. "/mod/mod.lua")
            debug.print("error", err)

            msa.file = false
        end
    )
end

return msa