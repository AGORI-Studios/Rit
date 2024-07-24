--- @class Slider
---@diagnostic disable-next-line: assign-type-mismatch
local Slider = Object:extend()

function Slider:new(tag, value, optionTag, option, min, max)
    self.tag = tag or "Tag"
    self.value = value or 0
    self.min = min or 0
    self.max = max or 100
    self.x, self.y = 0, 0
    self.optionTag = optionTag or "General"
    self.option = option or "volume"
    self.value = Settings.options[self.optionTag][self.option]

    self.barWidth = 300 -- Longer bar
    self.barHeight = 10
    self.handleWidth = 15
    self.handleHeight = 22

    self.sliderXOffset = 250 -- Offset to the right
    self.sliderYOffset = 23 -- Offset down by 15 pixels

    self.textXOffset = 0

    self.keyDiff = 0.1

    self:updateHandlePosition()
end

function Slider:updateHandlePosition()
    local normalizedValue = (self.value - self.min) / (self.max - self.min)
    self.handleX = self.x + self.sliderXOffset + normalizedValue * (self.barWidth - self.handleWidth)
    self.handleY = self.y + self.sliderYOffset + (self.barHeight - self.handleHeight) / 2
end

function Slider:onValueChanged(value) end -- <- Override me

function Slider:update(dt)
    self:updateHandlePosition()
end

function Slider:mousepressed(x, y, b)
    if x >= self.handleX and x <= self.handleX + self.handleWidth and y >= self.handleY and y <= self.handleY + self.handleHeight then
        self.dragging = true
    else
        if x >= self.x + self.sliderXOffset and x <= self.x + self.sliderXOffset + self.barWidth and
           y >= self.y + self.sliderYOffset and y <= self.y + self.sliderYOffset + self.barHeight then
            local newHandleX = math.clamp(self.x + self.sliderXOffset, x - self.handleWidth / 2, self.x + self.sliderXOffset + self.barWidth - self.handleWidth)
            local normalizedValue = (newHandleX - (self.x + self.sliderXOffset)) / (self.barWidth - self.handleWidth)
            self.value = self.min + normalizedValue * (self.max - self.min)

            Settings.options[self.optionTag][self.option] = self.value

            self:onValueChanged(self.value)
            self.dragging = true
        end
    end
end

function Slider:mousereleased(x, y, b)
    self.dragging = false
end

function Slider:mousemoved(x, y, dx, dy)
    if self.dragging then
        local newHandleX = math.max(self.x + self.sliderXOffset, math.min(x - self.handleWidth / 2, self.x + self.sliderXOffset + self.barWidth - self.handleWidth))
        local normalizedValue = (newHandleX - (self.x + self.sliderXOffset)) / (self.barWidth - self.handleWidth)
        self.value = self.min + normalizedValue * (self.max - self.min)

        Settings.options[self.optionTag][self.option] = self.value

        self:onValueChanged(self.value)
    end
end

function Slider:keypressed(key)
    local x, y = toGameScreen(love.mouse.getPosition())

    if x >= self.x + self.sliderXOffset and x <= self.x + self.sliderXOffset + self.barWidth and
       y >= self.y + self.sliderYOffset and y <= self.y + self.sliderYOffset + self.barHeight then

        if key == "left" then
            self.value = math.clamp(self.min, self.value - self.keyDiff * (love.keyboard.isDown("lshift") and 0.1 or 1), self.max)
        elseif key == "right" then
            self.value = math.clamp(self.min, self.value + self.keyDiff * (love.keyboard.isDown("lshift") and 0.1 or 1), self.max)
        end

        Settings.options[self.optionTag][self.option] = self.value
        self:onValueChanged(self.value)
        self:updateHandlePosition()
    end
end

function Slider:draw()
    love.graphics.print(self.tag, self.x, self.y + 10)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", self.x + self.sliderXOffset, self.y + self.sliderYOffset, self.barWidth, self.barHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.handleX, self.handleY, self.handleWidth, self.handleHeight)
    local lastFont = love.graphics.getFont()
    love.graphics.setFont(Cache.members.font["defaultBold"])
    love.graphics.print(string.format("%.2f", self.value), self.x + self.sliderXOffset - 35 + self.textXOffset, self.y + self.sliderYOffset - 6)
    love.graphics.setFont(lastFont)
end

return Slider