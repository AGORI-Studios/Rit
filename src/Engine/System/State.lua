local State = Group:extend("State")

function State:new()
    Group.new(self)
end

function State:kill()
    Group.kill(self)
end

return State