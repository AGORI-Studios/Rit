local BaseModifier = Object:extend()
BaseModifier.enabled = false

function BaseModifier:enable(...)
    self.enabled = true
end

function BaseModifier:disable(...)
    self.enabled = false
end

function BaseModifier:update(dt, ...)
end

return BaseModifier