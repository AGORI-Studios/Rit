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

function State:kill()
    Group.kill(self)
end

return State