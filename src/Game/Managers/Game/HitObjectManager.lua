---@class HitObjectManager
local HitObjectManager = Group:extend("HitObjectManager")

function HitObjectManager:new(instance)
    Group.new(self)
    
    self.receptorsGroup = TypedGroup(Receptor)
    self:add(self.receptorsGroup)
    self.hitObjects = {}
    self.drawableHitObjects = {}
    self.scrollVelocities = {}
    self.scrollVelocityMarks = {}
    self.musicTime = 0
    self.currentTime = 0
    
    self.svIndex = 1
    self.STRUM_Y = 50

    self.screen = instance
    self.scorePerNote = 0
    self.accuracy = 1

    self.started = false

    self.initialSV = 1
    self.length = 1000

    self.data = {
        mode = 4
    }
end

local midX = 1920/2.45

function HitObjectManager:createReceptors(count)
    self.data.mode = count
    for i = 1, self.data.mode do
        local receptor = Receptor(i, count)
        receptor.y = self.STRUM_Y
        receptor.x = midX + (i - (self.data.mode/2)) * 200
        self.receptorsGroup:add(receptor)
    end

    self:resortReceptors()
end

function HitObjectManager:resortReceptors()
    -- sometimes positions get messed up
    for i = 1, self.data.mode do
        self.receptorsGroup.objects[i].x = midX + (i - (self.data.mode/2)) * 200
    end
end

function HitObjectManager:isOnScreen(time)
    return self:getNotePosition(self:getPositionFromTime(time), true) <= Game._windowHeight+600
end

function HitObjectManager:initSVMarks()
    if #self.scrollVelocities < 1 then
        return
    end

    local first = self.scrollVelocities[1]

    local time = first.StartTime
    table.insert(self.scrollVelocityMarks, time)

    for i = 2, #self.scrollVelocities do
        local prev = self.scrollVelocities[i - 1]
        local current = self.scrollVelocities[i]

        time = time + (current.StartTime - prev.StartTime) * prev.Multiplier
        table.insert(self.scrollVelocityMarks, time)
    end
end

function HitObjectManager:getPositionFromTime(time, index)
    index = index or -1

    if index == -1 then
        for i = 1, #self.scrollVelocities do
            if time < self.scrollVelocities[i].StartTime then
                index = i
                break
            else
                index = 1
            end
        end
    end

    if index == 1 then
        return time * self.initialSV
    end
    
    local previous = self.scrollVelocities[index-1] or ScrollVelocity(0, 1)

    local pos = self.scrollVelocityMarks[index-1] or 0
    pos = pos + (time - previous.StartTime) * previous.Multiplier

    return pos
end

function HitObjectManager:getNotePosition(time, moveWithScroll)
    if not moveWithScroll then
        return self.STRUM_Y
    end
    return self.STRUM_Y + (time - self.currentTime)
end 

function HitObjectManager:updateTime(dt)
    if not self.started then
        return
    end
    self.musicTime = self.musicTime + dt * 1000

    while (self.svIndex <= #self.scrollVelocities and self.musicTime >= self.scrollVelocities[self.svIndex].StartTime) do
        self.svIndex = self.svIndex + 1
    end

    self.currentTime = self:getPositionFromTime(self.musicTime, self.svIndex)
end

function HitObjectManager:update(dt)
    self:updateTime(dt)

    while #self.hitObjects > 0 and self:isOnScreen(self.hitObjects[1].StartTime) do
        local hitObject = self.hitObjects[1]
        local drawableHitObject = HitObject(hitObject, self.data.mode)

        drawableHitObject.x = midX + (drawableHitObject.Data.Lane - (self.data.mode/2)) * 200
        drawableHitObject.initialSVTime = self:getPositionFromTime(hitObject.StartTime)
        drawableHitObject.endSVTime = self:getPositionFromTime(hitObject.EndTime)
        drawableHitObject.y = self:getNotePosition(drawableHitObject.initialSVTime, drawableHitObject.moveWithScroll)
        drawableHitObject:resize(Game._windowWidth, Game._windowHeight)
        
        self:add(drawableHitObject, false)
        table.insert(self.drawableHitObjects, drawableHitObject)
        table.remove(self.hitObjects, 1)
    end

    for _, hitObject in ipairs(self.drawableHitObjects) do
        hitObject.y = self:getNotePosition(hitObject.initialSVTime, hitObject.moveWithScroll)
        hitObject.endY = self:getNotePosition(hitObject.Data.EndTime, true)

        if self.musicTime > hitObject.Data.StartTime+360 then
            self:remove(hitObject)
            hitObject:destroy()
            table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
        end
    end

    for i = 1, self.data.mode do
        if Input:wasPressed(self.data.mode .. "k" .. i) then
            self.receptorsGroup.objects[i].down = true

            for _, hitObject in ipairs(self.drawableHitObjects) do
                local abs = math.abs(self.musicTime - hitObject.Data.StartTime)
                if abs < 360 and hitObject.Data.Lane == i then
                    self.screen.score = self.screen.score + self.scorePerNote
                    hitObject:hit()
                    if not hitObject.holdSprite then
                        self:remove(hitObject)
                        hitObject:destroy()
                        table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
                    else
                        hitObject.moveWithScroll = false
                    end

                    break
                end
            end
        end
        if Input:isDown(self.data.mode .. "k" .. i) then
            for _, hitObject in ipairs(self.drawableHitObjects) do
                if hitObject.Data.Lane == i and hitObject.holdSprite and hitObject.holdSprite.endTime - self.musicTime <= 50 then
                    hitObject:hit(true)
                    self:remove(hitObject)
                    hitObject:destroy()
                    table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
                end
            end
        end
        if Input:wasReleased(self.data.mode .. "k" .. i) then
            self.receptorsGroup.objects[i].down = false

            for _, hitObject in ipairs(self.drawableHitObjects) do
                if hitObject.Data.Lane == i then
                    if not hitObject.moveWithScroll then
                        self:remove(hitObject)
                        hitObject:destroy()
                        table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
                    end
                end
            end
        end
    end

    if (self.musicTime or 0) > (self.length or 1000) then
        Game:SwitchState(Skin:getSkinnedState("SongListMenu"))
    end

    Group.update(self, dt)
end

return HitObjectManager