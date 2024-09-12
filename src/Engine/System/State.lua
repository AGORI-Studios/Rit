local State = Group:extend("State")

function State:new()
    Group.new(self)
end

function State:update(dt)
    Group.update(self, dt)
end

function State:draw()
    Group.draw(self)
end

function State:keypressed(key, scancode, isrepeat)
    Group.keypressed(self, key, scancode, isrepeat)
end

function State:keyreleased(key, scancode)
    Group.keyreleased(self, key, scancode)
end

function State:resize(w, h)
    Group.resize(self, w, h)
end

function State:mousereleased(x, y, button, istouch, presses)
    Group.mousereleased(self, x, y, button, istouch, presses)
end

function State:mousepressed(x, y, button, istouch, presses)
    Group.mousepressed(self, x, y, button, istouch, presses)
end

function State:mousemoved(x, y, dx, dy, istouch)
    Group.mousemoved(self, x, y, dx, dy, istouch)
end

function State:kill()
    Group.kill(self)
end

return State