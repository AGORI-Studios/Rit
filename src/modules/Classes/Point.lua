-- Based off of haxeflixel's FlxPoint class
---@class Point
---@diagnostic disable-next-line: assign-type-mismatch
local Point = Object:extend()

function Point:new(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0

    self.__name = "Point"
    
    return self
end

function Point:get()
    return self.x, self.y, self.z
end

function Point:__tostring()
    return "Point: " .. self.x .. ", " .. self.y .. ", " .. self.z
end

function Point:__add(other)
    return Point(self.x + other.x, self.y + other.y, self.z + other.z)
end

function Point:__sub(other)
    return Point(self.x - other.x, self.y - other.y, self.z - other.z)
end

function Point:__mul(other)
    return Point(self.x * other.x, self.y * other.y, self.z * other.z)
end

function Point:__div(other)
    return Point(self.x / other.x, self.y / other.y, self.z / other.z)
end

function Point:__eq(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

function Point:__lt(other)
    return self.x < other.x and self.y < other.y and self.z < other.z
end

function Point:__le(other)
    return self.x <= other.x and self.y <= other.y and self.z <= other.z
end

function Point:__unm()
    return Point(-self.x, -self.y, -self.z)
end

function Point:__concat(other)
    return tostring(self) .. tostring(other)
end

function Point:set(x, y)
    local x = x or 0
    local y = y or x

    self.x, self.y = x, y
end

return Point