
require("Engine")

function love.load()

end

function love.update(dt)
    Game:update(dt)
end

function love.resize(w, h)
    Game:resize(w, h)
end

function love.draw()
    Game:draw()

    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Game: " .. Game:__tostring(), 10, 30)
end