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

    self.unhoveredTextObj = Text(self.title, 0, 0, 20, {1, 1, 1, 1}, Game.fonts["menuExtraBoldX3"], nil, nil, nil, true, 600)
    self.textObj = Text(self.title, 0, 0, 20, {1, 1, 1, 1}, Game.fonts["menuExtraBoldX2"], nil, nil, nil, true, 600)
    self.leBar = Sprite("Assets/Textures/Menu/SongTagSelectedBar.png", 0, 0, true)
    self.artistText = Text("By " .. self.artist, 0, 0, 20, {200/255, 80/255, 104/255, 1}, Game.fonts["menuExtraBoldX1.5"], nil, nil, nil, true, 370)

    self.difficultyBars = TypedGroup(Drawable)
    self.showPlus = false
    for i = 1, #self.children do
        if i > 6 then
            self.showPlus = true
            break
        end
        local bar = Drawable(0, 0, 10, 35)
        bar.roundingX = 25
        bar.roundingY = 5
        self.difficultyBars:add(bar)
    end
    if self.showPlus then
        self.plusText = Text("+", 0, 0, 20, {1, 1, 1, 1}, Game.fonts["menuExtraBoldX1.5"], nil, nil, nil, true, 400)
    end
    self.difficultyText = Text(#self.difficultyBars.objects .. " Difficult" .. (#self.difficultyBars.objects == 1 and "y" or "ies"), 0, 0, 20, {200/255, 80/255, 104/255, 1}, Game.fonts["menuBoldX1.5"], nil, nil, nil, true, 400)
    self.difficultyText.shear.x = -0.3

    Sprite.new(self, "Assets/Textures/Menu/SongTag.png", 0, 0, true)
    self.drawY = Game._windowHeight/2 + self.index * (self.height+20) - self.height/2
    self.lastDrawY = self.drawY

    self.leBar.drawY = Game._windowHeight/2 + self.index * (self.height+20) + self.height-self.leBar.height
    self.leBar.lastDrawY = self.drawY
    self.leBar.scale.y = 0.75

    self.drawX = 0
    self.lerpedDrawX = 0
    self.lastDrawX = 0

    self.targetX = 0

    self.hidden = false
end

function SongButton:update(dt)
    Sprite.update(self, dt)
    self.leBar:update(dt)
    self.unhoveredTextObj:update(dt)
    self.textObj:update(dt)
    self.artistText:update(dt)
    self.difficultyBars:update(dt)
    self.difficultyText:update(dt)

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
    self.unhoveredTextObj:resize(w, h)
    self.textObj:resize(w, h)
    self.artistText:resize(w, h)
    self.difficultyBars:resize(w, h)
    if self.showPlus then
        self.plusText:resize(w, h)
    end
    self.difficultyText:resize(w, h)
end

function SongButton:updateYFromIndex(index, diffIndex, dt)
    self.lerpedDrawY = Game._windowHeight/2 + (self.index - index) * (self.height+20) - self.height/2

    self.drawY = math.fpsLerp(self.lastDrawY, self.lerpedDrawY, 15, dt)
    self.lastDrawY = self.drawY

    self.leBar.lerpedDrawY = self.lerpedDrawY + self.height - self.leBar.height * 0.75
    self.leBar.drawY = math.fpsLerp(self.leBar.lastDrawY, self.leBar.lerpedDrawY, 15, dt)
    self.leBar.lastDrawY = self.leBar.drawY

    if self.index == index then
        self.colour[1], self.colour[2], self.colour[3] = 1, 1, 1
        self.targetX = 0
    else
        self.colour[1], self.colour[2], self.colour[3] = 0.5, 0.5, 0.5
        --self.targetX = -25
        -- wheel-like effect based off current index and this index
        self.targetX = -35 * math.abs(index - self.index)
    end

    if self.hidden then
        --lerp x to -self.baseWidth 
        self.lerpedDrawX = -self.baseWidth
        self.drawX = math.fpsLerp(self.lastDrawX, self.lerpedDrawX, 15, dt)
        self.leBar.drawX = self.drawX
        self.lastDrawX = self.drawX
    else
        -- lerp x to 0
        self.lerpedDrawX = self.targetX
        self.drawX = math.fpsLerp(self.lastDrawX, self.lerpedDrawX, 15, dt)
        self.leBar.drawX = self.drawX
        self.lastDrawX = self.drawX
    end

    self.unhoveredTextObj.drawX = self.drawX + 20 * self.unhoveredTextObj.windowScale.x
    self.unhoveredTextObj.drawY = self.drawY + 20 * self.unhoveredTextObj.windowScale.y
    self.textObj.drawX = self.drawX + 15 * self.textObj.windowScale.x
    self.textObj.drawY = self.drawY + 5 * self.textObj.windowScale.y
    self.artistText.drawX = self.drawX + 15 * self.artistText.windowScale.x
    self.artistText.drawY = self.drawY + 70 * self.artistText.windowScale.y

    for i, bar in ipairs(self.difficultyBars.objects) do
        bar.drawY = self.artistText.drawY + 3
        bar.drawX = (self.artistText.drawX + self.artistText:getTextWidth() + 20 + 15 * i) * bar.windowScale.x
    end

    local last = self.difficultyBars.objects[#self.difficultyBars.objects]

    if self.showPlus then
        -- plusText goes directly after the last bar
        self.plusText.drawX = last.drawX+7
        self.plusText.drawY = last.drawY-3
    end

    self.difficultyText.drawX = last.drawX + last.width*2+10
    self.difficultyText.drawY = last.drawY-3

    if not self.showChildren then return end
    for _, child in pairs(self.children) do
        child:updateYFromIndex(diffIndex, dt)
    end
end

function SongButton:checkCollision(x, y)
    return x < self.drawX + self.width and
           self.drawX < x + 1 and
           y < self.drawY + self.height and
           self.drawY < y + 1
end

function SongButton:draw()
    -- if not on screen, RETURN !
    if self.drawY+self.height < 0 or self.drawY>Game._windowHeight then
        return
    end
    self.leBar:draw()
    Sprite.draw(self)
    --[[ love.graphics.printWithTrimmed(self.title, self.drawX + 20, self.drawY + 20, 300) ]]
    -- draw trimmed text scaled with the window in aspect fixed mode
    --love.graphics.printWithTrimmed(self.title, self.drawX + 20, self.drawY + 20, 300)
    if self.colour[1] == 1 then
        self.textObj:draw()
        self.artistText:draw()
        self.difficultyBars:draw()
        if self.showPlus then
            self.plusText:draw()
        end
        self.difficultyText:draw()
    else
        self.unhoveredTextObj:draw()
    end

    if not self.showChildren then return end
    for _, child in pairs(self.children) do
        child:draw(child)
    end
end

return SongButton
