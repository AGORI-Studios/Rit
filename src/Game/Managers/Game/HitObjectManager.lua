---@class HitObjectManager
local HitObjectManager = Group:extend()

function HitObjectManager:new(instance)
    Group.new(self)
    
    self.hitObjects = {}
    self.drawableHitObjects = {}
    self.scrollVelocities = {}
    self.scrollVelocityMarks = {}
    self.musicTime = 0
    self.currentTime = 0
    
    self.svIndex = 1
    self.STRUM_Y = 50

    self.screen = instance

    self:createReceptors()
end

local midX = 1920/2.45
local count = 4

function HitObjectManager:createReceptors()
    for i = 1, count do
        local receptor = Receptor(i)
        receptor.y = self.STRUM_Y
        receptor.x = midX + (i - (count/2)) * 200
        self:add(receptor)
    end
end

function HitObjectManager:isOnScreen(time)
    return self:getNotePosition(time) < Game._windowHeight+400
end

function HitObjectManager:initSVMarks()
    if #self.scrollVelocities == 0 then
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
    local index = index or -1

    if index == -1 then
        for i = 1, #self.scrollVelocityMarks do
            if time < self.scrollVelocityMarks[i] then
                index = i
                break
            end
        end
    end

    if index == -1 then
        return time
    end

    local prev = self.scrollVelocities[index - 1] or ScrollVelocity()
    local pos = self.scrollVelocityMarks[index - 1] or 0
    pos = pos + (time - prev.StartTime) * prev.Multiplier

    return pos
end

function HitObjectManager:getNotePosition(time)
    return self.STRUM_Y + (time - self.currentTime)
end

function HitObjectManager:updateTime(dt)
    self.musicTime = self.musicTime + dt * 1000
    while (self.svIndex < #self.scrollVelocities and self.scrollVelocities[self.svIndex].StartTime <= self.musicTime) do
        self.svIndex = self.svIndex + 1
    end

    self.currentTime = self:getPositionFromTime(self.musicTime, self.svIndex)
end

function HitObjectManager:update(dt)
    self:updateTime(dt)

    while #self.hitObjects > 0 and self:isOnScreen(self.hitObjects[1].StartTime)do
        local hitObject = self.hitObjects[1]
        local drawableHitObject = HitObject(hitObject)
        drawableHitObject.x = midX + (drawableHitObject.Data.Lane - (count/2)) * 200
        self:add(drawableHitObject)
        table.insert(self.drawableHitObjects, drawableHitObject)
        table.remove(self.hitObjects, 1)
    end

    for _, hitObject in ipairs(self.drawableHitObjects) do
        hitObject.y = self:getNotePosition(hitObject.Data.StartTime)
    end

    Group.update(self, dt)
end

return HitObjectManager