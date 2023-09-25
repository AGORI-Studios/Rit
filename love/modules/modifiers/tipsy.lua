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

local tipsy = {}
function tipsy:apply(amount)
    -- Apply the tipsy mod
    -- causes the note receptors to go up and down depending on its modifier
    table.insert(modifiers.curEnabled, {"tipsy", amount})
end

function tipsy:update(dt, beat, amount)
    for i = 1, 4 do
        local ypos = 0

        ypos = ypos + amount * (math.cos(musicTime*0.001+i*(1.2)+1*(1.2))*receptors[i][1]:getHeight()*0.5)

        receptors[i][1].offsetY = ypos
        receptors[i][2].offsetY = ypos

        noteImgs[i][1].offsetY = ypos
        noteImgs[i][2].offsetY = ypos
        noteImgs[i][3].offsetY = ypos
    end
end

return tipsy