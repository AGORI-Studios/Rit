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

local Group = Object:extend()

function Group:new()
    self.members = {}
end

function Group:add(n)
    table.insert(self.members, n)
end

function Group:remove(n)
    for i, v in ipairs(self.members) do
        if v == n then
            table.remove(self.members, i)
            break
        end
    end
end

function Group:update(dt)
    for i, v in ipairs(self.members) do
        v:update(dt)
    end
end

function Group:draw()
    for i, v in ipairs(self.members) do
        v:draw()
    end
end

return Group