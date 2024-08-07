---@diagnostic disable: inject-field, duplicate-set-field, undefined-global
local HitObject = VertSprite:extend()

HitObject.time = 0
HitObject.data = 1
HitObject.canBeHit = false
HitObject.tooLate = false
HitObject.wasGoodHit = false

HitObject.moveWithScroll = true

function HitObject:new(time, data, endTime) 
    self.super.new(self, 0, 0, 0)

    self.moves = false

    self.x = states.game.Gameplay.strumX + (200) * (data-1)
    self.x = self.x + 25
    self.y = -2000

    self.time = time / Modifiers.Rate
    self.endTime = Modifiers.NLN == false and ((endTime or -1) / Modifiers.Rate) or -1
    self.data = data

    self.visible = true

    self.moveWithScroll = true

    self:load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. ".png"))

    self.forcedDimensions = true
    self.dimensions = {width = 200, height = 200}
    self:updateHitbox()
    self:centerOrigin()
    _G.__NOTE_OBJECT_WIDTH = 200

    self.x = self.x + (200) * (data-1)

    self.hitsound = ""

    if self.endTime and self.endTime > self.time then
        self.children = {}
        local holdObj = VertSprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-hold.png"))
        holdObj.endTime = self.endTime
        holdObj.length = self.endTime - self.time -- hold time
        holdObj:updateHitbox()
        holdObj.x = self.x
        holdObj.forcedDimensions = true
        holdObj.dimensions = {width = 200, height = 200}
        holdObj.parent = self

        table.insert(self.children, holdObj)

        local endObj = VertSprite():load(skin:format("notes/" .. tostring(states.game.Gameplay.mode) .. "K/note" .. data .. "-end.png"))
        holdObj.endTime = self.endTime
        endObj:updateHitbox()
        endObj.x = self.x

        endObj.forcedDimensions = true
        endObj.dimensions = {width = 200, height = 100}
        endObj.flipY = Modscript.downscroll == false
        endObj.parent = self

        endObj.hold = holdObj
        holdObj.endObj = endObj

        self.endObj = endObj

        table.insert(self.children, endObj)
    end

    self.type = 1

    return self
end

function HitObject:onHit()
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

function HitObject:update(dt)
    self.super.update(self, dt)

    self.canBeHit = self.time > musicTime - safeZoneOffset and self.time < musicTime + safeZoneOffset
    if self.time < musicTime - safeZoneOffset and not self.wasGoodHit then
        self.tooLate = true
    end
    
    if self.tooLate then
        self.alpha = 0.5
    end
end

function HitObject:draw(scale)
    if not self.visible then return end
    
    if self.y < 1080/scale and self.y > -400 / scale then
        if self.children then
            for _, child in ipairs(self.children) do
                child:draw()
            end
        end
        self.super.draw(self)
    end
end

return HitObject