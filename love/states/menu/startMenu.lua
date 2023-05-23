return {
    enter = function(self)
        logo = love.graphics.newImage("assets/images/ui/menu/logo.png")

        logoSize = 1

        beat = 0
        time = 0
    end,

    update = function(self, dt)
        time = time + dt * 1000

        if (time > (60/menuBPM) * 1000) then
            local curBeat = math.floor(menuMusic:tell() / (60/menuBPM))
            if curBeat % 2 == 0 then
                logoSize = 1.1
            end
            time = 0
        end

        if logoSize > 1 then
            logoSize = logoSize - (dt * ((menuBPM/60))) * 0.3
        end

        if input:pressed("confirm") then
            state.switch(songSelect)
        end
    end,

    draw = function(self)
        love.graphics.push()
            love.graphics.scale(0.35, 0.35)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(
                logo, 
                push.getWidth()+1000, push.getHeight()+400, 
                0, 
                logoSize, logoSize, 
                logo:getWidth() / 2, logo:getHeight() / 2
            )
        love.graphics.pop()
    end,

    leave = function(self)

    end
}