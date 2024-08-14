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
            switchState(states.game.Gameplay, 0.3)
        elseif self.selection == 3 then
            switchState(states.menu.SongMenu, 0.3)
        end
        states.game.Gameplay.inPause = false
        states.game.Gameplay.updateTime = true
        previousFrameTime = love.timer.getTime() * 1000
        states.game.Gameplay.escapeTimer = 0
        state.killSubstate(self.selection == 2, self.selection == 3)
    end
end

function Pause:mousemoved(x, y, dx, dy, istouch)
    local x, y = toGameScreen(x, y)
    if x > 0 and x < Inits.GameWidth and y > 0 and y < Inits.GameHeight then
        self.selection = math.floor((y - 250) / 50) + 1
        self.selection = math.clamp(self.selection, 1, #options)
    end
end

function Pause:touchpressed(id, x, y, dx, dy, pressure)
    local x, y = toGameScreen(x, y)
    if x > 0 and x < Inits.GameWidth and y > 0 and y < Inits.GameHeight then
        if self.selection == 1 then
            
        elseif self.selection == 2 then
            switchState(states.game.Gameplay, 0.3)
        elseif self.selection == 3 then
            switchState(states.menu.SongMenu, 0.3)
        end
        states.game.Gameplay.inPause = false
        states.game.Gameplay.updateTime = true
        previousFrameTime = love.timer.getTime() * 1000
        states.game.Gameplay.escapeTimer = 0
        state.killSubstate(self.selection == 2, self.selection == 3)
    end
end

function Pause:mousepressed(x, y, button, istouch)
    if x > 0 and x < Inits.GameWidth and y > 0 and y < Inits.GameHeight then
        if self.selection == 1 then
            
        elseif self.selection == 2 then
            switchState(states.game.Gameplay, 0.3)
        elseif self.selection == 3 then
            states.game.Gameplay.soundManager:removeAllSounds()
            switchState(states.menu.SongMenu, 0.3)
        end
        states.game.Gameplay.inPause = false
        states.game.Gameplay.updateTime = true
        previousFrameTime = love.timer.getTime() * 1000
        states.game.Gameplay.escapeTimer = 0
        state.killSubstate(self.selection == 2, self.selection == 3)
    end
end

function Pause:draw() 
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Cache.members.font["menuBig"])
    love.graphics.printf(localize("Paused"), 0, 100, Inits.GameWidth, "center")

    love.graphics.setFont(Cache.members.font["menuMedium"])
    for i, v in ipairs(options) do
        if i == self.selection then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        if i == 2 then
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
        end
        love.graphics.printf(v, 0, 200 + (i * 50), Inits.GameWidth, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setFont(Cache.members.font["default"])
end

function Pause:exit()

end

return Pause