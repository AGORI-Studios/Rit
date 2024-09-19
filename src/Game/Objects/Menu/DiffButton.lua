local DiffButton = Sprite:extend("DiffButton")

function DiffButton:new(diffData, parent)
    self.data = diffData
    self.index = diffData.index

    Sprite.new(self, "Assets/Textures/Menu/DiffBtn.png", 0, 0, true)

    self.drawY = Game._windowHeight/2 + self.index * (self.height+20) - self.height/2
    self.lastDrawY = self.drawY
    self.lerpedDrawY = self.drawY
    self.parent = parent
end

function DiffButton:updateYFromIndex(index, dt)
    self.lerpedDrawY = (self.parent.drawY-self.parent.baseHeight) + (self.index - index) * (self.height+20) - self.height/2

    self.drawY = math.fpsLerp(self.lastDrawY, self.lerpedDrawY, 15, dt)
    self.lastDrawY = self.drawY

    if self.index-1 == index then
        self.colour[1], self.colour[2], self.colour[3] = 1, 1, 1
    else
        self.colour[1], self.colour[2], self.colour[3] = 0.5, 0.5, 0.5
    end
end

function DiffButton:draw(self)
    Sprite.draw(self)
    love.graphics.printWithTrimmed(self.data.diff_name, self.drawX + 20, self.drawY + 20, 300)
end

return DiffButton