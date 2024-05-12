--- Virtual Controller module
-- For creating a virtual controllers for mobile devices.

local VirtualController = Object:extend()

local key = Object:extend()

function key:new(config)
    self.x = config.x or 0
    self.y = config.y or 0
    self.width = config.width or 125
    self.height = config.height or 125
    self.color = config.color or {1, 1, 1}
    self.alpha = config.alpha or 1
    self.key = config.key or "a"
    self.text = config.text or self.key
    self.scanCode = love.keyboard.getKeyFromScancode(self.key)
    self.down = false
    self.downAlpha = config.downAlpha or 1
end

function key:draw()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha * (not self.down and 0.25 or self.downAlpha))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 25, 25)
    love.graphics.setColor(self.color)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 25, 25)
end

function VirtualController:new(config)
    self.keys = {}
    for i, keyConfig in ipairs(config) do
        table.insert(self.keys, key(keyConfig))
    end
end

function VirtualController:redraw(config)
    self.keys = {}
    for i, keyConfig in ipairs(config) do
        table.insert(self.keys, key(keyConfig))
    end
end

function VirtualController:update(dt)

end

function VirtualController:touchpressed(id, x, y, dx, dy, pressure)
    local x, y = toGameScreen(x, y)
    for i, key in ipairs(self.keys) do
        if x > key.x and x < key.x + key.width and y > key.y and y < key.y + key.height then
            self.keys[i].down = true
        end
    end
end

function VirtualController:touchmoved(id, x, y, dx, dy, pressure)
    local x, y = toGameScreen(x, y)
    for i, key in ipairs(self.keys) do
        if not (x > key.x and x < key.x + key.width and y > key.y and y < key.y + key.height) then
            self.keys[i].down = false
        end
    end
end

function VirtualController:touchreleased(id, x, y, dx, dy, pressure)
    local x, y = toGameScreen(x, y)
    for i, key in ipairs(self.keys) do
        if x > key.x and x < key.x + key.width and y > key.y and y < key.y + key.height then
            self.keys[i].down = false
        end
    end
end

function VirtualController:draw()
    for i, key in ipairs(self.keys) do
        key:draw()
        love.graphics.setColor(0, 0, 0)
        local lastFont = love.graphics.getFont()
        setFont("menuBoldX1.5")
        local width = love.graphics.getFont():getWidth(key.text)
        local height = love.graphics.getFont():getHeight(key.text)
        love.graphics.print(key.text, key.x + key.width / 2, key.y + key.height / 2, 0, 1, 1, width / 2, height / 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(lastFont)
    end
end

local og_lkp = love.keyboard.isDown
function love.keyboard.isDown(key)
    local isDown = false
    for i, v in ipairs(currentController.keys) do
        if v.key == key then
            isDown = v.down
        end
    end

    return isDown or og_lkp(key)
end

local og_isdown = love.keyboard.isScancodeDown
function love.keyboard.isScancodeDown(scancode)
    local isDown = false
    for i, v in ipairs(currentController.keys) do
        if v.scanCode == scancode then
            isDown = v.down
        end
    end
    return isDown or og_isdown(scancode)
end

return VirtualController