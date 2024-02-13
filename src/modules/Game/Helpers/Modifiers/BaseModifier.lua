local BaseModifier = Object:extend()
BaseModifier.enabled = false

-- Our base modifier class. 
-- ! This is not meant to be used directly, but to be extended by other modifiers.

function BaseModifier:enable(...)
    self.enabled = true
end

function BaseModifier:disable(...)
    self.enabled = false
end

function BaseModifier:update(dt, ...)
end

return BaseModifier