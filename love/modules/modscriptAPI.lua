--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]
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