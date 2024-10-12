local Underlay = Drawable:extend("Underlay")

function Underlay:new(receptorCount)
    self.count = receptorCount

    Drawable.new(self, 0, 0, 200*receptorCount, 1080*5) -- lol
    self.colour = {0, 0, 0}

    self.x = 1920/2 - self.baseWidth/2
end

function Underlay:updateCount(count)
    self.count = count
    self.baseWidth = 200*count
    self.width = (200*count) * self.windowScale.x
    self.baseHeight = 3000
    self.height = 3000 * self.windowScale.y

    self.x = 1920/2 - self.baseWidth/2
end

return Underlay