local MSFuncs = {}
MSFuncs.sprites = {}

function MSFuncs:createSprite(name, path, x, y)
    local spr = Sprite(x, y, path)
    spr.name = name
    spr.drawWithoutRes = false -- draws within push handling
    self.sprites[name] = spr
    --table.insert(self.sprites, spr)
    return spr
end

function MSFuncs:setSpriteProperty(name, property, value)
    if self.sprites[name] then
        self.sprites[name][property] = value
    end
end

function MSFuncs:getSpriteProperty(name, property)
    if self.sprites[name] then
        return self.sprites[name][property]
    end
end

function MSFuncs:removeSprite(name)
    if self.sprites[name] then
        self.sprites[name] = nil
    end
end

return MSFuncs