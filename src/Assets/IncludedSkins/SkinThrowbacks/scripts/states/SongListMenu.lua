local SongList = State:extend("SongList")

--[[
CurrentMenuState -
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
    self.searchInput = ""
    self.searchTyping = false

    for _, song in pairs(SongManager:getSongList()) do
        local id = #self.SongButtonGroup.objects + 1
        local btn = SongButton(song)
        btn.zorder = id
        self.SongButtonGroup:add(btn)
        if not self.currentButton then
            self.currentButton = btn
        end
    end

    SearchManager:init(self.SongButtonGroup.objects)

    self.searchTab = Sprite("Assets/Textures/Menu/SearchCatTab.png", 0, 100)
    self.searchTab.zorder = 100
    self:add(self.searchTab)

    self.searchInputText = Text("Search", 30, 110, nil, nil, Game.fonts["menuBold"], nil, nil, nil, nil, nil)
    self.searchInputText.colour[4] = 0.5
    self.searchInputText.zorder = 101
    self:add(self.searchInputText)

    self.currentIndex = 1
    self.currentDiffIndex = 1

    self:add(self.SongButtonGroup)

    Header.zorder = 1000
    self:add(Header)
    love.keyboard.setKeyRepeat(true)
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
        if not self.searchInput then
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
                Game:SwitchState(States.Screens.Game, self.currentButton.children[self.currentDiffIndex].data)
            end
        else
            self.SongButtonGroup.objects = {}
            for _, btn in ipairs(SearchManager:doSearch(self.searchInput)) do
                self.SongButtonGroup:add(btn)
            end
            self.searchTyping = false
        end
            
    end

    if Input:wasPressed("MenuSearch") then
        self.searchTyping = not self.searchTyping
    end
end

local utf8 = require("utf8")
function SongList:keypressed(k)
    if k == "backspace" and self.searchTyping then
        local byteoffset = utf8.offset(self.searchInput, -1)

        if byteoffset then
            self.searchInput = string.sub(self.searchInput, 1, byteoffset - 1)
        end

        if #self.searchInput > 0 then
            self.searchInputText.text = self.searchInput
            self.searchInputText.colour[4] = 1
        else
            self.searchInputText.text = "Search"
            self.searchInputText.colour[4] = 0.5
        end
    end
end

function SongList:textinput(t)
    if t == "\\" then return end

    if self.searchTyping then
        self.searchInput = self.searchInput .. t
    end

    if #self.searchInput > 0 then
        self.searchInputText.text = self.searchInput
        self.searchInputText.colour[4] = 1
    else
        self.searchInputText.text = "Search"
        self.searchInputText.colour[4] = 0.5
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
