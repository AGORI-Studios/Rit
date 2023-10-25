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

local Point = Object:extend()

function Point:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Point:get()
    return self.x, self.y
end

function Point:__tostring()
    return "Point: " .. self.x .. ", " .. self.y
end

function Point:__add(other)
    return Point(self.x + other.x, self.y + other.y)
end

function Point:__sub(other)
    return Point(self.x - other.x, self.y - other.y)
end

function Point:__mul(other)
    return Point(self.x * other.x, self.y * other.y)
end

function Point:__div(other)
    return Point(self.x / other.x, self.y / other.y)
end

function Point:__eq(other)
    return self.x == other.x and self.y == other.y
end

function Point:__lt(other)
    return self.x < other.x and self.y < other.y
end

function Point:__le(other)
    return self.x <= other.x and self.y <= other.y
end

function Point:__unm()
    return Point(-self.x, -self.y)
end

function Point:__concat(other)
    return tostring(self) .. tostring(other)
end

return Point