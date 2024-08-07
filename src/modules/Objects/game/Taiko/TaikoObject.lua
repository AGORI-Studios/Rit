---@diagnostic disable: inject-field, duplicate-set-field, undefined-global
local TaikoObject = VertSprite:extend()

TaikoObject.time = 0
TaikoObject.data = 1
TaikoObject.canBeHit = false
TaikoObject.tooLate = false
TaikoObject.wasGoodHit = false

TaikoObject.children = {}
TaikoObject.moveWithScroll = true

function TaikoObject:new(time, type, isBig)
    self.super.new(self, 0, 0, 0)
    self.moves = false

    self.x = 3000
    self.y = 225

    self.time = time / Modifiers.Rate
    self.data = type

    self.visible = true

    self.children = {}
    self.moveWithScroll = true

    self.setColour = skinData.Taiko.useCustomColour
    self.colour = {255, 255, 255}

    self.isBig = isBig

    if self.isBig then
        if self.data-2 == 1 then
            -- don (big)
            if self.setColour then
                self:load(skin:format("taiko/taikobigcircle.png"))
                self.colour = skinData.Taiko.donColour
            else
                self:load(skin:format("taiko/taikobigcircle-don.png"))
            end
        elseif self.data-2 == 2 then
            -- kat (big)
            if self.setColour then
                self:load(skin:format("taiko/taikobigcircle.png"))
                self.colour = skinData.Taiko.katColour
            else
                self:load(skin:format("taiko/taikobigcircle-kat.png"))
            end
        end
    else
        if self.data == 1 then
            -- don
            if self.setColour then
                self:load(skin:format("taiko/taikohitcircle.png"))
                self.colour = skinData.Taiko.donColour
            else
                self:load(skin:format("taiko/taikohitcircle-don.png"))
            end
        elseif self.data == 2 then
            -- kat
            if self.setColour then
                self:load(skin:format("taiko/taikohitcircle.png"))
            else
                self:load(skin:format("taiko/taikohitcircle-kat.png"))
                self.colour = skinData.Taiko.katColour
            end
        end
    end

    self.forcedDimensions = true
    self.dimensions = {width = 200, height = 200}
    self:updateHitbox()
    self:centerOrigin()
    _G.__NOTE_OBJECT_WIDTH = 200

    self.hitsound = ""

    self.type = 1

    return self
end

function TaikoObject:onHit()
    local gameplayState = states.game.Gameplay
    local foundSound = false

    if not foundSound then
        local clone = gameplayState.hitsounds["Default"]:clone()
        clone:setVolume((Settings.options["Audio"].hitsound/100) * skinData.Miscellaneous.hitsoundVolume)
        clone:play()
        clone:release()
    end
end

function TaikoObject:update(dt)
    self.super.update(self, dt)

    self.canBeHit = self.time > musicTime - safeZoneOffset and self.time < musicTime + safeZoneOffset
    if self.time < musicTime - safeZoneOffset and not self.wasGoodHit then
        self.tooLate = true
    end
    
    if self.tooLate then
        self.alpha = 0.5
    end
end

function TaikoObject:draw()
    if not self.visible then return end
    
    if self.x < 2220 and self.x > -400 then
        if self.setColour then
            self.color = {
                self.colour[1]/255,
                self.colour[2]/255,
                self.colour[3]/255
            }
        end
        self.super.draw(self)
    end
end

return TaikoObject