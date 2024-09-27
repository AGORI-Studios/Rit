local VirtualPad = Class:extend("VirtualPad")
VirtualPad._CURRENT = nil

local keyDefaults = {
    size = {64, 64},
    color = {1, 1, 1},
    alpha = 0.25,
    downAlpha = 0.5,
    position = {0, 0},
    rounding = 15,
    key = "return",
    border = true
}

function VirtualPad:new(settings)
    self.settings = settings
    self.keys = {}

    for i, key in ipairs(settings) do
        -- set defaults if not set
        for k, v in pairs(keyDefaults) do
            if not key[k] then
                key[k] = v
            end
        end
        self.keys[key.key] = key
        self.keys[key.key].down = false
        self.keys[key.key].touchid = nil
    end
end

local function toGameScale(x, y)
    -- the buttons are stretched to the window
    return x * Game._gameWidth / Game._windowWidth, y * Game._gameHeight / Game._windowHeight
end

function VirtualPad:touchpressed(id, x, y, dx, dy, pressure)
    x, y = toGameScale(x, y)
    for i, key in ipairs(self.settings) do
        if x >= key.position[1] and x <= key.position[1] + key.size[1] and y >= key.position[2] and y <= key.position[2] + key.size[2] and not self.keys[key.key].touchid then
            self.keys[key.key].touchid = id
            if not self.keys[key.key].down then
                love.keypressed(key.key, nil, false)
            end
            self.keys[key.key].down = true
            break
        end
    end
end

function VirtualPad:touchreleased(id, x, y, dx, dy, pressure)
    x, y = toGameScale(x, y)
    for i, key in ipairs(self.settings) do
        if x >= key.position[1] and x <= key.position[1] + key.size[1] and y >= key.position[2] and y <= key.position[2] + key.size[2] and self.keys[key.key].touchid == id then
            self.keys[key.key].touchid = nil
            if self.keys[key.key].down then
                love.keyreleased(key.key, nil)
            end
            self.keys[key.key].down = false
            break
        end
    end
end

function VirtualPad:touchmoved(id, x, y, dx, dy, pressure)
    x, y = toGameScale(x, y)
    for i, key in ipairs(self.settings) do
        -- if moved out, release the key
        if not (x >= key.position[1] and x <= key.position[1] + key.size[1] and y >= key.position[2] and y <= key.position[2] + key.size[2]) and self.keys[key.key].touchid == id then
            self.keys[key.key].touchid = nil
            if self.keys[key.key].down then
                love.keyreleased(key.key, nil)
            end
            self.keys[key.key].down = false
        end
    end
end

function VirtualPad:mousepressed(x, y, button)
    x, y = toGameScale(x, y)
    for i, key in ipairs(self.settings) do
        if x >= key.position[1] and x <= key.position[1] + key.size[1] and y >= key.position[2] and y <= key.position[2] + key.size[2] then
            if not self.keys[key.key].down then
                love.keypressed(key.key, nil, false)
            end
            self.keys[key.key].down = true
            break
        end
    end
end

function VirtualPad:mousereleased(x, y, button)
    x, y = toGameScale(x, y)
    for i, key in ipairs(self.settings) do
        if x >= key.position[1] and x <= key.position[1] + key.size[1] and y >= key.position[2] and y <= key.position[2] + key.size[2] then
            if self.keys[key.key].down then
                love.keyreleased(key.key, nil)
            end
            self.keys[key.key].down = false
            break
        end
    end
end

function VirtualPad:mousemoved(x, y, dx, dy, istouch)
    x, y = toGameScale(x, y)
    for i, key in ipairs(self.settings) do
        if not (x >= key.position[1] and x <= key.position[1] + key.size[1] and y >= key.position[2] and y <= key.position[2] + key.size[2]) then
            if self.keys[key.key].down then
                love.keyreleased(key.key, nil)
            end
            self.keys[key.key].down = false
        end
    end
end

function VirtualPad:isDown(key)
    return self.keys[key].down
end

function VirtualPad:isScancodeDown(scancode)
    for i, key in ipairs(self.settings) do
        for j, k in ipairs(key.keys) do
            if love.keyboard.isScancodeDown(k) then
                return true
            end
        end
    end
    return false
end

function VirtualPad:update(dt) end

function VirtualPad:draw()
    for i, key in ipairs(self.settings) do
        love.graphics.setColor(key.color[1], key.color[2], key.color[3], key.down and key.downAlpha or key.alpha)
        love.graphics.rectangle("fill", key.position[1], key.position[2], key.size[1], key.size[2], key.rounding)
        if key.border then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle("line", key.position[1], key.position[2], key.size[1], key.size[2], key.rounding)
        end
    end
end

local o_lkeyboard_isDown = love.keyboard.isDown
function love.keyboard.isDown(key)
    -- check both for the virtual pad and the keyboard
    local isDown = false
    if VirtualPad._CURRENT then
        isDown = VirtualPad._CURRENT:isDown(key)
    end
    return isDown or o_lkeyboard_isDown(key)
end

local o_lkeyboard_isScancodeDown = love.keyboard.isScancodeDown
function love.keyboard.isScancodeDown(scancode)
    -- check both for the virtual pad and the keyboard
    local isDown = false
    if VirtualPad._CURRENT then
        isDown = VirtualPad._CURRENT:isScancodeDown(scancode)
    end
    return isDown or o_lkeyboard_isScancodeDown(scancode)
end


return VirtualPad