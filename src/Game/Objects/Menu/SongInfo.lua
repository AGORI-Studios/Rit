local SongInfo = Group:extend("SongInfo")

function SongInfo:new()
    Group.new(self)
    
    self.playTab = Sprite("Assets/Textures/Menu/PlayTab.png", 0, 0, true)
    self.playTab.zorder = 0
    self.playTab.scalingType = ScalingTypes.STRETCH_Y
    self.playTab.x = 1120
    self.playTab.y = 0

    self:add(self.playTab)

    self.songTitle = Text("", 1170, 120, nil, nil, Game.fonts["menuExtraBoldX3"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 550)
    self.artist = Text("", 1170, 200, nil, nil, Game.fonts["menuExtraBoldX2"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 400)
    self.mapper = Text("", 1170, 260, nil, nil, Game.fonts["defaultBoldX2"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 400)
    self.desc = Text("", 1120, 350, nil, nil, Game.fonts["NatsRegular26"], false, nil, Skin:getSkinnedState("SongListMenu"), false)

    self:add(self.songTitle)
    self:add(self.artist)
    self:add(self.mapper)
    self:add(self.desc)
end

function SongInfo:update(dt)
    Group.update(self, dt)
end

function SongInfo:resize(w, h)
    Group.resize(self, w, h)    
end

function SongInfo:updateInfo(data)
    self.songTitle.text = data.title
    self.artist.text = "By " .. (data.artist or "Unknown")
    self.mapper.text = "Mapped by " .. (data.creator or "Unknown")
    self.desc.text = data.desc or ""
end

return SongInfo