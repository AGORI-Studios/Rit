local StoryboardSprite = Sprite:extend()

function StoryboardSprite:new(origin, filepath, x, y, layer)
    local x, y = Parsers["osu!"].convertPlayfieldToGame(x, y)
    
    Sprite.new(self, x, y, filepath)
    
    self.type = "StoryboardSprite"

    self.events = {}
    self.timers = {}

    self.layer = layer or "Background"

    self.addOrigin = false

    self.safePosX = x
    self.safePosY = y

    self.didFirstEvent = false

    if origin == "Centre" then
        self.origin.x = self:getFrameWidth()/2
        self.origin.y = self:getFrameHeight()/2
    elseif origin == "CentreLeft" then
        self.origin.y = self:getFrameHeight()/2
    elseif origin == "TopRight" then
        self.origin.x = self:getFrameWidth()
    elseif origin == "BottomCentre" then
        self.origin.y = self:getFrameHeight()
        self.origin.x = self:getFrameWidth()/2
    elseif origin == "TopCentre" then
        self.origin.x = self:getFrameWidth()/2
    -- 6 is same as top left, and should not be used
    elseif origin == "CentreRight" then
        self.origin.x = self:getFrameWidth()
        self.origin.y = self:getFrameHeight()/2
    elseif origin == "BottomLeft" then
        self.origin.y = self:getFrameHeight()
    elseif origin == "BottomRight" then
        self.origin.x = self:getFrameWidth()
        self.origin.y = self:getFrameHeight()
    else
    end

    self.visible = false

    return self
end

function StoryboardSprite:update(dt)
    Sprite.update(self, dt)

    local event = self.events[1]

    if event and musicTime >= event.startTime then
        if not self.didFirstEvent then 
            self.didFirstEvent = true
            self.visible = true
        end
        if event.type == "Fade" then
            if self.timers["Fade"] then 
                Timer.cancel(self.timers["Fade"])
            end
            self.alpha = event.startVal
            self.timers["Fade"] = Timer.tween(
                event.duration,
                self,
                {
                    alpha = event.endVal
                },
                event.ease
            )
        elseif event.type == "MoveXY" then
            if self.timers["MoveX"] then 
                Timer.cancel(self.timers["MoveX"])
            end
            if self.timers["MoveY"] then 
                Timer.cancel(self.timers["MoveY"])
            end
            self.visible = true
            self.x = event.startValX
            self.y = event.startValY
            if event.duration > 0 then
                self.timers["MoveX"] = Timer.tween(
                    event.duration,
                    self,
                    {
                        x = event.endValX
                    },
                    event.ease
                )
                self.timers["MoveY"] = Timer.tween(
                    event.duration,
                    self,
                    {
                        y = event.endValY
                    },
                    event.ease
                )
            end
        elseif event.type == "Scale" then
            if self.timers["Scale"] then 
                Timer.cancel(self.timers["Scale"])
            end
            event.startVal = event.startVal + 0.5
            event.endVal = event.endVal + 0.5
            self.scale.x, self.scale.y = event.startVal, event.startVal
            self.timers["Scale"] = Timer.tween(
                event.duration,
                self.scale,
                {
                    x = event.endVal,
                    y = event.endVal
                },
                event.ease
            )
        elseif event.type == "Rotate" then
            if self.timers["Rotate"] then 
                Timer.cancel(self.timers["Rotate"])
            end
            self.angle = event.startVal
            self.timers["Rotate"] = Timer.tween(
                event.duration,
                self,
                {
                    angle = event.endVal
                },
                event.ease
            )
        elseif event.type == "Colour" then
            if self.timers["Colour"] then 
                Timer.cancel(self.timers["Colour"])
            end
            self.color = event.startRGB or {1, 1, 1}
            self.timers["Colour"] = Timer.tween(
                event.duration,
                self.color,
                {
                    [1] = event.endRGB[1],
                    [2] = event.endRGB[2],
                    [3] = event.endRGB[3]
                },
                event.ease
            )
        elseif event.type == "Hide" then
            self.visible = false
        end
        table.remove(self.events, 1)
    end
end

function StoryboardSprite:draw()
    Sprite.draw(self)
end

return StoryboardSprite