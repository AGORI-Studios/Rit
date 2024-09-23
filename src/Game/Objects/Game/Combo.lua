local Combo = Class:extend("Combo")

function Combo:draw()
    local num = States.Screens.Game.instance.combo
    local str = tostring(num)

    for i = 1, #str do
        local char = str:sub(i, i)
        local spr = Sprite(Skin._comboAssets[tonumber(char)], 0, 0, false)

        -- center the sprites to Game._gameWidth
        spr.x = Game._gameWidth/2 - ((spr.width * 1.5) * #str)/2 + (i-1) * (spr.width * 1.5)
        spr.y = 1080/2
        spr.scale.x, spr.scale.y = 1.5, 1.5
        spr:update(love.timer.getDelta())
        spr:resize(Game._windowWidth, Game._windowHeight)

        spr:draw()
    end
end

return Combo