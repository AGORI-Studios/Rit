---@class HitObjectManager
local HitObjectManager = Group:extend("HitObjectManager")
local GAME = States.Screens.Game

function HitObjectManager:new(instance)
    Group.new(self)

    self.receptorsGroup = TypedGroup(Receptor)
    self.underlay = Underlay(4)
    self:add(self.underlay)

    self:add(self.receptorsGroup)
    self.hitObjects = {}
    self.drawableHitObjects = {}
    self.scrollVelocities = {}
    self.scrollVelocityMarks = {}
    self.musicTime = -1000
    self.currentTime = 0

    self.svIndex = 1
    self.STRUM_Y = 1080-225

    self.screen = instance
    self.scorePerNote = 0
    self.accuracy = 1

    self.started = false

    self.initialSV = 1
    self.length = 1000

    self.data = {
        mode = 4
    }

    self.judgeCounts = {
        ["marvellous"] = 0,
        ["perfect"] = 0,
        ["great"] = 0,
        ["good"] = 0,
        ["bad"] = 0,
        ["miss"] = 0
    }
end

local midX = 1920/2.45

function HitObjectManager:createReceptors(count)
    self.data = {mode = 4}
    self.data.mode = count
    for i = 1, self.data.mode do
        local receptor = Receptor(i, count)
        receptor.y = self.STRUM_Y
        receptor.x = midX + (i - (self.data.mode/2)) * 200
        self.receptorsGroup:add(receptor)
    end

    self.underlay:updateCount(count)

    self:resortReceptors()
end

function HitObjectManager:resortReceptors()
    -- sometimes positions get messed up
    for i = 1, self.data.mode do
        -- sort based off of underlay width and pos
        local receptor = self.receptorsGroup.objects[i]
        receptor.x = self.underlay.x + ((i-1) * 200)
    end
end

function HitObjectManager:isOnScreen(time)
    return self:getNotePosition(self:getPositionFromTime(time), true) >= -500
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
    return self.STRUM_Y - (time - self.currentTime) * 2.2
end 

function HitObjectManager:updateTime(dt)
    self.musicTime = self.musicTime + dt * 1000
    if self.musicTime >= 0 then
        self.started = true
        GAME.instance.song:play()
        Script:call("OnSongStart")
    end
    if not self.started then
        return
    end

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

        drawableHitObject.x = self.receptorsGroup.objects[hitObject.Lane].x
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

        if self.musicTime > hitObject.Data.StartTime+360 and hitObject.moveWithScroll then
            self:remove(hitObject)
            hitObject:destroy()
            table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
        end
    end

    for i = 1, self.data.mode do
        if Input:wasPressed(self.data.mode .. "k" .. i) then
            Script:call("OnPress", i, self.musicTime)
            if not self.receptorsGroup.objects[i] then return end
            self.receptorsGroup.objects[i].down = true

            for _, hitObject in ipairs(self.drawableHitObjects) do
                local abs = math.abs(self.musicTime - hitObject.Data.StartTime)
                if abs < 360 and hitObject.Data.Lane == i then
                    hitObject:hit(self.musicTime - hitObject.Data.StartTime)
                    self.screen.combo = self.screen.combo + 1
                    self.screen.maxCombo = math.max(self.screen.maxCombo, self.screen.combo)
                    Script:call("OnHit", i, self.musicTime, hitObject, self.screen.combo)
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
                    --[[ hitObject:hit(self.musicTime - hitObject.Data.EndTime) ]]
                    self:remove(hitObject)
                    hitObject:destroy()
                    table.remove(self.drawableHitObjects, table.findID(self.drawableHitObjects, hitObject))
                end
            end
        end
        if Input:wasReleased(self.data.mode .. "k" .. i) then
            if not self.receptorsGroup.objects[i] then return end
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

    Script:call("OnUpdate", dt, self.musicTime)
    if (self.musicTime or 0) > ((self.length or 1000)+500) then
        Script:call("OnSongEnd")
        Game:SwitchState(Skin:getSkinnedState("SongListMenu"))
    end

    Group.update(self, dt)
end

return HitObjectManager
