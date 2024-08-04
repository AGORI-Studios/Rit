---@diagnostic disable: inject-field, duplicate-set-field, undefined-global
local CatchObject = Object:extend()

CatchObject.time = 0
CatchObject.data = 1
CatchObject.canBeHit = false
CatchObject.tooLate = false
CatchObject.wasGoodHit = false

CatchObject.offsetX = 0
CatchObject.offsetY = 0

function CatchObject:new(time, data) 
    self.super.new(self, 0, 0, 0)

    self.moves = false

    self.x = states.game.Gameplay.strumX + (200) * (data-1)
    self.x = self.x + 25
    self.y = -2000

    self.time = time / Modifiers.Rate
    self.data = data

    self.visible = true

    self.children = {}
    self.moveWithScroll = true

    self.forcedDimensions = true
    self.dimensions = {width = 200, height = 20}
    _G.__NOTE_OBJECT_WIDTH = 200

    self.x = self.x + (200) * (data-1)

    self.hitsound = ""

    self.x = self.x + self.offsetX

    self.type = 2

    return self
end

function CatchObject:onHit()
    local gameplayState = states.game.Gameplay
    local foundSound = false

    if self.hitsound:find("Whistle") then
        foundSound = true
        local clone = gameplayState.hitsounds["Whistle"]:clone()
        clone:setVolume((Settings.options["Audio"].hitsound/100) * skinData.Miscellaneous.hitsoundVolume)
        clone:play()
        clone:release()
    end
    if self.hitsound:find("Finish") then
        foundSound = true
        local clone = gameplayState.hitsounds["Finish"]:clone()
        clone:setVolume((Settings.options["Audio"].hitsound/100) * skinData.Miscellaneous.hitsoundVolume)
        clone:play()
        clone:release()
    end
    if self.hitsound:find("Clap") then
        foundSound = true
        local clone = gameplayState.hitsounds["Clap"]:clone()
        clone:setVolume((Settings.options["Audio"].hitsound/100) * skinData.Miscellaneous.hitsoundVolume)
        clone:play()
        clone:release()
    end

    if not foundSound then
        local clone = gameplayState.hitsounds["Default"]:clone()
        clone:setVolume((Settings.options["Audio"].hitsound/100) * skinData.Miscellaneous.hitsoundVolume)
        clone:play()
        clone:release()
    end
end

function CatchObject:update(dt)
    self.canBeHit = self.time > musicTime - safeZoneOffset and self.time < musicTime + safeZoneOffset
    if self.time < musicTime - safeZoneOffset and not self.wasGoodHit then
        self.tooLate = true
    end
    
    if self.tooLate then
        self.alpha = 0.5
    end
end

function CatchObject:draw(scale)
    if not self.visible then return end
    
    if self.y < 1080/scale and self.y > -400 / scale then
        local lastColor = {love.graphics.getColor()}
        love.graphics.setColor(1, 204/255, 0, self.alpha)
        love.graphics.rectangle("fill", self.x, self.y+110, 200, 20)
        love.graphics.setColor(lastColor)
    end
end

return CatchObject