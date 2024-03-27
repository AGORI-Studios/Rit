-- Based off of haxeflixel's FlxPoint class
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