---@class MobileObjectManager
local MobileObjectManager = HitObjectManager:extend("MobileObjectManager")

function MobileObjectManager:new(instance)
    Group.new(self)

    self.mobileObjects = {}
    self.hitObjects = {}

    self.musicTime = 0

    self.screen = instance
    self.scorePerNote = 0
    self.accuracy = 1

    self.started = false

    self.length = 10000

    self.judgeCounts = {
        ["marvellous"] = 0,
        ["perfect"] = 0,
        ["great"] = 0,
        ["good"] = 0,
        ["bad"] = 0,
        ["miss"] = 0
    }

    self.scrollVelocities = {}
    self.scrollVelocityMarks = {}
    self.svIndex = 1
    self.initialSV = 1
end

function MobileObjectManager:getNotePosition(time)
    -- always downscroll
    local strumY = 100
    -- go from -100 to strumY
    return strumY - (time - self.musicTime) * 0.5
end

function MobileObjectManager:isOnScreen(time)
    return self:getNotePosition(self:getPositionFromTime(time)) >= -200
end

function MobileObjectManager:update(dt)
    self:updateTime(dt)

    while #self.hitObjects > 0 and self:isOnScreen(self.hitObjects[1].StartTime) do
        local hitObject = table.remove(self.hitObjects, 1)
        if hitObject.noteVer == "TAP" then
            local tapNote = TapNote(hitObject.lane, hitObject.StartTime, hitObject.tileWidth, hitObject.hitsounds)
            tapNote.y = self:getNotePosition(hitObject.StartTime)
            self:add(tapNote)
            table.insert(self.mobileObjects, tapNote)
        elseif hitObject.noteVer == "SLIDE" then
            print("slide note")
            local slideNote = SlideNote(hitObject.lane, hitObject.StartTime, hitObject.endTime, hitObject.tileWidth, hitObject.endWidth, hitObject.hitsounds)
            slideNote.y = self:getNotePosition(hitObject.StartTime)
            self:add(slideNote)
            table.insert(self.mobileObjects, slideNote)
        end
    end

    for i, mobileObject in ipairs(self.mobileObjects) do
        mobileObject.y = self:getNotePosition(mobileObject.StartTime)
        mobileObject:update(dt)
    end
end

function MobileObjectManager:draw()
    for i, mobileObject in ipairs(self.mobileObjects) do
        if self:isOnScreen(mobileObject.StartTime) then
            mobileObject:draw()
        end
    end
end

return MobileObjectManager