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

function love.keypressed(key, scancode, isrepeat)
    Input:keypressed(key)
    Game:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
    Input:keyreleased(key)
    Game:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
    Game:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    Game:mousereleased(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
    Game:wheelmoved(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
    Game:mousemoved(x, y, dx, dy, istouch)
end

function love.draw()
    Game:draw()

    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Game: " .. Game:__tostring(), 10, 30)

    if Input:isDown("MenuPress") then
        love.graphics.print("Menu Pressed", 10, 50)
    end
end
