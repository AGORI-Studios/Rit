local Button = Drawable:extend("Button")

function Button:new(x, y, width, height, text, font, fontSize, colour, hoverColour, clickColour, textColour, rounding)
    Button.super.new(self, x, y, width, height)
    self.text = text or "Button"
    self.font = font or love.graphics.getFont()
    self.fontSize = fontSize or 12
    self.colour = colour or {1, 1, 1, 1}
    self.hoverColour = hoverColour or {0.9, 0.9, 0.9, 1}
    self.clickColour = clickColour or {0.8, 0.8, 0.8, 1}
    self.textColour = textColour or {0, 0, 0, 1}
    self.rounding = rounding or 0
    self.hovered = false
    self.clicked = false
    self.onClick = function() end
end

function Button:update(dt)
    Button.super.update(self, dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = self:checkCollision(mx, my)

    if self.clicked and not love.mouse.isDown(1) then
        self.clicked = false
        if self.hovered then
            self.onClick()
        end
    end
end

function Button:mousepressed(x, y, button)
    if self:checkCollision(x, y) then
        self.clicked = true
        return true
    end
    return false
end

function Button:checkCollision(x, y)
    Drawable.checkCollision(self, x, y)
end

function Button:draw()
    if self.clicked then
        love.graphics.setColor(self.clickColour)
    elseif self.hovered then
        love.graphics.setColor(self.hoverColour)
    else
        love.graphics.setColor(self.colour)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.rounding)
    love.graphics.setColor(self.textColour)
    love.graphics.setFont(self.font)
    love.graphics.printf(self.text, self.x, self.y + self.height / 2 - self.fontSize / 2, self.width, "center")
end

return Button