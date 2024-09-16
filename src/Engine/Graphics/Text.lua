---@class Text : Drawable
local Text = Drawable:extend()

---@param text string|nil
---@param x number|nil
---@param y number|nil
---@param size number|nil
---@param colour table|nil
---@param font string|number|nil
function Text:new(text, x, y, size, colour, font, format, value, instance)
    text = text or ""
    x = x or 0
    y = y or 0
    size = size or 12
    colour = colour or {1, 1, 1, 1}

    Drawable.new(self, x, y, 0, 0)

    self.text = text
    if not font or font == "" then
        font = size
        size = nil
    end
    self.font = love.graphics.newFont(font, size)
    self.colour = colour
    self.format = format
    self.value = value
    self.instance = instance

    -- format layout: "%s" or "{math.floor(%d)}"
end

function Text:update(dt)
    self.width = self.font:getWidth(self.text)
    self.height = self.font:getHeight()
    Drawable.update(self, dt)

    -- update text value
    if self.format then
        self.text = self:updateText(self.value)
    end
end

-- if true, the function is restricted
local restrictedFuncs = {
    os = {
        execute = true,
        exit = true,
        remove = true,
        rename = true,
        setlocale = true,
        time = true,
        tmpname = true
    }
}

function Text:updateText(value)
    return self.format:gsub("{(.-)}", function(a) 
        return loadstring("return " .. a:gsub("%%d", self.instance and self.instance[value] or _G[value] or value))()
    end)
end

function Text:draw()
    --[[ print(self.text, self.drawX, self.drawY) ]]
    if self.text == "" then return end
    local lastColour, lastFont = {love.graphics.getColor()}, love.graphics.getFont()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colour)

    love.graphics.print(self.text, self.drawX, self.drawY)

    love.graphics.setColor(lastColour)
    love.graphics.setFont(lastFont)
end

return Text