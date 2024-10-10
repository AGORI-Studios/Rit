local SongButton = Sprite:extend("SongButton")

function SongButton:new(songData)
    self.data = songData
    self.title = songData.title
    self.artist = songData.artist
    self.index = songData.index

    self.children = {}
    self.showChildren = false
    self.lerpedDrawY = 0
    self.lastDrawY = 0

    for _, diff in pairs(songData.difficulties) do
        table.insert(self.children, DiffButton(diff, self))
    end

    table.sort(self.children, function(a, b) return a.index < b.index end)

    self.textObj = Text(self.title, 0, 0, 20, {1, 1, 1, 1}, nil, nil, nil, nil, true, 1920)
    self.leBar = Sprite("Assets/Textures/Menu/SongTagSelectedBar.png", 0, 0, true)

    Sprite.new(self, "Assets/Textures/Menu/SongTag.png", 0, 0, true)
    self.drawY = Game._windowHeight/2 + self.index * (self.height+20) - self.height/2
    self.lastDrawY = self.drawY

    self.leBar.drawY = Game._windowHeight/2 + self.index * (self.height+20) + self.height-self.leBar.height
    self.leBar.lastDrawY = self.drawY
    self.leBar.scale.y = 0.75

    self.drawX = 0
    self.lerpedDrawX = 0
    self.lastDrawX = 0

    self.hidden = false
end

function SongButton:update(dt)
    Sprite.update(self, dt)
    self.leBar:update(dt)
    self.textObj:update(dt)

    if not self.showChildren then return end
    for _, child in pairs(self.children) do
        child:update(dt)
    end
    
end

function SongButton:resize(w, h)
    Sprite.resize(self, w, h)

    for _, child in pairs(self.children) do
        child:resize(w, h)
    end
    self.leBar:resize(w, h)
    self.textObj:resize(w, h)
end

function SongButton:updateYFromIndex(index, diffIndex, dt)
    self.lerpedDrawY = Game._windowHeight/2 + (self.index - index) * (self.height+20) - self.height/2

    self.drawY = math.fpsLerp(self.lastDrawY, self.lerpedDrawY, 15, dt)
    self.lastDrawY = self.drawY

    self.leBar.lerpedDrawY = self.lerpedDrawY + self.height - self.leBar.height * 0.75
    self.leBar.drawY = math.fpsLerp(self.leBar.lastDrawY, self.leBar.lerpedDrawY, 15, dt)
    self.leBar.lastDrawY = self.leBar.drawY

    if self.hidden then
        --lerp x to -self.baseWidth 
        self.lerpedDrawX = -self.baseWidth
        self.drawX = math.fpsLerp(self.lastDrawX, self.lerpedDrawX, 15, dt)
        self.leBar.drawX = self.drawX
        self.lastDrawX = self.drawX
    else
        -- lerp x to 0
        self.lerpedDrawX = 0
        self.drawX = math.fpsLerp(self.lastDrawX, self.lerpedDrawX, 15, dt)
        self.leBar.drawX = self.drawX
        self.lastDrawX = self.drawX
    end

    self.textObj.drawX = self.drawX + 20 * self.textObj.windowScale.x
    self.textObj.drawY = self.drawY + 20 * self.textObj.windowScale.y

    if self.index == index then
        self.colour[1], self.colour[2], self.colour[3] = 1, 1, 1
    else
        self.colour[1], self.colour[2], self.colour[3] = 0.5, 0.5, 0.5
    end

    if not self.showChildren then return end
    for _, child in pairs(self.children) do
        child:updateYFromIndex(diffIndex, dt)
    end
end

function SongButton:draw()
    self.leBar:draw()
    Sprite.draw(self)
    --[[ love.graphics.printWithTrimmed(self.title, self.drawX + 20, self.drawY + 20, 300) ]]
    -- draw trimmed text scaled with the window in aspect fixed mode
    --love.graphics.printWithTrimmed(self.title, self.drawX + 20, self.drawY + 20, 300)
    self.textObj:draw()

    if not self.showChildren then return end
    for _, child in pairs(self.children) do
        child:draw(child)
    end
end

return SongButton
