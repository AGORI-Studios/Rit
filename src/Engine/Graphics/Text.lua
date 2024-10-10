---@class Text : Drawable
local Text = Drawable:extend("Text")

---@param text string|nil
---@param x number|nil
---@param y number|nil
---@param size number|nil
---@param colour table|nil
---@param font string|number|nil
function Text:new(text, x, y, size, colour, font, format, value, instance, trimmed, trimWidth, printf)
    text = text or ""
    x = x or 0
    y = y or 0
    size = size or 12
    colour = colour or {1, 1, 1, 1}

    Drawable.new(self, x, y, trimWidth or 1920, 1080)

    self.text = text
    if type(font) ~= "userdata" then
        if not font or font == "" then
            font = size
            size = nil
        end
        self.font = Cache:get("Font", font, size)
    else
        self.font = font
    end
    self.colour = colour
    self.format = format
    self.value = value
    self.instance = instance
    self.trimmed = trimmed
    self.trimWidth = trimWidth
    self.printf = printf

    -- format layout: "%s" or "{math.floor(%d)}"
end

function Text:update(dt)
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
    if not self.format then return self.text end
    return self.format:gsub("{(.-)}", function(a)
        local num = self.instance and self.instance[value] or  _G[value] or value or 0
        if tostring(num) == "inf" or tostring(num) == "-inf" or tostring(num) == "nan" then
            return "0"
        end
        return loadstring("return " .. a:gsub(
            "%%d",
            num
        ))()
    end)
end

function Text:getTextWidth()
    --[[ return self.font:getWidth(self.text) ]]
    local width = self.font:getWidth(self.text)
    -- if trimmed, make sure to do so!
    local text = self.text
    if width > self.trimWidth then
        local trimmed = self.text
        while self.font:getWidth(trimmed .. "...") > self.trimWidth do
            trimmed = trimmed:sub(1, #trimmed - 1)
        end
        text = trimmed .. "..."
    end

    return self.font:getWidth(text)
end

function Text:getTextHeight()
    return self.font:getHeight(self.text)
end

function Text:draw()
    if not self.visible then return end
    if self.text == "" then return end
    love.graphics.push()
    love.graphics.translate(self.drawX, self.drawY)
    love.graphics.rotate(math.rad(self.angle))
    love.graphics.translate(-self.drawX, -self.drawY)
    local lastColour, lastFont = {love.graphics.getColor()}, love.graphics.getFont()
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colour)

    if not self.trimmed then
        --love.graphics.print(self.text, self.drawX, self.drawY, 0, 1, 1, 0, 0, self.shear.x, self.shear.y)
        if not self.printf then
            love.graphics.print(self.text, self.drawX, self.drawY, 0, 1, 1, 0, 0, self.shear.x, self.shear.y)
        else
            love.graphics.printf(self.text, self.drawX, self.drawY, self.trimWidth, "left", 0, 1, 1, 0, 0, self.shear.x, self.shear.y)
        end
    else
        love.graphics.printWithTrimmed(self.text, self.drawX, self.drawY, self.trimWidth, self.scale.x * self.windowScale.x, self.scale.y * self.windowScale.y, self.shear.x, self.shear.y)
    end

    love.graphics.setColor(lastColour)
    love.graphics.setFont(lastFont)
    love.graphics.pop()
end

return Text
