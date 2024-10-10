local Icon = Sprite:extend("Icon")

function Icon:new(type, x, y)
    local path = "Assets/Textures/Menu/Icons/" .. type .. ".png"
    Sprite.new(self, path, x, y, false)
end

return Icon