local Combo = Class:extend("Combo")

function Combo:new()
    self.sprites = {}
    self.lastCombo = 0
end

function Combo:doHit()
    for _, sprite in pairs(self.sprites) do
        sprite.scale.y = 1.55
        sprite.scale.x, sprite.scale.y = 1.5, 1.85
    end
end

function Combo:getComboSprite(digit)
    if not self.sprites[digit] then
        self.sprites[digit] = Sprite(Skin._comboAssets[digit], 0, 0, false)
        self.sprites[digit].scale.x, self.sprites[digit].scale.y = 1.5, 1.7
        self.sprites[digit].debug = false
    end

    return self.sprites[digit]
end

function Combo:draw()
    local num = States.Screens.Game.instance.combo
    if num == 0 then
        return
    end
    if num ~= self.lastCombo then
        self:doHit()
    end
    local str = tostring(num)

    for i = 1, #str do
        local char = str:sub(i, i)
        local digit = tonumber(char)
        local spr = self:getComboSprite(digit or 0)

        spr.x = 1920 / 2 + (i - #str / 2) * 100
        spr.y = 1080 / 2
        spr:update(love.timer.getDelta())
        spr:resize(Game._windowWidth, Game._windowHeight)

        if spr.scale.y > 1.5 then
            spr.scale.y = spr.scale.y - 5 * love.timer.getDelta()
        end

        spr:draw()
    end

    self.lastCombo = num
end

return Combo
