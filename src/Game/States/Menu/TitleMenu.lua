local TitleMenu = State:extend("TitleMenu")

local curLogoScale = 0.75
local bpm = 100 -- to be determined when we have a song lol
local curBeat = 0
local beatTime = 60 / bpm

function TitleMenu:new()
    State.new(self)

    self.bg = Sprite("Assets/Textures/Menu/PlayBG.png", 0, 0)
    self.bg.scalingType = ScalingTypes.WINDOW_STRETCH
    self.bg:resize(Game._windowWidth, Game._windowHeight)
    self:add(self.bg)

    self.logo = Sprite("Assets/Textures/Menu/Logo.png", 100, 200)
    self.logo:centerOrigin()
    self.logo:setScale(curLogoScale, curLogoScale)
    self:add(self.logo)
end

function TitleMenu:update(dt)
    State.update(self, dt)

    curBeat = curBeat + dt
    if curBeat >= beatTime then
        curBeat = 0
        curLogoScale = 0.8
    end
    self.logo:setScale(curLogoScale, curLogoScale)

    if curLogoScale > 0.75 then
        curLogoScale = math.fpsLerp(curLogoScale, 0.75, 5, dt)
    end
end

return TitleMenu