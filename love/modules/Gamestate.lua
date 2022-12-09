local Gamestate = {}
local current, to, pre = nil, nil, nil

function Gamestate.switch(to, ...)
    assert(to, "Missing argument: Gamestate to switch to")
    pre = current
    if pre then pre:leave(to) end
    current = to
    to:init(pre, ...)
    to:enter(pre, ...)
end

function Gamestate.update(dt)
    if current then current:update(dt) end
end

function Gamestate.draw()
    if current then current:draw() end
end

function Gamestate.keypressed(key, unicode)
    if current then current:keypressed(key, unicode) end
end

function Gamestate.keyreleased(key)
    if current then current:keyreleased(key) end
end

function Gamestate.textinput(text)
    if current then current:textinput(text) end
end

function Gamestate.mousepressed(x, y, button)
    if current then current:mousepressed(x, y, button) end
end

function Gamestate.mousereleased(x, y, button)
    if current then current:mousereleased(x, y, button) end
end

function Gamestate.joystickpressed(joystick, button)
    if current then current:joystickpressed(joystick, button) end
end

function Gamestate.joystickreleased(joystick, button)
    if current then current:joystickreleased(joystick, button) end
end

function Gamestate.focus(f)
    if current then current:focus(f) end
end

function Gamestate.quit()
    if current then current:quit() end
end

return Gamestate