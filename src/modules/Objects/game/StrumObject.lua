local StrumObject = Sprite:extend()

StrumObject.data = 1

function StrumObject:new(x, y, data)
    self.super.new(self, x, y)
    self.data = data

    self.anims = {}
    if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_unpressed"] then
        self.anims[1] = skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_unpressed"])
    else
        -- default to left
        self.anims[1] = skin:format(skinData["NoteAssets"]["1k_1_receptor_unpressed"])
    end
    if skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_pressed"] then
        self.anims[2] = skin:format(skinData["NoteAssets"][tostring(states.game.Gameplay.mode) .. "k_" .. data .. "_receptor_pressed"])
    else
        -- default to left
        self.anims[2] = skin:format(skinData["NoteAssets"]["1k_1_receptor_pressed"])
    end
    

    Cache:loadImage(self.anims[1], self.anims[2])

    self.graphic = Cache:loadImage(self.anims[1])

    -- todo. different note images for different lanes (skin dependent)

    self:updateHitbox()
    self:setGraphicSize(math.floor(self.width * 0.925))

    return self
end

function StrumObject:update(dt)
    self.super.update(self, dt)
end

function StrumObject:postAddToGroup()
    self.graphic = Cache:loadImage(self.anims[1])
    self.x = self.x + (self.width * 0.925) * (self.data - 1)
    self.x = self.x + 25
    self.ID = self.data
end

function StrumObject:playAnim(anim)
    if anim == "pressed" then
        self.graphic = Cache:loadImage(self.anims[2])
    elseif anim == "unpressed" then
        self.graphic = Cache:loadImage(self.anims[1])
    end
end

return StrumObject