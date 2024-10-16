local SongInfo = Group:extend("SongInfo")

function SongInfo:new()
    Group.new(self)
    
    self.playTab = Sprite("Assets/Textures/Menu/PlayTab.png", 0, 0, true)
    self.playTab.zorder = -1000
    self.playTab.scalingType = ScalingTypes.STRETCH_Y
    self.playTab.x = 1120
    self.playTab.y = 0

    self:add(self.playTab)

    self.songTitle = Text("", 1170, 120, nil, nil, Game.fonts["menuExtraBoldX3"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 550)
    self.artist = Text("", 1170, 200, nil, {200/255, 80/255, 104/255, 1}, Game.fonts["menuExtraBoldX2"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 400)
    self.mapper = Text("", 1170, 260, nil, {200/255, 80/255, 104/255, 1}, Game.fonts["defaultBoldX2"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 400)
    self.desc = Text("", 1205, 800, nil, nil, Game.fonts["NatsRegular26"], false, nil, Skin:getSkinnedState("SongListMenu"), false, Game.fonts["NatsRegular26"]:getWidth("Hi this is testing a \"very long\" description in rit to see how it displays. Look off? Please report it. Description's should look no longer than this."), true)
    self.desc.zorder = 101
    self.diffDisplay = Text("", 1660, 375, nil, nil, Game.fonts["NatsRegular26"], false, nil, Skin:getSkinnedState("SongListMenu"), true, 200)
    self.diffDisplay.visible = false

    self.pictureShadow = Drawable(1755, 120, 125, 125)
    self.pictureShadow.colour = {128/255, 34/255, 88/255}
    self.pictureShadow.alpha = 0.3
    self.pictureShadow.rounding = 10
    self:add(self.pictureShadow)

    self.infoBox = Drawable(1655, 370, 215, 395)
    self.infoBox.colour = {0, 0, 0}
    self.infoBox.alpha = 0.15
    self.infoBox.rounding = 10
    self:add(self.infoBox)

    self.descBox = Drawable(1190, 790, 700, 225)
    self.descBox.colour = {0, 0, 0}
    self.descBox.alpha = 0.6
    self.descBox.rounding = 25
    self.descBox.zorder = 100
    self:add(self.descBox)

    self.currentDiffData = {}
    
    self.seperator = Drawable(1170, self.mapper.y+75, 700, 2)
    self.seperator.alpha = 0.2
    self:add(self.seperator)

    self:add(self.songTitle)
    self:add(self.artist)
    self:add(self.mapper)
    self:add(self.desc)
    self:add(self.diffDisplay)
end

function SongInfo:update(dt)
    Group.update(self, dt)
end

function SongInfo:resize(w, h)
    Group.resize(self, w, h)

    local x = self.playTab.drawX
    local xWithWidth = x + self.playTab.width
    local offScreen = xWithWidth - w
    local newWidth = self.playTab.baseWidth - offScreen
    self.playTab.width = newWidth
    self.playTab.windowScale.x = newWidth / self.playTab.baseWidth
    self.playTab.windowScale.y = h / self.playTab.baseHeight
end

function SongInfo:updateInfo(data)
    self.songTitle.text = data.title
    self.artist.text = Locale("By ") .. (data.artist or Locale("Unknown"))
    self.mapper.text = Locale("Mapped by ") .. (data.creator or Locale("Unknown"))
    self.desc.text = data.desc or Locale("This map has no description.")
end

function SongInfo:updateDiffData(data)
    self.currentDiffData = data
    self.diffDisplay.text = "NPS: " .. string.format("%.2f", data.nps) .. "\nDifficulty: " .. string.format("%.2f", data.difficulty)
end

function SongInfo:toggleDiffDisplay()
    self.diffDisplay.visible = not self.diffDisplay.visible
end

return SongInfo