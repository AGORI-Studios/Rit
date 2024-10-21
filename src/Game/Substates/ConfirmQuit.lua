local ConfirmQuit = State:extend("ConfirmQuit")
ConfirmQuit.confirmed = false

function ConfirmQuit:new()
    State.new(self)
    self.box = Drawable(400, 300, 1120, 480)
    self.box.rounding = 25
    self.box.colour = {0.1, 0.1, 0.1, 0.75}

    self.confirmButton = Button(640, 420, 640, 240, "Confirm", nil, 48, {0.1, 0.1, 0.1, 1}, {0.2, 0.2, 0.2, 1}, {0.3, 0.3, 0.3, 1}, {1, 1, 1, 1}, 25)
    self.confirmButton.onClick = function()
        ConfirmQuit.confirmed = true
        Game:popState()
    end

    self:add(self.box)
    self:add(self.confirmButton)
end

function ConfirmQuit:mousepressed(x, y, button)
    if self:checkCollision(x, y) then
        return true
    end

    return false
end

function ConfirmQuit:mousemoved(x, y, dx, dy)
    if self:checkCollision(x, y) then
        return true
    end

    return false
end

function ConfirmQuit:checkCollision(x, y)
    return self.box:checkCollision(x, y)
end

return ConfirmQuit