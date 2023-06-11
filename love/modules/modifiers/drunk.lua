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

local drunk = {}
-- Drunk is a notig mod. It's a modifier that makes the notes look drunk.
function drunk:apply(amount)
    -- Apply the drunk mod
    -- causes the note receptors to go left and right depending on its modifier
    table.insert(modifiers.curEnabled, {"drunk", amount})

end

function drunk:update(dt, beat, amount)
    --print("drunkIsEnabled")
    for i = 1, 4 do
        local xpos = 0

        xpos = xpos + amount * (math.cos(musicTime*0.001+i*(0.2)+1*(0.2))*receptors[i][1]:getWidth()*0.5)

        receptors[i][1].offsetX = xpos
        receptors[i][2].offsetX = xpos

        noteImgs[i][1].offsetX = xpos
        noteImgs[i][2].offsetX = xpos
        noteImgs[i][3].offsetX = xpos
    end
end

return drunk