require("Engine")
require("Game")

function love.load()
    Game:SwitchState(States.Testing.TestState)
end

function love.update(dt)
    Input:update()
    Game:update(dt)
end

function love.resize(w, h)
    Game:resize(w, h)
    Game._windowWidth = w
    Game._windowHeight = h
end

function love.keypressed(key)
    Input:keypressed(key)
end

function love.keyreleased(key)
    Input:keyreleased(key)
end

function love.draw()
    Game:draw()

    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Game: " .. Game:__tostring(), 10, 30)

    if Input:isDown("MenuPress") then
        love.graphics.print("Menu Pressed", 10, 50)
    end
end
