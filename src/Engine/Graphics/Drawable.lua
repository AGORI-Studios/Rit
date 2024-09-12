local Drawable = Class:extend("Drawable")

function Drawable:new(x, y, w, h)
    -- a drawable is an object that rescales itself based on the screen size

    self.x = 0
    self.y = 0 
    self.width = 0
    self.height = 0
    self.baseWidth = 0
    self.baseHeight = 0
    self.scale = 1
end

function Drawable:draw()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Drawable:resize(w, h)
    -- base game is 1920x1080
    -- findn new width and height based on the screen size. FIxed width so we use math.min to find the scale
    -- DO NOT STRETCH
    local scale = math.min(w / 1920, h / 1080)
    self.width = self.baseWidth * scale
    self.height = self.baseHeight * scale
end

function Drawable:move(x, y)
    self.x = x
    self.y = y
end

function Drawable:scale(s)
    self.scale = s
end

return Drawable