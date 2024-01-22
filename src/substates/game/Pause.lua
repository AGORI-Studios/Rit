local Pause = state()

local options = {
    "Resume",
    "Restart",
    "Leave",
}

function Pause:enter()
    self.selection = 1
end

function Pause:update(dt)
    if input:pressed("up") then
        self.selection = self.selection - 1
    elseif input:pressed("down") then
        self.selection = self.selection + 1
    end

    self.selection = math.clamp(self.selection, 1, #options)

    if input:pressed("confirm") then
        if self.selection == 1 then
            
        elseif self.selection == 2 then
            state.switch(states.game.Gameplay)
        elseif self.selection == 3 then
            state.switch(states.menu.SongMenu)
        end
        states.game.Gameplay.inPause = false
        states.game.Gameplay.updateTime = true
        previousFrameTime = love.timer.getTime() * 1000
        states.game.Gameplay.escapeTimer = 0
        state.killSubstate(self.selection == 2)
    end
end

function Pause:mousemoved(x, y, dx, dy, istouch)
    if x > 0 and x < __inits.__GAME_WIDTH and y > 0 and y < __inits.__GAME_HEIGHT then
        self.selection = math.floor((y - 200) / 50) + 1
    end
end

function Pause:mousepressed(x, y, button, istouch)
    if x > 0 and x < __inits.__GAME_WIDTH and y > 0 and y < __inits.__GAME_HEIGHT then
        if self.selection == 1 then
            
        elseif self.selection == 2 then
            state.switch(states.game.Gameplay)
        elseif self.selection == 3 then
            state.switch(states.menu.SongMenu)
        end
        states.game.Gameplay.inPause = false
        states.game.Gameplay.updateTime = true
        previousFrameTime = love.timer.getTime() * 1000
        states.game.Gameplay.escapeTimer = 0
        state.killSubstate()
    end
end

function Pause:draw() 
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Cache.members.font["menuBig"])
    love.graphics.printf("Paused", 0, 100, __inits.__GAME_WIDTH, "center")

    love.graphics.setFont(Cache.members.font["menuMedium"])
    for i, v in ipairs(options) do
        if i == self.selection then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        love.graphics.printf(v, 0, 200 + (i * 50), __inits.__GAME_WIDTH, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(Cache.members.font["default"])
end

function Pause:exit()

end

return Pause