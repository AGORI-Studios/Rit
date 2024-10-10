local Header = Sprite:extend("Header")

function Header:new() -- Only 1 instance of this object will exist
    self.group = Group()

    Sprite.new(self, "Assets/Textures/Menu/MenuBar.png", 0, 0)

    local gearIcon = Icon("Gear", 5, 10)
    local homeIcon = Icon("Home", 15 + gearIcon.baseWidth, 10)
    local barLineIcon = Icon("BarLine", 15 + gearIcon.baseWidth*2, 10)
    local importIcon = Icon("Import", 1920-gearIcon.baseWidth*2-15, 10)
    local barsIcon = Icon("Bars", 1920-gearIcon.baseWidth-5, 10)

    self.group:add(gearIcon)
    self.group:add(homeIcon)
    self.group:add(barLineIcon)
    self.group:add(importIcon)
    self.group:add(barsIcon)
end

function Header:update(dt)
    Sprite.update(self, dt)

    self.group:update(dt)
end

function Header:resize(w, h)
    Sprite.resize(self, w, h)

    self.group:resize(w, h)
end

function Header:draw()
    Sprite.draw(self)

    self.group:draw()
end

return Header