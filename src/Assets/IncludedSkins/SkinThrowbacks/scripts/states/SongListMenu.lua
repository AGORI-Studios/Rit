local SongList = State:extend("SongList")

--[[
1: SongList
2: DifficultyList
]]
local currentMenuState = 1

function SongList:new()
    currentMenuState = 1
    State.new(self)

    self.bg = Sprite("Assets/Textures/Menu/PlayBG.png", 0, 0, true)
    self.bg.scalingType = ScalingTypes.WINDOW_LARGEST
    self.bg:resize(Game._windowWidth, Game._windowHeight)
    self.bg.zorder = -1
    self:add(self.bg)

    self.songInfo = SongInfoTab()
    self:add(self.songInfo)

    self.SongButtonGroup = TypedGroup(SongButton)
    self.SongButtonGroup.zorder = 1

    for _, song in pairs(SongManager:getSongList()) do
        local id = #self.SongButtonGroup.objects + 1
        local btn = SongButton(song)
        btn.zorder = id
        self.SongButtonGroup:add(btn)
        if not self.currentButton then
            self.currentButton = btn
        end
    end

    self.currentIndex = 1
    self.currentDiffIndex = 1

    self:add(self.SongButtonGroup)

    Header.zorder = 1000
    self:add(Header)
end

function SongList:updateSongList(dt)
    if Input:wasPressed("MenuDown") then
        self.currentIndex = self.currentIndex + 1
    elseif Input:wasPressed("MenuUp") then
        self.currentIndex = self.currentIndex - 1
    end

    self.currentIndex = math.clamp(self.currentIndex, 1, #self.SongButtonGroup.objects)
end

function SongList:updateDiffList(dt)
    if Input:wasPressed("MenuDown") then
        self.currentDiffIndex = self.currentDiffIndex + 1
    elseif Input:wasPressed("MenuUp") then
        self.currentDiffIndex = self.currentDiffIndex - 1
    end

    self.currentDiffIndex = math.clamp(self.currentDiffIndex, 1, #self.currentButton.children)
end

function SongList:update(dt)
    State.update(self, dt)

    for i, songButton in pairs(self.SongButtonGroup.objects) do
        songButton:updateYFromIndex(self.currentIndex, self.currentDiffIndex, dt)

        if i == self.currentIndex then
            self.songInfo:updateInfo(songButton.data)
        end
    end

    if currentMenuState == 1 then
        self:updateSongList(dt)
    else
        self:updateDiffList(dt)
    end

    if Input:wasPressed("MenuBack") then
        if currentMenuState == 1 then
            Game:SwitchState(Skin:getSkinnedState("TitleMenu"))
        else
            currentMenuState = 1
            for _, songBtn in pairs(self.SongButtonGroup.objects) do
                songBtn.hidden = false
                songBtn.showChildren = false
            end
        end
    end

    if Input:wasPressed("MenuConfirm") then
        if currentMenuState == 1 then
            currentMenuState = 2
            for _, songBtn in pairs(self.SongButtonGroup.objects) do
                songBtn.hidden = true
                songBtn.showChildren = false

                if songBtn.index == self.currentIndex then
                    songBtn.showChildren = true
                    self.currentButton = songBtn
                end
            end
        else
            --Game:SwitchState(Skin:getSkinnedState("Gameplay"))
            Game:SwitchState(States.Screens.Game, self.currentButton.children[self.currentDiffIndex].data)
        end
    end
end

function SongList:mousepressed(x, y, button, istouch, presses)
    State.mousepressed(self, x, y, button, istouch, presses)

    if Header:mousepressed(x, y, button, istouch, presses) then return end

    if currentMenuState == 1 then
        local didPress = false
        for _, songButton in pairs(self.SongButtonGroup.objects) do
            if songButton:checkCollision(x, y) then
                --self.currentIndex = songButton.index
                if songButton.index == self.currentIndex then
                    self.currentButton = songButton
                    self.currentButton.showChildren = true
                    currentMenuState = 2

                    -- HIDE ALL SONG BUTTONS
                    for _, songBtn in pairs(self.SongButtonGroup.objects) do
                        songBtn.hidden = true
                    end
                else
                    self.currentIndex = songButton.index
                end
            end
        end
    else
        for _, diffButton in pairs(self.currentButton.children) do
            if diffButton:checkCollision(x, y) then
                --self.currentDiffIndex = diffButton.index
                if diffButton.index == self.currentDiffIndex then
                    Game:SwitchState(States.Screens.Game, diffButton.data)
                else
                    self.currentDiffIndex = diffButton.index
                end
            end
        end
    end
end

function SongList:wheelmoved(x, y)
    State.wheelmoved(self, x, y)

    if currentMenuState == 1 then
        if y > 0 then
            self.currentIndex = self.currentIndex - 1
        elseif y < 0 then
            self.currentIndex = self.currentIndex + 1
        end

        if x > 0 then
            self.currentIndex = self.currentIndex - 3
        elseif x < 0 then
            self.currentIndex = self.currentIndex + 3
        end
        self.currentIndex = math.clamp(self.currentIndex, 1, #self.SongButtonGroup.objects)
    else
        if y > 0 then
            self.currentDiffIndex = self.currentDiffIndex - 1
        elseif y < 0 then
            self.currentDiffIndex = self.currentDiffIndex + 1
        end

        if x > 0 then
            self.currentDiffIndex = self.currentDiffIndex - 3
        elseif x < 0 then
            self.currentDiffIndex = self.currentDiffIndex + 3
        end
        self.currentDiffIndex = math.clamp(self.currentDiffIndex, 1, #self.currentButton.children)
    end
end

return SongList
