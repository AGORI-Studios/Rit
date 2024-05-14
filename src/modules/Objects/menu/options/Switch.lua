--- @class Switch
---@diagnostic disable-next-line: assign-type-mismatch
local Switch = Object:extend()

function Switch:new(tag, state, optionTag, option)
    self.tag = tag or "Tag" -- The longest tag will be "Photosensitive Mode"
    self.state = state or false
    self.x, self.y = 0, 0
    self.optionTag = optionTag or "Switch" -- Settings.options[self.optionTag]
    self.option = option or "Switch" -- Settings.options[self.optionTag][self.option]

    self.onSprite = Sprite(0, 0, "assets/images/ui/menu/options/switchOnFull.png")
    self.offSprite = Sprite(0, 0, "assets/images/ui/menu/options/switchOffFull.png")
    self.sprite = self.offSprite
end

function Switch:update(dt)

end

function Switch:toggle()
    self.state = not self.state
    if self.state then
        self.sprite = self.onSprite
    else
        self.sprite = self.offSprite
    end
end

function Switch:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.tag, self.x, self.y + 10)
    love.graphics.draw(self.sprite.image, self.x + 200, self.y, 0, 0.5, 0.5)
end

return Switch