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

Gameplay.songName = ""
Gameplay.difficultyName = ""

Gameplay.members = {}
Gameplay.members2 = {} -- judgements, combo, etc

Gameplay.chartType = ""

Gameplay.trackRounding = 100
Gameplay.initialScrollVelocity = 1
Gameplay.velocityPositionMakers = {}

Gameplay.songDuration = 0
Gameplay.escapeTimer = 0 -- how long the back button has been held for
Gameplay.health = 0.5

Gameplay.maxScore = 1000000 -- 1 million max score. Can be modified with mods (TODO)
Gameplay.score = 0
Gameplay.rating = 0
Gameplay.accuracy = 0
Gameplay.misses = 0
Gameplay.hits = 0
Gameplay.noteScore = 0

Gameplay.playfields = {}

Gameplay.background = nil

Gameplay.bgLane = {
    x = 0,
    width = 0
}

Gameplay.events = {}

Gameplay.lastNoteTime = 10000 -- safe number

local lerpedScore = 0
local lerpedAccuracy = 0

local comboTimer = {}
local judgeTimer = {}

function Gameplay:preloadAssets()
    -- Preload our judgement assets
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
    -- Reset all variables to their default values
    self.strumX = 525
    self.spawnTime = 1000
    self.hitObjects = Group()
    self.timingLines = Group()
    self.unspawnNotes = {}
    self.sliderVelocities = {}
    self.strumLineObjects = Group()
    self.songPercent = 0
    self.updateTime = false
    self.endingSong = false
    self.starting = false
    self.songScore = 0
    self.songHits = 0
    self.songName = ""
    self.difficultyName = ""
    self.members = {}
    self.members2 = {}
    self.didTimer = false
    self.objectKillOffset = 350
    self.inputsArray = {false, false, false, false}
    --[[ self.hitsound = love.audio.newSource("defaultSkins/skinThrowbacks/hitsound.wav", "static") ]]
    self.hitsound = love.audio.newSource(skin:format("hitsound.wav"), "static")
    self.hitsound:setVolume(0.1)
    self.judgement = nil
    self.comboGroup = Group()
    self.combo = 0
    self.missCombo = 0
    self.initialScrollVelocity = 1
    self.velocityPositionMakers = {}
    self.currentSvIndex = 1
    self.songDuration = 0
    self.health = 0.5
    self.mode = 4 -- amount of keys
    self.maxScore = 1000000 -- 1 million max score
    self.score = 0
    self.rating = 0
    self.accuracy = 0
    self.noteScore = 0
    self.soundManager = SoundManager()
    self.playfields = {}
    self.hits = 0
    self.misses = 0
    self.lastNoteTime = 10000 -- safe number

    self.noteoffsets = {}

    self.background = nil

    self.events = {}

    self.bgLane = {
        x = 0,
        width = 0
    }

    self.replay = {hits={}, meta={}, score={}, mods={}}
    self.watchingReplay = false

    self:preloadAssets()

    self.judgements = { -- Judgement 4 timings
        {name="marvellous", img="defaultSkins/skinThrowbacks/judgements/MARVELLOUS.png", time=22, scoreMultiplier=1},
        {name="perfect", img="defaultSkins/skinThrowbacks/judgements/PERFECT.png", time=45, scoreMultiplier=1},
        {name="great", img="defaultSkins/skinThrowbacks/judgements/GREAT.png", time=90, scoreMultiplier=0.7},
        {name="good", img="defaultSkins/skinThrowbacks/judgements/GOOD.png", time=135, scoreMultiplier=0.55},
        {name="bad", img="defaultSkins/skinThrowbacks/judgements/BAD.png", time=180, scoreMultiplier=0.3},
        {name="miss", img="defaultSkins/skinThrowbacks/judgements/MISS.png", time=225, scoreMultiplier=0},
    }

    musicTime = 0

    self.escapeTimer = 0
end

function Gameplay:addPlayfield(x, y)
    -- Adds a playfield to the game screen
    local x = x or 0
    local y = y or 0
    local playfield = Playfield(x, y)
    table.insert(self.playfields, playfield)
end

function Gameplay:doJudgement(time)
    local judgement = nil
    local index = 1
    for i, judge in ipairs(self.judgements) do
        if time <= judge.time then
            judgement = judge
            break
        end
    end
    if not judgement then judgement = self.judgements[#self.judgements] end -- default to miss

    local score = self.noteScore * judgement.scoreMultiplier

    self.score = self.score + score
    -- find max possible score
    local maxScore = (self.misses + self.hits) * self.noteScore
    self.accuracy = (self.score / maxScore) * 100

    self:remove2(self.judgement)
    self.judgement = Sprite(Inits.GameWidth/2, 390, judgement.img)
    if judgeTimer.y then Timer.cancel(judgeTimer.y) end
    judgeTimer.y = Timer.tween(0.1, self.judgement, {y = 400}, "in-out-expo")
    self.judgement.origin.x = self.judgement.width / 2 -- Always center x origin
    self.judgement.x = self.judgement.x - self.judgement.origin.x
    self:add2(self.judgement)

    -- combo shits
    self.comboGroup.members = {}
    -- for the amount of digits in the combo, add a sprite
    if judgement.name == "miss" then
        self.combo = 0
        self.misses = self.misses + 1
        self.missCombo = self.missCombo + 1
    end
    if self.combo > 0 then -- The normal combo
        for i = 1, #tostring(self.combo) do
            local comboDigit = tostring(self.combo):sub(i, i)
            local sprite = Sprite(0, 0, "defaultSkins/skinThrowbacks/combo/COMBO" .. comboDigit .. ".png")
            local sprWidth = sprite.width * 1.25
            --sprite.x = 180 - (#tostring(self.combo) * sprWidth/2) + (i * sprWidth) -- center to middle of screen lfmna 
            sprite.x = 180 - (#tostring(self.combo) * sprWidth/2) + (i * sprWidth)
            sprite.x = sprite.x + (Inits.GameWidth/2.55)
            sprite.y = 460
            sprite:setGraphicSize(math.floor(sprWidth))
            sprite.scale.y = sprite.scale.y + 0.2
            if not comboTimer[i] then comboTimer[i] = {} end
            if comboTimer[i].scaleY then Timer.cancel(comboTimer[i].scaleY) end
            comboTimer[i].scaleY = Timer.tween(0.1, sprite.scale, {y = sprite.scale.y - 0.2}, "in-out-expo")
            sprite.origin.x = sprWidth / 2
            sprite.origin.y = sprWidth / 2
            self.comboGroup:add(sprite)
        end
    end
    if self.missCombo > 0 then -- The miss combo (I find it a nice QoL feature)
        for i = 1, #tostring(self.missCombo) do
            local comboDigit = tostring(self.missCombo):sub(i, i)
            local sprite = Sprite(0, 0, "defaultSkins/skinThrowbacks/combo/COMBO" .. comboDigit .. ".png")
            local sprWidth = sprite.width * 1.25
            sprite.x = 180 - (#tostring(self.combo) * sprWidth/2) + (i * sprWidth)
            sprite.x = sprite.x + (Inits.GameWidth/2.55)
            sprite.y = 460
            sprite.color = {1, 0.2, 0.2}
            sprite:setGraphicSize(math.floor(sprWidth))
            sprite.scale.y = sprite.scale.y + 0.2
            if not comboTimer[i] then comboTimer[i] = {} end
            if comboTimer[i].scaleY then Timer.cancel(comboTimer[i].scaleY) end
            comboTimer[i].scaleY = Timer.tween(0.1, sprite.scale, {y = sprite.scale.y - 0.2}, "in-out-expo")
            sprite.origin.x = sprWidth / 2
            sprite.origin.y = sprWidth / 2
            self.comboGroup:add(sprite)
        end
    end
end

-- // Slider Velocity Functions \\ --
function Gameplay:initializePositionMarkers()
    if #self.sliderVelocities == 0 then return end

    local position = self.sliderVelocities[1].startTime 
                    * self.initialScrollVelocity 
                    * self.trackRounding
    
    table.insert(self.velocityPositionMakers, position)
    for i = 2, #self.sliderVelocities do
        local velocity = self.sliderVelocities[i]
        position = position + (velocity.startTime - self.sliderVelocities[i - 1].startTime) 
                * (self.sliderVelocities[i - 1] and self.sliderVelocities[i - 1].multiplier or 0) * self.trackRounding
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
    if Settings.options["General"].noScrollVelocity then
        return time * self.trackRounding
    end
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
    for _, hitObject in ipairs(self.unspawnNotes) do
        hitObject.initialTrackPosition = self:getPositionFromTime(hitObject.time)
        hitObject.latestTrackPosition = hitObject.initialTrackPosition
        if hitObject.endTime then
            hitObject.endTrackPosition = self:getPositionFromTime(hitObject.endTime)
        end
    end
end

function Gameplay:getNotePosition(offset, initialPos)
    if not Settings.options["General"].downscroll then
        return strumY + (((initialPos or 0) - offset) * Settings.options["General"].scrollspeed / self.trackRounding)
    else
        return strumY - (((initialPos or 0) - offset) * Settings.options["General"].scrollspeed / self.trackRounding)
    end
end


function Gameplay:updateNotePosition(offset, curTime)
    local spritePosition = 0

    for _, hitObject in ipairs(self.hitObjects.members) do
        spritePosition = self:getNotePosition(offset, hitObject.initialTrackPosition)
        if not hitObject.moveWithScroll then
            -- go to strumY (it's a hold)
            spritePosition = strumY
        end
        hitObject.y = spritePosition
        if #hitObject.children > 0 then
            -- Determine the hold notes position and scale
            hitObject.children[1].y = spritePosition + hitObject.height/2
            hitObject.children[2].y = spritePosition + hitObject.height/2

            hitObject.endY = self:getNotePosition(offset, hitObject.endTrackPosition)
            local pixelDistance = hitObject.endY - hitObject.children[1].y + hitObject.children[2].height-- the distance of start and end we need
            hitObject.children[1].scale.y = (pixelDistance / hitObject.children[1].height)

            if Settings.options["General"].downscroll then
                hitObject.children[2].y = hitObject.children[2].y + pixelDistance - hitObject.children[2].height
            else
                hitObject.children[2].y = hitObject.children[2].y + pixelDistance + hitObject.children[2].height
            end
        end
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

function Gameplay:add2(member, pos)
    local pos = pos or -1
    if pos == -1 then
        table.insert(self.members2, member)
    else
        table.insert(self.members2, pos, member)
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

function Gameplay:remove2(member)
    for i, v in ipairs(self.members2) do
        if v == member then
            table.remove(self.members2, i)
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
    Modscript.modifiers = {}
    Modscript:loadModifiers()
    strumY = not Settings.options["General"].downscroll and 50 or 825
    self:reset()

    self.inputsArray = {false, false, false, false}

    self:add(self.strumLineObjects)
    self:add(self.hitObjects)

    self:generateBeatmap(self.chartVer, self.songPath, self.folderpath)
    self.mode = tonumber(self.mode)
    self:generateStrums()

    musicTime = -1000

    self:initializePositionMarkers()
    self:updateCurrentTrackPosition()
    self:initPositions()
    self:updateNotePosition(self.currentTrackPosition, musicTime)
    self:addObjectsToGroups()

    safeZoneOffset = (15 / 60) * 1000

    self:add2(self.comboGroup)

    self:addPlayfield(0, 0) -- Add the main playfield. We need at least one playfield to draw the notes

    Modscript:call("Start")

    if self.watchingReplay then
        -- load most recent replay that has songName and songDifficulty with the highest time in it
        local files = love.filesystem.getDirectoryItems("replays")
        local replay = nil
        local replayTimeCreated = 0
        local allTimes = {}
        -- formatted like "songname - songdifficulty - timecreated.json"
        for i, file in ipairs(files) do
            local replayData = json.decode(love.filesystem.read("replays/" .. file)).meta
            if replayData.song == self.songName and replayData.difficulty == self.difficultyName then
                local filenameData = file:split(" - ")
                local time = tonumber(filenameData[#filenameData]:sub(1, -6))
               
                table.insert(allTimes, time)
                if time > replayTimeCreated then
                    replayTimeCreated = time
                    replay = file
                end
            end
        end

        if replay then
            self.replay = json.decode(love.filesystem.read("replays/" .. replay))
        end

    end

    Timer.after(1.2, function() -- forced delay to prevent potential desync's
        self.updateTime = true
        self.didTimer = true
        previousFrameTime = love.timer.getTime() * 1000
    end)
end

function Gameplay:addObjectsToGroups()
    for i, ho in ipairs(self.unspawnNotes) do
        self.hitObjects:add(ho)
    end
end

function Gameplay:generateStrums()
    -- strumX works with 4 keys by default, modify it for self.mode
    self.strumX = self.strumX - ((self.mode - 4.5) * 100)
    -- update hitobjects x position
    for i, ho in ipairs(self.unspawnNotes) do
        ho.x = self.strumX + ((ho.data - 1) * (__NOTE_OBJECT_WIDTH * 0.925)) + 32
        if #ho.children > 0 then
            ho.children[1].x = self.strumX + ((ho.data - 1) * (__NOTE_OBJECT_WIDTH * 0.925)) + 32
            ho.children[2].x = self.strumX + ((ho.data - 1) * (__NOTE_OBJECT_WIDTH * 0.925)) + 32
        end
    end
    for i = 1, self.mode do
        self.noteoffsets[i] = {x=0, y=0}
        local strum = StrumObject(self.strumX, strumY, i)

        self.strumLineObjects:add(strum)
        strum:postAddToGroup()
    end

    -- generate lane
    self.bgLane.x = self.strumX - ((self.mode - 4) * (__NOTE_OBJECT_WIDTH * 0.0185))
    self.bgLane.width = (__NOTE_OBJECT_WIDTH) * self.mode 
end

function Gameplay:update(dt)
    MenuSoundManager:removeAllSounds() -- a final safe guard to remove any sounds that may have been left over
    if self.inPause then return end
    if self.updateTime then
        if musicTime >= 0 and not self.soundManager:isPlaying("music") and musicTime < 1000 then
            self.soundManager:play("music")
            musicTime = 0
        elseif (musicTime > self.lastNoteTime and not self.soundManager:isPlaying("music")) then
            --self.songName .. " - " .. self.difficultyName,
            self.replay.meta = {
                song = self.songName,
                difficulty = self.difficultyName,
            }
            self.replay.score = {
                score = self.score,
                accuracy = self.accuracy,
                misses = self.misses,
                hits = self.hits,
            }
            if not self.watchingReplay then
                love.filesystem.write("replays/" .. self.songName .. " - " .. self.difficultyName .. " - " .. os.time() .. ".json", json.encode(self.replay))
            end
            state.switch(states.menu.SongMenu)
            if self.background then self.background:release() end
            return
        elseif self.escapeTimer >= 0.7 then
            state.substate(substates.game.Pause)
            self.inPause = true
            self.soundManager:pause("music")
            self.updateTime = false
            return
        else
            if (self.background and self.background.play) and (musicTime >= 0 and musicTime < self.lastNoteTime-1000) and self.soundManager:isPlaying("music") then
                self.background:play(musicTime/1000)
            end
            musicTime = musicTime + (love.timer.getTime() * 1000) - (previousFrameTime or (love.timer.getTime()*1000))
            self.soundManager:update(dt)
            previousFrameTime = love.timer.getTime() * 1000
        end
        self:updateCurrentTrackPosition()
        self:updateNotePosition(self.currentTrackPosition, musicTime)
    end

    Modscript:update(dt, self.soundManager:getBeat("music"))

    for i = 1, self.mode do
        self.strumLineObjects.members[i].offset = self.noteoffsets[i]
    end

    for i, member in ipairs(self.members) do
        if member.update then
            member:update(dt)
        end
    end

    if input:down("back") then
        self.escapeTimer = self.escapeTimer + (dt * 1.87)
    else
        self.escapeTimer = 0
    end

    if self.updateTime then
        if #self.hitObjects.members > 0 then
            if self.didTimer then
                for i, ho in ipairs(self.hitObjects.members) do
                    ho.offset = self.noteoffsets[ho.data]
                    local strum = self.strumLineObjects.members[ho.data]

                    if musicTime - ho.time > self.objectKillOffset and not ho.wasGoodHit then
                        ho.active = false
                        ho.visible = false
                        ho:kill()
                        self.hitObjects:remove(ho)
                        ho:destroy()
                        self:doJudgement(1000) -- miss
                        self.health = self.health - 0.18
                    end
                end
            end
        end
    end

    if not self.watchingReplay then
        for i = 1, self.mode do
            if input:pressed(self.mode .. "k_game" .. i) then
                self:keyPressed(i)
            end
            if input:down(self.mode .. "k_game" .. i) then
                self:keyDown(i)
            end
            if input:released(self.mode .. "k_game" .. i) then
                self:keyReleased(i)
            end
        end
    elseif self.watchingReplay and self.didTimer and self.updateTime then
        for i, hit in ipairs(self.replay.hits) do
            if hit.time <= musicTime and hit.releasedTime >= musicTime and not hit.press then
                hit.press = true
                self:keyPressed(hit.key)
            end

            -- key down
            if hit.time <= musicTime and hit.releasedTime >= musicTime and hit.press then
                self:keyDown(hit.key)
            end

            if hit.releasedTime <= musicTime and not hit.release then
                hit.release = true
                self:keyReleased(hit.key)
            end
        end
    end
end

function Gameplay:keyPressed(key)
    --self.hitsound:clone():setVolume(Settings.options["General"].hitsoundVolume):play()
    local cloned = self.hitsound:clone()
    cloned:setVolume(Settings.options["General"].hitsoundVolume)
    cloned:play()
    cloned:release()

    if not self.watchingReplay then
        table.insert(self.replay.hits, {key=key, time=musicTime, releasedTime=musicTime})
    end

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

function Gameplay:keyReleased(key)
    self.inputsArray[key] = false

    -- find the last note that was pressed (same lane) for replay
    if not self.watchingReplay then
        for i = #self.replay.hits, 1, -1 do
            if self.replay.hits[i].key == key then
                self.replay.hits[i].releasedTime = musicTime
                break
            end
        end
    end

    self.strumLineObjects.members[key]:playAnim("unpressed")

    for i, ho in ipairs(self.hitObjects.members) do
        if ho.data == key and not ho.moveWithScroll then
            ho:kill()
            ho:destroy()
            self.hitObjects:remove(ho)
            break
        end
    end
end

function Gameplay:keyDown(key)
    self.inputsArray[key] = true

    for i, ho in ipairs(self.hitObjects.members) do
        if ho.data == key and not ho.moveWithScroll then -- HOLD NOTE
            -- if in a distance of 15ms, then remove note
            if ho.endTime - musicTime <= -15 then
                ho:kill()
                ho:destroy()
                self.hitObjects:remove(ho)
                break
            end
        end
    end

    self.strumLineObjects.members[key]:playAnim("pressed")
end

function Gameplay:goodNoteHit(note, time)
    if not note.wasGoodHit then
        note.wasGoodHit = true
        self.health = self.health + 0.035

        if not note.isSustainNote then
            self.combo = self.combo + 1
            self.missCombo = 0
            self.hits = self.hits + 1
            self:doJudgement(time)
            if #note.children > 0 then
                note.moveWithScroll = false
            else
                note.visible = false
            end
        end
    end
end

function Gameplay:substateReturn(restarted)
    self.inPause = false
    if not restarted then
        self.soundManager:play("music")
    end
    self.updateTime = true
end

function Gameplay:draw()
    if self.background and musicTime >= 0 then
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.draw(self.background.image or self.background, 0, 0, 0, 1920/self.background:getWidth(), 1080/self.background:getHeight())
    end
    
    for i, spr in pairs(Modscript.funcs.sprites) do
        if not spr.drawWithoutRes and not spr.drawOverNotes then
            spr:draw()
        end
    end


    love.graphics.push()
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", self.bgLane.x, -200, self.bgLane.width, 1080+400) -- 200 val to be safe when the screen is scaling for key's > 4
        love.graphics.setColor(1,1,1)
        for i, playfield in ipairs(self.playfields) do
            playfield:draw(self.hitObjects.members, self.timingLines.members, self.bgLane.width)
        end
    love.graphics.pop()

    -- draw members2
    for i, member in ipairs(self.members2) do
        if member.draw then
            member:draw()
        end
    end

    for i, spr in pairs(Modscript.funcs.sprites) do
        if not spr.drawWithoutRes and spr.drawOverNotes then
            spr:draw()
        end
    end

    love.graphics.setColor(0,0,0, self.escapeTimer)
    love.graphics.rectangle("fill", 0, 0, 1920, 1080)
    love.graphics.setColor(1,1,1,1)

    lerpedScore = math.lerp(lerpedScore, self.score, 0.05)
    lerpedAccuracy = math.lerp(lerpedAccuracy, self.accuracy, 0.05)

    local lastFont = love.graphics.getFont()
    love.graphics.setFont(Cache.members.font["menuBold"])
    love.graphics.printf("Score: " .. math.round(lerpedScore), 0, 0, 960, "right", 0, 2, 2)
    love.graphics.printf("Accuracy: " .. string.format("%.2f", lerpedAccuracy) .. "%", 0, 50, 960, "right", 0, 2, 2)
    love.graphics.setFont(lastFont)
end

function Gameplay:generateBeatmap(chartType, songPath, folderPath)
    self.mode = 4 -- Amount of key lanes, reset to 4 until the chart specifies otherwise
    
    Parsers[chartType].load(songPath, folderPath)

    self.M_folderPath = folderPath -- used for mod scripting
    Modscript.vars = {sprites={}} -- reset modscript vars

    local modPath = folderPath .. "/mod/mod.lua"
    if love.filesystem.getInfo(modPath) then
        Modscript:load(modPath)
    end

    table.sort(self.unspawnNotes, function(a, b)
        return a.time < b.time
    end)

    local lastNoteTime = #self.unspawnNotes > 0 and self.unspawnNotes[#self.unspawnNotes].time or 0
    self.lastNoteTime = lastNoteTime

    self.songName = __title or "N/A"
    self.difficultyName = __diffName or "N/A"
    self.songDuration = self.soundManager:getDuration("music") * 1000

    if discordRPC then
        discordRPC.presence = {
            details = "Playing a song",
            state = self.songName .. " - " .. self.difficultyName,
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
    end

    -- determine noteScore (1m max score and how many notes)
    self.noteScore = self.maxScore / #self.unspawnNotes

    self.soundManager:setBeatCallback("music", function(beat)
        Modscript:call("OnBeat", {beat})
    end)
end

function Gameplay:exit()
    musicTime = 0
end

return Gameplay