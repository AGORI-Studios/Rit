---@class StrumObject
---@diagnostic disable-next-line: assign-type-mismatch
local StrumObject = VertSprite:extend()

StrumObject.data = 1

function StrumObject:new(x, y, data)
    self.super.new(self, x, y, 0)
    self.data = data

    self.anims = {}
    self.anims[1] = skin:format("notes/" .. tostring(states.game.Gameplay.mode or states.screens.MapEditorScreen.map.meta.KeyAmount) .. "K/receptor" .. data .. "-unpressed.png")
    self.anims[2] = skin:format("notes/" .. tostring(states.game.Gameplay.mode or states.screens.MapEditorScreen.map.meta.KeyAmount) .. "K/receptor" .. data .. "-pressed.png")
    self.animTimer = 0
    

    Cache:loadImage(self.anims[1], self.anims[2])

    self.graphic = Cache:loadImage(self.anims[1])

    self:updateHitbox()
    self:updateHitbox()

    self.forcedDimensions = true
    self.dimensions = {width = 200, height = 200}
    self:centerOrigin()

    return self
end

function StrumObject:update(dt)
    self.super.update(self, dt)
    --self.animTimer = self.animTimer - dt
end

function StrumObject:postAddToGroup()
    self.graphic = Cache:loadImage(self.anims[1])

    self.x = states.game.Gameplay.strumX + (200 + Settings.options["General"].columnSpacing) * (self.data - 1)
    self.x = self.x + 25
    self.ID = self.data
end

function StrumObject:playAnim(anim)
    -- Update the graphic to the correct animation
    if anim == "pressed" then
        self.graphic = Cache:loadImage(self.anims[2])
    elseif anim == "unpressed" then
        self.graphic = Cache:loadImage(self.anims[1])
    end
end

return StrumObject