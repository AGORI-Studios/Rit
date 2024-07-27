local playfieldSprs = {}
function Start()
    playfieldSprs[1] = states.game.Gameplay.playfieldVertSprites[1]
    for i = 2, 26 do
        if i < 26 then
            playfieldSprs[i] = CreatePlayfieldVertSprite(1)
        end
        playfieldSprs[i-1].gx, playfieldSprs[i-1].gy = love.math.random(-1920/2, 1920/2), love.math.random(-1080/2, 1080/2)
        playfieldSprs[i-1].rotationg = Point(love.math.random(0, 360), love.math.random(0, 360), love.math.random(0, 360))
        playfieldSprs[i-1].velY = love.math.random(25*5, 50*5)
        playfieldSprs[i-1].x = playfieldSprs[i-1].gx
        playfieldSprs[i-1].y = playfieldSprs[i-1].gy
        playfieldSprs[i-1].rotation = Point(
            playfieldSprs[i-1].rotationg.x,
            playfieldSprs[i-1].rotationg.y,
            playfieldSprs[i-1].rotationg.z
        )

        playfieldSprs[i-1].gz = love.math.random(-250, 250)

        playfieldSprs[i-1].scale = Point(
            0.45, 0.45, 0.45
        )
    end
end

function Update(dt)
    for i, spr in ipairs(playfieldSprs) do
        if i == #playfieldSprs then return end
        spr.x = spr.gx + math.sin((love.timer.getTime()*10) / (25 * i)) * 100
        spr.y = spr.y - spr.velY * dt
        spr.z = spr.gz + math.sin(love.timer.getTime()) * 100

        if spr.y < -spr.height/2 then
            spr.gx = love.math.random(-1920/2, 1920/2)
            spr.velY = love.math.random(25*5, 50*5)
            spr.y = 1080
        end
    end

    local last = playfieldSprs[#playfieldSprs]

    last.rotation.z = last.rotation.z + 25 * dt
    last.rotation.x = last.rotation.x + 12.5 * dt
    last.rotation.y = last.rotation.y + 6.25 * dt
end