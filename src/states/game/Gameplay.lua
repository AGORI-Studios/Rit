local Gameplay = state()

Gameplay.strumX = 525

Gameplay.spawnTime = 3000

Gameplay.hitObjects = Group()
Gameplay.unspawnNotes = {}
Gameplay.sliderVelocities = {}

Gameplay.strumLineObjects = Group()

Gameplay.songPercent = 0
Gameplay.updateTime = false
Gameplay.endingSong = false
Gameplay.starting = false

Gameplay.songScore = 0
Gameplay.songHits = 0
Gameplay.songMisses = 0

Gameplay.songName = ""
Gameplay.difficultyName = ""

Gameplay.members = {}

Gameplay.chartType = ""

Gameplay.trackRounding = 100
Gameplay.initialScrollVelocity = 1
Gameplay.velocityPositionMakers = {}

Gameplay.songDuration = 0

local previousFrameTime -- used for keeping musicTime consistent

local comboTimer = {}
local judgeTimer = {}

function Gameplay:preloadAssets()
    for i = 0, 9 do
        Cache:loadImage("defaultSkins/skinThrowbacks/combo/COMBO" .. i .. ".png")
    end
    Cache:loadImage("defaultSkins/skinThrowbacks/judgements/MISS.png")
    Cache:loadImage("defaultSkins/skinThrowbacks/judgements/BAD.png")
    Cache:loadImage("defaultSkins/skinThrowbacks/judgements/GOOD.png")
    Cache:loadImage("defaultSkins/skinThrowbacks/judgements/GREAT.png")
    Cache:loadImage("defaultSkins/skinThrowbacks/judgements/PERFECT.png")
    Cache:loadImage("defaultSkins/skinThrowbacks/judgements/MARVELLOUS.png")
end

function Gameplay:reset()
    self.strumX = 525
    self.spawnTime = 1000
    self.hitObjects = Group()
    self.holdHitObjects = Group()
    self.unspawnNotes = {}
    self.sliderVelocities = {}
    self.strumLineObjects = Group()
    self.songPercent = 0
    self.updateTime = false
    self.endingSong = false
    self.starting = false
    self.songScore = 0
    self.songHits = 0
    self.songMisses = 0
    self.songName = ""
    self.difficultyName = ""
    self.members = {}
    self.didTimer = false
    self.objectKillOffset = 350
    self.keysArray = {"gameLeft", "gameDown", "gameUp", "gameRight"}
    self.inputsArray = {false, false, false, false}
    self.hitsound = love.audio.newSource("defaultSkins/skinThrowbacks/hitsound.wav", "static")
    self.hitsound:setVolume(0.1)
    self.judgement = nil
    self.comboGroup = Group()
    self.combo = 0
    self.initialScrollVelocity = 1
    self.velocityPositionMakers = {}
    self.currentSvIndex = 1
    self.songDuration = 0

    self:preloadAssets()

    self.judgements = { -- Judgement 4 timings
        {name="marvellous", img="defaultSkins/skinThrowbacks/judgements/MARVELLOUS.png", time=22},
        {name="perfect", img="defaultSkins/skinThrowbacks/judgements/PERFECT.png", time=45},
        {name="great", img="defaultSkins/skinThrowbacks/judgements/GREAT.png", time=90},
        {name="good", img="defaultSkins/skinThrowbacks/judgements/GOOD.png", time=135},
        {name="bad", img="defaultSkins/skinThrowbacks/judgements/BAD.png", time=180},
        {name="miss", img="defaultSkins/skinThrowbacks/judgements/MISS.png", time=225}
    }
end

function Gameplay:doJudgement(time)
    local judgement = nil
    for i, judge in ipairs(self.judgements) do
        if time <= judge.time then
            judgement = judge
            break
        end
    end
    if not judgement then judgement = self.judgements[#self.judgements] end -- default to miss
    self:remove(self.judgement)
    self.judgement = Sprite(75, 390, judgement.img)
    if judgeTimer.y then Timer.cancel(judgeTimer.y) end
    judgeTimer.y = Timer.tween(0.1, self.judgement, {y = 400}, "in-out-expo")
    self.judgement.origin.x = self.judgement.width / 2 -- Always center x origin
    self:add(self.judgement)

    -- combo shits
    self.comboGroup.members = {}
    -- for the amount of digits in the combo, add a sprite
    if judgement.name == "miss" then
        self.combo = 0
    end
    for i = 1, #tostring(self.combo) do
        if not comboTimer[i] then comboTimer[i] = {} end
        local digit = tostring(self.combo):sub(i, i)
        local sprite = Sprite(0, 0, "defaultSkins/skinThrowbacks/combo/COMBO" .. digit .. ".png")
        local sprWidth = sprite.width * 1.25
        sprite.x = 180 - (#tostring(self.combo) * sprWidth/2) + (i * sprWidth)
        sprite.y = 460
        sprite:setGraphicSize(math.floor(sprWidth))
        sprite.scale.y = sprite.scale.y + 0.2
        if comboTimer[i].scaleY then Timer.cancel(comboTimer[i].scaleY) end
        comboTimer[i].scaleY = Timer.tween(0.1, sprite.scale, {y = sprite.scale.y - 0.2}, "in-out-expo")
        sprite.origin.x = sprWidth / 2
        sprite.origin.y = sprWidth / 2
        self.comboGroup:add(sprite)
    end
end

-- // Slider Velocity Functions (Quaver)  \\ --
function Gameplay:initializePositionMarkers()
    if #self.sliderVelocities == 0 then return end

    local position = self.sliderVelocities[1].startTime 
                    * self.initialScrollVelocity 
                    * self.trackRounding
    
    table.insert(self.velocityPositionMakers, position)
    for i = 2, #self.sliderVelocities do
        local velocity = self.sliderVelocities[i]
        position = position + (
            velocity.startTime - 
            self.sliderVelocities[i - 1].startTime
        ) * (self.sliderVelocities[i - 1] and self.sliderVelocities[i - 1].multiplier or 0) 
            * self.trackRounding
        table.insert(self.velocityPositionMakers, position)
    end
end

function Gameplay:updateCurrentTrackPosition()
    while self.currentSvIndex < #self.sliderVelocities and musicTime >= self.sliderVelocities[self.currentSvIndex].startTime do
        self.currentSvIndex = self.currentSvIndex + 1
    end

    self.currentTrackPosition = self:GetPositionFromTime(musicTime, self.currentSvIndex)
end

function Gameplay:GetPositionFromTime(time, index)
    if index == 1 then
        return time * self.initialScrollVelocity * self.trackRounding
    end
    index = index - 1
    local curPos = self.velocityPositionMakers[index]
    curPos = curPos + ((time - self.sliderVelocities[index].startTime) * (self.sliderVelocities[index].multiplier or 0) * self.trackRounding)
    return curPos
end

function Gameplay:getPositionFromTime(time)
    local _i = 1
    for i = 1, #self.sliderVelocities do
        if time < self.sliderVelocities[i].startTime then
            _i = i
            break
        end
    end

    return self:GetPositionFromTime(time, _i)
end

function Gameplay:isSVNegative(time)
    local i_ = 1
    for i = 1, #self.sliderVelocities do
        if time >= self.sliderVelocities[i].startTime then
            i_ = i
            break
        end
    end

    i_ = i_ - 1

    for i = i_, 1, -1 do
        if self.sliderVelocities[i].multiplier ~= 0 then
            i_ = i
            break
        end
    end

    if i_ <= 0 then
        return self.initialScrollVelocity < 0
    end

    return self.sliderVelocities[i_].multiplier < 0
end

function Gameplay:initPositions()
    --[[ for _, hitObject in ipairs(self.hitObjects.members) do
        hitObject.initialTrackPosition = self:getPositionFromTime(hitObject.time)
        hitObject.latestTrackPosition = hitObject.initialTrackPosition
    end
    for _, sliderObject in ipairs(self.holdHitObjects.members) do
        sliderObject.initialTrackPosition = self:getPositionFromTime(sliderObject.time)
        sliderObject.latestTrackPosition = sliderObject.initialTrackPosition
    end ]]
    for _, hitObject in ipairs(self.unspawnNotes) do
        hitObject.initialTrackPosition = self:getPositionFromTime(hitObject.time)
        hitObject.latestTrackPosition = hitObject.initialTrackPosition
    end
end

function Gameplay:getSpritePosition(offset, initialPos)
    return 50 + (((initialPos or 0) - offset) * speed / self.trackRounding)
end

function Gameplay:updateSpritePositions(offset, curTime)
    local spritePosition = 0

    for _, hitObject in ipairs(self.hitObjects.members) do
        spritePosition = self:getSpritePosition(offset, hitObject.initialTrackPosition)
        hitObject.y = spritePosition
    end
    for _, sliderObject in ipairs(self.holdHitObjects.members) do
        spritePosition = self:getSpritePosition(offset, sliderObject.initialTrackPosition)
        sliderObject.y = spritePosition
    end
end

function Gameplay:add(member, pos)
    local pos = pos or -1
    if pos == -1 then
        table.insert(self.members, member)
    else
        table.insert(self.members, pos, member)
    end
end

function Gameplay:remove(member)
    for i, v in ipairs(self.members) do
        if v == member then
            table.remove(self.members, i)
            return
        end
    end
end

function Gameplay:insert(pos, member)
    table.insert(self.members, pos, member)
end

function Gameplay:clear()
    self.members = {}
end

function Gameplay:enter()
    self:reset()

    self.inputsArray = {false, false, false, false}

    self:add(self.strumLineObjects)
    self:add(self.holdHitObjects)
    self:add(self.hitObjects)
    self:generateStrums()

    musicTime = -1000

    self:generateBeatmap(self.chartVer, self.songPath, self.folderpath)

    self:initializePositionMarkers()
    self:updateCurrentTrackPosition()
    self:initPositions()
    self:updateSpritePositions(self.currentTrackPosition, musicTime)

    safeZoneOffset = (15 / 60) * 1000

    Timer.after(0.8, function()
        self.updateTime = true
        self.didTimer = true
    end)

    self:add(self.comboGroup)
end

function Gameplay:generateStrums()
    local strumX = self.strumX
    local strumY = 50

    for i = 1, 4 do
        local strum = StrumObject(strumX, strumY, i)

        self.strumLineObjects:add(strum)
        strum:postAddToGroup()
    end
end

function Gameplay:update(dt)
    if self.updateTime then
        -- use previousFrameTime to get musicTime (love.timer.getTime is pft)
        musicTime = musicTime + (love.timer.getTime() * 1000) - (previousFrameTime or (love.timer.getTime()*1000))
        previousFrameTime = love.timer.getTime() * 1000
        if musicTime >= 0 and not audioFile:isPlaying() and musicTime < self.songDuration then
            audioFile:play()
            audioFile:seek(musicTime / 1000) -- safe measure to keep it lined up
        elseif musicTime > self.songDuration and not audioFile:isPlaying() then
            state.switch(states.menu.SongMenu)
            return
        end
        self:updateCurrentTrackPosition()
        self:updateSpritePositions(self.currentTrackPosition, musicTime)
    end

    for i, member in ipairs(self.members) do
        if member.update then
            member:update(dt)
        end
    end

    if self.unspawnNotes[1] then
        local time = self.spawnTime
        if speed < 1 then time = time / speed end
        -- change speed with slider velocity
        if self.sliderVelocities[self.currentSvIndex] then
            time = time / (self.sliderVelocities[self.currentSvIndex].multiplier == 0 and 1 or self.sliderVelocities[self.currentSvIndex].multiplier)
        end

        while #self.unspawnNotes > 0 and self.unspawnNotes[1].time - musicTime < time do
            local ho = table.remove(self.unspawnNotes, 1)

            if ho.isSustainNote then
                self.holdHitObjects:add(ho)
            else
                self.hitObjects:add(ho)
            end
            ho.spawned = true
        end
    end

    if self.didTimer and self.updateTime then
        self:keysCheck()
        if #self.hitObjects.members > 0 then
            if self.didTimer then
                local fakeCrocet = (60 / bpm) * 1000
                for i, ho in ipairs(self.hitObjects.members) do
                    local strum = self.strumLineObjects.members[ho.data]
                    --ho:followStrum(strum, fakeCrocet)

                    if musicTime - ho.time > self.objectKillOffset then
                        ho.active = false
                        ho.visible = false
                        ho:kill()
                        self.hitObjects:remove(ho)
                        ho:destroy()
                        self:doJudgement(1000) -- miss
                    end
                end
            end
        end

        if #self.holdHitObjects.members > 0 then
            if self.didTimer then
                local fakeCrocet = (60 / bpm) * 1000
                for i, ho in ipairs(self.holdHitObjects.members) do
                    local strum = self.strumLineObjects.members[ho.data]
                    --ho:followStrum(strum, fakeCrocet)
                    ho:clipToStrum(strum)

                    if musicTime - ho.time > self.objectKillOffset then
                        ho.active = false
                        ho.visible = false
                        ho:kill()
                        self.holdHitObjects:remove(ho)
                        if self.sliderVelocities[self.currentSvIndex] then
                            ho:changeHoldScale(self.sliderVelocities[self.currentSvIndex].multiplier)
                        end
                        ho:destroy()
                    end
                end
            end
        end
    end

    for i = 1, 4 do
        if input:pressed(self.keysArray[i]) then
            self:keyPressed(i)
        end
        if input:down(self.keysArray[i]) then
            self:keyDown(i)
        end
        if input:released(self.keysArray[i]) then
            self:keyReleased(i)
        end
    end
end

function Gameplay:keyPressed(key)
    self.hitsound:clone():play()
    if self.updateTime then
        if #self.hitObjects.members > 0 then
            local lastTime = musicTime

            local pressNotes = {}
            local notesStopped = false
            local sortedNotesList = {}

            for i, note in ipairs(self.hitObjects.members) do
                if note.canBeHit and not note.tooLate and not note.wasGoodHit and not note.isSustainNote then
                    if key == note.data then
                        table.insert(sortedNotesList, note)
                    end
                    self.canMiss = true
                end
            end

            table.sort(sortedNotesList, function(a, b)
                return a.time < b.time
            end)

            if #sortedNotesList > 0 then
                for i, epicNote in ipairs(sortedNotesList) do
                    for i2, doubleNote in ipairs(pressNotes) do
                        if math.abs(doubleNote.time - epicNote.time) < 1 then
                            self.hitObjects:remove(doubleNote)
                        else
                            notesStopped = true
                        end
                    end

                    if not notesStopped then
                        self:goodNoteHit(epicNote, math.abs(math.round(epicNote.time - lastTime)))
                    end
                    table.insert(pressNotes, epicNote)
                end
            end
        end
    end
end

function Gameplay:keyDown(key)
    local inputname = self.keysArray[key]
    self.inputsArray[key] = true
    self.strumLineObjects.members[key]:playAnim("pressed")
end

function Gameplay:keyReleased(key)
    local inputname = self.keysArray[key]
    self.inputsArray[key] = false

    self.strumLineObjects.members[key]:playAnim("unpressed")
end

function Gameplay:keysCheck()
    local holdArray, pressArray, releaseArray = {}, {}, {}

    for i, key in ipairs(self.keysArray) do
        table.insert(holdArray, input:down(key))
        table.insert(pressArray, input:pressed(key))
        table.insert(releaseArray, input:released(key))
    end

    if self.updateTime then
        if #self.holdHitObjects.members > 0 then
            for i, note in ipairs(self.holdHitObjects.members) do
                if note.canBeHit and not note.tooLate and note.prevNote.wasGoodHit and not note.wasGoodHit and note.isSustainNote and self.inputsArray[note.data] then
                    self:goodNoteHit(note)
                end
            end
        end
    end
end

function Gameplay:goodNoteHit(note, time)
    if not note.wasGoodHit then
        note.wasGoodHit = true
        --self.health = self.health + note.hitHealth

        if not note.isSustainNote then
            self.combo = self.combo + 1
            self:doJudgement(time)
            note:kill()
            self.hitObjects:remove(note)
            note:destroy()
            note = nil
        end
    end
end

function Gameplay:draw()
    for i, member in ipairs(self.members) do
        if member.draw then
            member:draw()
        end
    end
end

function Gameplay:generateBeatmap(chartType, songPath, folderPath)
    if chartType == "Quaver" then
        quaverLoader.load(songPath, folderPath)
    elseif chartType == "osu!" then
        osuLoader.load(songPath, folderPath)
    elseif chartType == "Stepmania" then
        smLoader.load(songPath, folderPath)
    elseif chartType == "Malody" then
        malodyLoader.load(songPath, folderPath)
    end

    table.sort(self.unspawnNotes, function(a, b)
        return a.time < b.time
    end)

    self.songName = __title or "N/A"
    self.difficultyName = __diffName or "N/A"
    self.songDuration = audioFile:getDuration() * 1000

    if discordRPC then
        discordRPC.presence = {
            details = "Playing a song",
            state = self.songName .. " - " .. self.difficultyName,
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
    end
end

return Gameplay