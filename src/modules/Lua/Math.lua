---Rounds a number to the nearest integer
---@param num number
---@param numDecimalPlaces? number (optional)
---@return number
function math.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

---Clamps a number between a minimum and a maximum value
---@param low number
---@param n number
---@param high number
---@return number
function math.clamp(low, n, high)
    return math.min(math.max(low, n), high)
end

---Returns the sign of a number
---@param n number
---@return number
function math.sign(n)
    return n > 0 and 1 or n < 0 and -1 or 0
end

---Returns the distance between two points
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function math.distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1) ^ 2 + (y2-y1) ^ 2)
end

---Returns the angle between two points
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

---Remaps a number from one range to another
---@param value number
---@param from1 number
---@param to1 number
---@param from2 number
---@param to2 number
---@return number
function math.remapToRange(value, from1, to1, from2, to2)
    return (value - from1) / (to1 - from1) * (to2 - from2) + from2
end

---Linearly interpolates between two numbers
---@param a number
---@param b number
---@param t number
---@return number
function math.lerp(a, b, t)
    return a + (b - a) * t
end

---Linearly interpolates between two numbers, taking into account the time between frames
---@param a number
---@param b number
---@param t number
---@param dt? number
---@return number
function math.fpsLerp(a, b, t, dt)
    local dt = dt or love.timer.getDelta()
    return math.lerp(a, b, 1 - math.exp(-t * dt))
end

---Returns a pseudo-random gradient vector
---@param hash number
---@param x number
---@param y number
---@param z number
---@return number
function math.grad(hash, x, y, z)
    local h = hash % 16
    local u = h < 8 and x or y
    local v = h < 4 and y or ((h == 12 or h == 14) and x or z)
    return ((h % 2) == 0 and u or -u) + ((h % 3) == 0 and v or -v)
end

---Returns a fade value
---@param t number
---@return number
function math.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

---Returns a perlin noise value
---@param x number
---@param y number
---@param z number
---@return number
function math.perlinNoise(x, y, z)
    local X = math.floor(x) 
    local Y = math.floor(y)
    local Z = math.floor(z)

    x = x - X
    y = y - Y
    z = z - Z

    local u = math.fade(x)
    local v = math.fade(y)
    local w = math.fade(z)

    local p = {}
    for i = 0, 255 do
        p[i] = love.math.random(0, 255)
    end

    local A = p[X] + Y
    local AA = p[A] + Z
    local AB = p[A + 1] + Z
    local B = p[X + 1] + Y
    local BA = p[B] + Z
    local BB = p[B + 1] + Z

    return math.lerp(w, math.lerp(v, math.lerp(u, math.grad(p[AA], x, y, z),
        math.grad(p[BA], x - 1, y, z)),
            math.lerp(u, math.grad(p[AB], x, y - 1, z),
                    math.grad(p[BB], x - 1, y - 1, z))),
            math.lerp(v, math.lerp(u, math.grad(p[AA + 1], x, y, z - 1),
                math.grad(p[BA + 1], x - 1, y, z - 1)),
                    math.lerp(u, math.grad(p[AB + 1], x, y - 1, z - 1),
                        math.grad(p[BB + 1], x - 1, y - 1, z - 1))))
end

---Returns a smoothstep value
---@param edge0 number
---@param edge1 number
---@param x number
---@return number
function math.smoothstep(edge0, edge1, x)
    x = math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return x * x * (3 - 2 * x)
end

---Returns a smootherstep value
---@param edge0 number
---@param edge1 number
---@param x number
---@return number
function math.smootherstep(edge0, edge1, x)
    x = math.clamp((x - edge0) / (edge1 - edge0), 0, 1)
    return x * x * x * (x * (x * 6 - 15) + 10)
end

-- Uncomment this to break the game lol
--[[ setmetatable(math, {
    __index = function(self, f)
        return function(val)
            return val
        end
    end
})

for k, v in pairs(math) do
    if type(v) == "function" then
        math[k] = function(...)
            local args = {...}
            return args[1]
        end
    end
end ]]