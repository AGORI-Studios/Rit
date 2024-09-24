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
    self.bg.scalingType = ScalingTypes.WINDOW_STRETCH
    self.bg:resize(Game._windowWidth, Game._windowHeight)
    self.bg.zorder = -1
    self:add(self.bg)

    self.playTab = Sprite("Assets/Textures/Menu/PlayTab.png", 0, 0, true)
    self.playTab.zorder = 0
    self.playTab.scalingType = ScalingTypes.STRETCH_Y
    self.playTab.x = 1120
    self.playTab.y = 0
    self:add(self.playTab)

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

    for _, songButton in pairs(self.SongButtonGroup.objects) do
        songButton:updateYFromIndex(self.currentIndex, self.currentDiffIndex, dt)
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

return SongList
