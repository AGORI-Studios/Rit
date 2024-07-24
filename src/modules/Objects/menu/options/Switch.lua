--- @class Switch
---@diagnostic disable-next-line: assign-type-mismatch
local Switch = Object:extend()

function Switch:new(tag, state, optionTag, option)
    self.tag = tag or "Tag" -- The longest tag will be "Photosensitive Mode"
    self.state = state or false
    self.x, self.y = 0, 0
    self.optionTag = optionTag or "General" -- Settings.options[self.optionTag]
    self.option = option or "downscroll" -- Settings.options[self.optionTag][self.option]
    self.state = Settings.options[self.optionTag][self.option]

    self.onSprite = Sprite(0, 0, "assets/images/ui/menu/options/switchOnFull.png")
    self.offSprite = Sprite(0, 0, "assets/images/ui/menu/options/switchOffFull.png")
    self.sprite = self.offSprite
    if self.state then
        self.sprite = self.onSprite
    end
end

function Switch:onToggle() end -- <- Override me

function Switch:update(dt)
    self.sprite.x, self.sprite.y = self.x + 450, self.y + 2
    self.sprite:setGraphicSize(self.sprite.width * 0.5)
end

function Switch:mousepressed(x, y, b)
    if self.sprite:isHovered(x, y) then
        self:toggle()
    end
end

function Switch:toggle()
    self.state = not self.state
    if self.state then
        self.sprite = self.onSprite
    else
        self.sprite = self.offSprite
    end

    Settings.options[self.optionTag][self.option] = self.state

    self:onToggle()
end

function Switch:draw()
    love.graphics.print(self.tag, self.x, self.y + 10)
    self.sprite:draw()
end

return Switch