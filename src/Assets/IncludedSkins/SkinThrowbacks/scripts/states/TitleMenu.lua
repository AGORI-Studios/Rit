local TitleMenu = State:extend("TitleMenu")

local curLogoScale = 0.65
local bpm = 100 -- to be determined when we have a song lol
local curBeat = 0
local beatTime = 60 / bpm

function TitleMenu:new()
    State.new(self)

    self.bg = Sprite("Assets/Textures/Menu/PlayBG.png", 0, 0, true)
    self.bg.scalingType = ScalingTypes.WINDOW_STRETCH
    self.bg:resize(Game._windowWidth, Game._windowHeight)
    self.bg.zorder = -1
    self:add(self.bg)

    self.logo = VertexSprite("Assets/Textures/Menu/Logo.png", 50, 150, 4)
    self.logo:centerOrigin()
    self.logo:setScale(curLogoScale, curLogoScale)
    self.logo.zorder = 1

    self:add(self.logo)

    self.buttonsGroup = TypedGroup(TitleButton)
    self.buttonsGroup.zorder = 2
    self:add(self.buttonsGroup)

    self.playButton = TitleButton("Assets/Textures/Menu/Buttons/PlayBtn.png", "Assets/Textures/Menu/Buttons/BigBtnBorder.png", 1250, 300, function()
        Game:SwitchState(Skin:getSkinnedState("SongListMenu"))
    end)
    self.playButton:setScale(1.35, 1.35)
    self.ohButton = TitleButton("Assets/Textures/Menu/Buttons/OhBtn.png", "Assets/Textures/Menu/Buttons/BigBtnBorder.png", 1550, 300, function()
        print("Online Hub is not currently implemented")
    end)
    self.ohButton:setScale(1.35, 1.35)

    self.buttonsGroup:add(self.playButton)
    self.buttonsGroup:add(self.ohButton)
end

function TitleMenu:update(dt)
    State.update(self, dt)

    curBeat = curBeat + dt
    if curBeat >= beatTime then
        curBeat = 0
        curLogoScale = 0.7
    end
    self.logo:setScale(curLogoScale, curLogoScale)

    if curLogoScale > 0.65 then
        curLogoScale = math.fpsLerp(curLogoScale, 0.65, 5, dt)
    end
end

function TitleMenu:mousemoved(x, y, dx, dy, istouch)
    State.mousemoved(self, x, y, dx, dy, istouch)
end

return TitleMenu