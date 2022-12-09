--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2022 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

local state = {}
local current, to, pre = nil, nil, nil

function state.switch(to, ...)
    assert(to, "Missing argument: state to switch to")
    pre = current
    if pre then pre:leave(to) end
    current = to
    to:init(pre, ...)
    to:enter(pre, ...)
end

function state.update(dt)
    if current then current:update(dt) end
end

function state.draw()
    if current then current:draw() end
end

function state.keypressed(key, unicode)
    if current.keypressed then current:keypressed(key, unicode) end
end

function state.keyreleased(key)
    if current.keyreleased then current:keyreleased(key) end
end

function state.textinput(text)
    if current.textinput then current:textinput(text) end
end

function state.mousepressed(x, y, button)
    if current.mousepressed then current:mousepressed(x, y, button) end
end

function state.mousereleased(x, y, button)
    if current.mousereleased then current:mousereleased(x, y, button) end
end

function state.joystickpressed(joystick, button)
    if current.joystickpressed then current:joystickpressed(joystick, button) end
end

function state.joystickreleased(joystick, button)
    if current.joystickreleased then current:joystickreleased(joystick, button) end
end

function state.focus(f)
    if current.focus then current:focus(f) end
end

function state.quit()
    if current.quit then current:quit() end
end

return state