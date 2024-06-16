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

Gameplay.bpmAffectsScrollVelocity = false

Gameplay.allJudgements = {}

Gameplay.gameModes = {
    "Mania",
    "TBD"
}

Gameplay.eventTimers = {}

local lerpedScore = 0
local lerpedAccuracy = 0

local comboTimer = {}
local judgeTimer = {}

local networkingUpdateTime = 0 -- every 5 seconds, refresh players info

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
    self.lastNoteIsFinish = true
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
    self.members = {}
    self.members2 = {}
    self.didTimer = false
    self.objectKillOffset = 350
    self.inputsArray = {false, false, false, false}
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
    self.firstNoteTime = 0
    self.hasSkipPeriod = false

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

    self.judgements = {
        { name = "marvellous",  img = "defaultSkins/skinThrowbacks/judgements/MARVELLOUS.png",  time = 23,   scoreMultiplier = 1,     weight = 125.000 },
        { name = "perfect",     img = "defaultSkins/skinThrowbacks/judgements/PERFECT.png",     time = 40,   scoreMultiplier = 0.93,  weight = 122.950 },
        { name = "great",       img = "defaultSkins/skinThrowbacks/judgements/GREAT.png",       time = 74,   scoreMultiplier = 0.7,   weight =  81.963 },
        { name = "good",        img = "defaultSkins/skinThrowbacks/judgements/GOOD.png",        time = 103,  scoreMultiplier = 0.55,  weight =  40.975 },
        { name = "bad",         img = "defaultSkins/skinThrowbacks/judgements/BAD.png",         time = 127,  scoreMultiplier = 0.3,   weight =  20.488 },
        { name = "miss",        img = "defaultSkins/skinThrowbacks/judgements/MISS.png",        time = 160,  scoreMultiplier = 0,     weight =   0.000 }
    }

    self.allJudgements = {}
    for i, judge in ipairs(self.judgements) do
        self.allJudgements[judge.name] = 0 -- judgement count (Used for accuracy calculation)
    end

    musicTime = 0

    self.escapeTimer = 0

    self.timingPoints = {}

    self.eventTimers = {}

    currentController = gameController
    Modscript:reset()
end

function Gameplay:calculateAccuracy()
    local marvCount, perfCount, greatCount, goodCount, badCount, missCount = self.allJudgements.marvellous, self.allJudgements.perfect, self.allJudgements.great,
                                                                            self.allJudgements.good, self.allJudgements.bad, self.allJudgements.miss

    local marvWeight, perfWeight, greatWeight, goodWeight, badWeight, missWeight = self.judgements[1].weight, self.judgements[2].weight, self.judgements[3].weight,
                                                                                    self.judgements[4].weight, self.judgements[5].weight, self.judgements[6].weight

    local hits = marvCount + perfCount + greatCount + goodCount + badCount + missCount

    local CUR = (marvCount * marvWeight) + (perfCount * perfWeight) + (greatCount * greatWeight) + (goodCount * goodWeight) + (badCount * badWeight)
    local MAX = hits * marvWeight

    return (CUR / MAX) * 100
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

    self.accuracy = self:calculateAccuracy() 
    if tostring(self.accuracy) == "nan" then self.accuracy = 0 end

    self.allJudgements[judgement.name] = self.allJudgements[judgement.name] + 1

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
        position = position + (velocity.startTime - (self.sliderVelocities[i - 1] and self.sliderVelocities[i - 1].startTime or 0)) 
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
    curPos = curPos + (time - self.sliderVelocities[index].startTime) * (self.sliderVelocities[index].multiplier or 0) * self.trackRounding
    return curPos
end

function Gameplay:getPositionFromTime(time)
    local _i = 1
    for i = 1, #self.sliderVelocities do
        if time <= self.sliderVelocities[i].startTime then
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
        if (self.sliderVelocities[i].multiplier or 0) ~= 0 then
            i_ = i
            break
        end
    end

    if i_ <= 0 then
        return self.initialScrollVelocity < 0
    end

    return (self.sliderVelocities[i_].multiplier or 0) < 0
end

function Gameplay:getCommonBpm()
    if #self.timingPoints == 0 then
        print("No timing points found")
        return 0
    end

    if #self.unspawnNotes == 0 then
        print("No notes found")
        return self.timingPoints[1].Bpm
    end

    --var lastObject = HitObjects.OrderByDescending(x => x.IsLongNote ? x.EndTime : x.StartTime).First();
    -- gets the very last note, accounting for the endTime
    local newNoteTable = {}
    for i, note in ipairs(self.unspawnNotes) do
        table.insert(newNoteTable, note)
    end

    -- table.sort
    table.sort(newNoteTable, function(a, b)
        if a.endTime and b.endTime then
            return a.endTime > b.endTime
        elseif a.endTime and not b.endTime then
            return a.endTime > b.time
        elseif not a.endTime and b.endTime then
            return a.time > b.endTime
        else
            return a.time > b.time
        end
    end)
    local lastObject = newNoteTable[1]
    local lastTime = lastObject.endTime or lastObject.time

    local durations = {}
    for i = 1, #self.timingPoints do
        local point = self.timingPoints[i]

        if point.StartTime > lastTime then
            break
        end
        local duration = (lastTime - (i == 1 and 0 or point.StartTime))
        lastTime = point.StartTime

        if table.find(durations, point.Bpm) then
            durations[point.Bpm] = durations[point.Bpm] + duration
        else
            durations[point.Bpm] = duration
        end
    end

    if #durations == 0 then
        return self.timingPoints[1].Bpm
    end

    table.sort(durations, function(a, b)
        return a > b
    end)

    print("Common BPM: " .. durations[1])

    return durations[1]
end

function Gameplay:normalizeSVs()
    if not self.bpmAffectsScrollVelocity then return end

    print("Normalizing SVs")

    local baseBpm = self:getCommonBpm()

    local normalizedScrollVelocities = {}

    local currentBpm = self.timingPoints[1].Bpm
    local currentSvIndex = 1
    local currentSvStartTime
    local currentSvMultiplier = 1
    local currentAdjustedSvMultiplier
    local initialSvMultiplier

    for i = 1, #self.timingPoints do
        local timingPoint = self.timingPoints[i]

        local nextTimingPointHasSameTimestamp = false
        if (i + 1 < #self.timingPoints and self.timingPoints[i + 1].StartTime == timingPoint.StartTime) then
            nextTimingPointHasSameTimestamp = true
        end

        while(true) do
            if currentSvIndex >= #self.sliderVelocities then
                break
            end

            local sv = self.sliderVelocities[currentSvIndex]
            if sv.startTime > timingPoint.StartTime then
                break
            end

            if (nextTimingPointHasSameTimestamp and sv.startTime == timingPoint.StartTime) then
                break
            end

            if (sv.startTime <= timingPoint.StartTime) then
                local multiplier = (sv.Multiplier or 0) * (currentBpm / baseBpm)

                if not currentAdjustedSvMultiplier then
                    currentAdjustedSvMultiplier = multiplier
                    initialSvMultiplier = (sv.Multiplier or 0)
                end

                if multiplier ~= currentAdjustedSvMultiplier then
                    table.insert(normalizedScrollVelocities, {
                        startTime = sv.startTime,
                        multiplier = multiplier
                    })
                    currentAdjustedSvMultiplier = multiplier
                end
            end

            currentSvStartTime = sv.startTime
            currentSvMultiplier = (sv.Multiplier or 0)
            currentSvIndex = currentSvIndex + 1
        end

        if not currentSvStartTime or currentSvStartTime < timingPoint.StartTime then
            currentSvMultiplier = 1
        end
        currentBpm = timingPoint.Bpm

        local multiplierToo = currentSvMultiplier * (currentBpm/baseBpm)

        if not currentAdjustedSvMultiplier then
            currentAdjustedSvMultiplier = multiplierToo
            initialSvMultiplier = currentSvMultiplier
        end

        if multiplierToo ~= currentAdjustedSvMultiplier then
            table.insert(normalizedScrollVelocities, {
                startTime = timingPoint.StartTime,
                multiplier = multiplierToo
            })
            currentAdjustedSvMultiplier = multiplierToo
        end
    end

    -- for (; currentSvIndex < SliderVelocities.Count; currentSvIndex++)
    for i = currentSvIndex, #self.sliderVelocities do
        local sv = self.sliderVelocities[i]
        local multiplier = (sv.multiplier or 0) * (currentBpm / baseBpm)

        if multiplier ~= currentAdjustedSvMultiplier then
            table.insert(normalizedScrollVelocities, {
                startTime = sv.startTime,
                multiplier = multiplier
            })
            currentAdjustedSvMultiplier = multiplier
        end

        currentSvIndex = currentSvIndex + 1
    end

    self.initialScrollVelocity = initialSvMultiplier or 1
    self.sliderVelocities = normalizedScrollVelocities
end

function Gameplay:SVFactor()
    local MIN_MULTIPLIER = 1e-3
    local MAX_MULTIPLIER = 1e2

    self:normalizeSVs()

    local importantTimestamps = {}
    for i = 1, #self.unspawnNotes do
        local note = self.unspawnNotes[i]
        table.insert(importantTimestamps, note.time)
        if note.children[1] then
            table.insert(importantTimestamps, note.endTime)
        end
    end
    table.sort(importantTimestamps, function(a, b)
        return a < b
    end)
    local nextImportantTimeStampIndex = 1

    local sum = 0
    for i = 2, #self.sliderVelocities do
        local prevSv = self.sliderVelocities[i - 1]
        local sv = self.sliderVelocities[i]

        while (nextImportantTimeStampIndex < #importantTimestamps and importantTimestamps[nextImportantTimeStampIndex] < sv.startTime) do
            nextImportantTimeStampIndex = nextImportantTimeStampIndex + 1
        end

        if (nextImportantTimeStampIndex >= #importantTimestamps or importantTimestamps[nextImportantTimeStampIndex] > sv.startTime + 1000) then
            break
        end

        local prevMultiplier = math.min(math.max(math.abs((prevSv.multiplier or 0)), MIN_MULTIPLIER), MAX_MULTIPLIER)
        local multiplier = math.min(math.max(math.abs((sv.multiplier or 0)), MIN_MULTIPLIER), MAX_MULTIPLIER)

        local prevLogMultiplier = math.log(prevMultiplier)
        local logMultiplier = math.log(multiplier)

        sum = sum + math.abs(logMultiplier - prevLogMultiplier)
    end

    return sum
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
    if not Modscript.downscroll then
        return strumY + (((initialPos or 0) - offset) * Settings.options["General"].scrollspeed / self.trackRounding)
    else
        return strumY - (((initialPos or 0) - offset) * Settings.options["General"].scrollspeed / self.trackRounding)
    end
end


function Gameplay:updateNotePosition(offset, curTime)
    local spritePosition = 0

    for _, hitObject in ipairs(self.hitObjects.members) do
        --[[ hitObject.offset.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
        hitObject.offset.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
        hitObject.offset.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
        hitObject.rotation.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
        hitObject.rotation.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
        hitObject.rotation.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25 ]]

        if hitObject.time - musicTime > 15000 then -- Only update notes that are within 15 seconds of the current time to prevent lag issues from too many notes
            break
        end
        spritePosition = self:getNotePosition(offset, hitObject.initialTrackPosition)
        if not hitObject.moveWithScroll then
            -- go to strumY (it's a hold)
            spritePosition = strumY
        end
        hitObject.y = spritePosition
        --[[ hitObject.y = math.sin((curTime - hitObject.time) / 1000 * math.pi) * 10 + spritePosition ]]
        if #hitObject.children > 0 then
            -- Determine the hold notes position and scale
            hitObject.children[1].y = spritePosition + 100
            hitObject.children[2].y = spritePosition + 100
            -- This code doesn't exist. You're just going crazy.
            --[[ 
            hitObject.children[1].offset.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[1].offset.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[1].offset.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[1].rotation.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[1].rotation.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[1].rotation.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[2].offset.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[2].offset.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[2].offset.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[2].rotation.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[2].rotation.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            hitObject.children[2].rotation.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * hitObject.data) * 25
            ]]
            hitObject.endY = self:getNotePosition(offset, hitObject.endTrackPosition)
            local pixelDistance = hitObject.endY - hitObject.children[1].y + 100-- the distance of start and end we need
            hitObject.children[1].dimensions = {width = 200, height = pixelDistance}
            hitObject.children[2].dimensions = {width = 200, height = 100--[[  * (not (Settings.options["General"].skin.flippedEnd or false) and 1 or -1)-} ]]}

            if Modscript.downscroll then
                hitObject.children[2].y = hitObject.children[2].y + pixelDistance - 100
            else
                hitObject.children[2].y = hitObject.children[2].y + pixelDistance + 100
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
    self:reset()
    strumY = not Modscript.downscroll and 50 or 825

    self.inputsArray = {false, false, false, false}

    self:add(self.strumLineObjects)
    self:add(self.hitObjects)

    self:generateBeatmap(self.chartVer, self.songPath, self.folderpath, self.difficultyName)

    musicTime = -1000

    self:initializePositionMarkers()
    self:updateCurrentTrackPosition()
    self:initPositions()
    self:updateNotePosition(self.currentTrackPosition, musicTime)
    self:addObjectsToGroups()

    safeZoneOffset = 160 -- start/end ms time for a note to be able to be hit

    self:add2(self.comboGroup)

    self:addPlayfield(0, 0) -- Add the main playfield. We need at least one playfield to draw the notes

    if self.ableToModscript then
        Modscript:call("Start")
    end

    if self.watchingReplay then
        -- load most recent replay that has songName and songDifficulty with the highest time in it
        local files = love.filesystem.getDirectoryItems("replays")
        local replay = nil
        local replayTimeCreated = 0
        local allTimes = {}
        -- formatted like "songname - songdifficulty - timecreated.ritreplay"
        for i, file in ipairs(files) do
            local replayData = json.decode(love.filesystem.read("replays/" .. file)).meta
            if replayData.song == self.songName and replayData.difficulty == self.difficultyName then
                local filenameData = file:split(" - ")
                local time = tonumber(filenameData[#filenameData]:sub(1, -6))

                table.insert(allTimes, time)
                if time > replayTimeCreated then
                    ---@diagnostic disable-next-line: cast-local-type
                    replayTimeCreated = time
                    replay = file
                end
            end
        end

        if replay then
            self.replay = json.decode(love.filesystem.read("replays/" .. replay))
        end

    end

    if shaders and shaders.backgroundEffects then
        shaders.backgroundEffects:send("dim", Settings.options["General"].backgroundDim)
    end
    --shaders.backgroundEffects:send("blurIntensity", 0)

    Timer.after(1.2, function() -- forced delay to prevent potential desync's
        self.updateTime = true
        self.didTimer = true
        previousFrameTime = love.timer.getTime() * 1000
    end)
end

function Gameplay:addObjectsToGroups()
    for i, ho in ipairs(self.unspawnNotes) do
        ho.x = self.strumLineObjects.members[ho.data].x
        if #ho.children > 0 then
            ho.children[1].x = ho.x
            ho.children[2].x = ho.x
        end
        self.hitObjects:add(ho)
    end
end

function Gameplay:generateStrums()
    --self.bgLane.x = self.strumX - ((self.mode - 4) * (200 * 0.0185))
    -- above code, but with Settings.options["General"].columnSpacing
    self.strumX = self.strumX - (self.mode * Settings.options["General"].columnSpacing) / 2
    self.bgLane.x = self.strumX - ((self.mode - 4) * ((200 + Settings.options["General"].columnSpacing) * 0.0185))
    for i = 1, self.mode do
        self.noteoffsets[i] = {x=0, y=0}
        local strum = StrumObject(self.strumX, strumY, i)

        self.strumLineObjects:add(strum)
        strum:postAddToGroup()
    end

    --self.bgLane.width = self.mode * (200 + Settings.options["General"].columnSpacing + 10)
    -- 10 is for columnSpacing == 0, accomodate for that
    -- do some math to convert the 10 to other values. Higher columnSpacing = higher number
    -- Lower columnSpacing = lower number
    local normalPadding = 12
    normalPadding = normalPadding / (Settings.options["General"].columnSpacing * 1.25 + 1)
    self.bgLane.width = self.mode * (200 + Settings.options["General"].columnSpacing + normalPadding)
end

function Gameplay:updateEvents()
    if not self.songEvents then return end
    if self.songEvents.playfieldmove then
        for i, event in ipairs(self.songEvents.playfieldmove) do
            if musicTime >= event.time then
                -- the 0.9 scaling is here due to the difference in size of fluXis' and Rit's playfields
                local x = (event.x or 0) * 0.9
                local y = (event.y or 0) * 0.9
                local duration = event.duration--[[ /1000 or 0 ]] or 0
                if duration ~= 0 then duration = duration/1000 end
                local ease = event.ease or 10 -- TODO: Find out the ease equivalency.
                local playfield = self.playfields[1]
                
                self.eventTimers[tostring(event.time) .. "_moveEvent"] = Timer.tween(
                    duration, playfield.offsets, {x = x, y = y}, "linear"
                )

                table.remove(self.songEvents.playfieldmove, i)
                break
            else
                break
            end
        end
    end
    if self.songEvents.playfieldfade then
        for i, event in ipairs(self.songEvents.playfieldfade) do
            if musicTime >= event.time then
                local alpha = event.alpha or 0
                local duration = event.duration--[[ /1000 or 0 ]] or 0
                if duration ~= 0 then duration = duration/1000 end
                local ease = event.ease or 10 -- TODO: Find out the ease equivalency.
                local playfield = self.playfields[1]
                
                self.eventTimers[tostring(event.time) .. "_fadeEvent"] = Timer.tween(
                    duration, playfield, {alpha=alpha}, "out-quad"
                )

                table.remove(self.songEvents.playfieldfade, i)
                break
            else
                break
            end
        end
    end
end

function Gameplay:update(dt)
    networkingUpdateTime = networkingUpdateTime + dt
    if networkingUpdateTime >= 1.25 and Steam and networking.inMultiplayerGame and networking.connected then
        networkingUpdateTime = 0
        networking.hub:publish({
            message = {
                action = "getPlayersInfo_INGAME",
                id = networking.currentServerData.id,
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName),
                    score = self.score,
                    accuracy = self.accuracy,
                    completed = false
                }
            }
        })
    end
    MenuSoundManager:removeAllSounds() -- a final safe guard to remove any sounds that may have been left over
    if self.inPause then return end
    if self.updateTime then
        if musicTime >= 0 and not self.soundManager:isPlaying("music") and musicTime < 1000 then
            self.soundManager:play("music")
            musicTime = 0
        elseif ((self.lastNoteIsFinish and musicTime > self.lastNoteTime+750) or (not self.lastNoteIsFinish and not self.soundManager:isPlaying("music") and musicTime > self.lastNoteTime+750)) then
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
                love.filesystem.write("replays/" .. self.songName .. " - " .. self.difficultyName .. " - " .. os.time() .. ".ritreplay", json.encode(self.replay))
            end
            if Steam and networking.connected and networking.currentServerData and networking.inMultiplayerGame then
                switchState(states.menu.StartMenu, 0.3, nil, {score = self.score, accuracy = self.accuracy, misses = self.misses, maxCombo = self.combo})
                MenuSoundManager:removeAllSounds()
                self.soundManager:removeAllSounds()
            else
                switchState(states.menu.StartMenu, 0.3)
                MenuSoundManager:removeAllSounds()
            end
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
        if musicTime <= self.firstNoteTime and self.hasSkipPeriod and input:pressed("Skip_Key") then
            if (self.background and self.background.play) and (musicTime >= 0 and musicTime < self.lastNoteTime-1000) and self.soundManager:isPlaying("music") then
                self.background:play(musicTime/1000)
                self.soundManager:seek("music", musicTime/1000, "seconds")
            end
            musicTime = 2000
            self.hasSkipPeriod = false
        end
        self:updateCurrentTrackPosition()
        if not self.ableToModscript then -- Use default note positioning
            self:updateNotePosition(self.currentTrackPosition, musicTime)
        end
    end

    if self.ableToModscript then
        Modscript:update(dt, self.soundManager:getBeat("music"))
    end

    if self.updateTime then
        self:updateEvents()
    end

    --[[ for i = 1, self.mode do -- erm... what the sigma?
        -- use i for modifying offserts
        self.strumLineObjects.members[i].offset.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * i) * 25
        self.strumLineObjects.members[i].offset.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * i) * 25
        self.strumLineObjects.members[i].offset.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * i) * 25
        self.strumLineObjects.members[i].rotation.x = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * i) * 25
        self.strumLineObjects.members[i].rotation.y = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * i) * 25
        self.strumLineObjects.members[i].rotation.z = math.sin((musicTime - self.firstNoteTime) / 1000 * math.pi * i) * 25
    end ]]

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

function Gameplay:substateReturn(restarted, leftGame)
    self.inPause = false
    if restarted then
        self.soundManager:removeAllSounds()
    end
    if not restarted or not leftGame then
        self.soundManager:play("music")
    end
    self.updateTime = true
end

function Gameplay:draw()
    if self.background and musicTime >= 0 then
        -- background dim is 0-1, 0 being no dim, 1 being full dbackgroundim
        --love.graphics.setColor(1, 1, 1, Settings.options["General"].backgroundDim)
        if shaders and shaders.backgroundEffects then
            love.graphics.setShader(shaders.backgroundEffects)
        end
        love.graphics.draw(
            self.background and self.background.image or self.background, 
            0, 0, 0, 
            1920/self.background:getWidth(), 1080/self.background:getHeight()
        )
        love.graphics.setShader()
    end
    
    for i, spr in pairs(Modscript.funcs.sprites) do
        if not spr.drawWithoutRes and not spr.drawOverNotes then
            spr:draw()
        end
    end

    local lastFont = love.graphics.getFont()
    love.graphics.setFont(Cache.members.font["menuBold"])
    if Steam and networking.inMultiplayerGame and networking.currentServerData then
        for i, player in ipairs(networking.currentServerData.players) do
            love.graphics.setColor(0, 0, 0, 0.5)
            -- small box for the players
            love.graphics.rectangle("fill", 0, 400 + (i * 100), 300, 100)
            love.graphics.setColor(1, 1, 1)
            local text = player.name

            if table.find(player.tags, "Owner") then -- Game owner
                text = text .. " (Owner)"
            elseif table.find(player.tags, "Admin") then -- Admin
                text = text .. " (Admin)"
            elseif table.find(player.tags, "Mod") then -- Moderator
                text = text .. " (Mod)"
            elseif table.find(player.tags, "Developer") then -- Developers
                text = text .. " (Developer)"
            elseif table.find(player.tags, "Supporter") then -- Supporters
                text = text .. " (Supporter)"
            end
            love.graphics.print(text, 10, 400 + (i * 100))
            love.graphics.print("Score: " .. (math.floor(player.score) or 0), 10, 420 + (i * 100)) 
            love.graphics.print("Accuracy: " .. (string.format("%.2f", player.accuracy or 0) .. "%"), 10, 440 + (i * 100))
        end
    end
    love.graphics.setFont(lastFont)

    love.graphics.push()
        local scale = 1 - ((self.mode - 4) * 0.05)
        love.graphics.push()
            love.graphics.translate(Inits.GameWidth/2, Inits.GameHeight/2)
            -- scale based off of the mode,
            -- the mid point is 4. 4 would be a scale of 1
            love.graphics.scale(scale*Settings.options["General"].noteSize, scale*Settings.options["General"].noteSize)
            love.graphics.translate(-Inits.GameWidth/2, -Inits.GameHeight/2)
            -- move down the playfield based off scale, 4 = 0
            love.graphics.translate(0, (self.mode - 4) * 25)
            for i, playfield in ipairs(self.playfields) do
                playfield:draw(self.hitObjects.members, self.timingLines.members, self.bgLane.width, scale*Settings.options["General"].noteSize, self.bgLane.x)
            end
        love.graphics.pop()
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
    love.graphics.printf(localize.localize("Score: ") .. math.round(lerpedScore), 0, 0, 960, "right", 0, 2, 2)
    love.graphics.printf(localize.localize("Accuracy: ") .. string.format("%.2f", lerpedAccuracy) .. "%", 0, 50, 960, "right", 0, 2, 2)

    if musicTime <= self.firstNoteTime and self.hasSkipPeriod and input:pressed("Skip_Key") then
        -- right align
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf(localize.localize("Press SPACE to skip intro"), 0, Inits.GameWidth-50, 960, "right", 0, 2, 2)
    end

    love.graphics.setFont(lastFont)
end

function Gameplay:generateBeatmap(chartType, songPath, folderPath, diffName, forDiffCalc)
    self.mode = 4 -- Amount of key lanes, reset to 4 until the chart specifies otherwise
    Parsers[chartType].load(songPath, folderPath, diffName, forDiffCalc)

    --self:normalizeSVs()
    --self:SVFactor()
    table.sort(self.unspawnNotes, function(a, b)
        return a.time < b.time
    end)

    local lastNoteTime = #self.unspawnNotes > 0 and self.unspawnNotes[#self.unspawnNotes].time or 0
    self.lastNoteTime = lastNoteTime
    local firstNoteTime = #self.unspawnNotes > 0 and self.unspawnNotes[1].time or 0
    self.firstNoteTime = firstNoteTime
    self.hasSkipPeriod = firstNoteTime > 2500 -- if first note is after 7.5 seconds, then we have a skip period
    --print("First note time: " .. firstNoteTime .. "\nLast note time: " .. lastNoteTime .. "\nSkip period: " .. tostring(self.hasSkipPeriod))

    self.songName = __title or "N/A"
    self.difficultyName = __diffName or "N/A"
    if not forDiffCalc then
        self.songDuration = self.soundManager:getDuration("music") * 1000
        self.M_folderPath = folderPath -- used for mod scripting
        Modscript.vars = {sprites={}} -- reset modscript vars

        self.mode = tonumber(self.mode)
        self:generateStrums()
        local modPath = folderPath .. "/mod/mod.lua"
        if love.filesystem.getInfo(modPath) then
            self.ableToModscript = Modscript:load(modPath)
        end

        if discordRPC then
            local details = ""
            if networking and networking.inMultiplayerGame then
                details = "In a multiplayer game - " .. networking.currentServerData.name .. " (" .. #networking.currentServerData.players .. "/" .. networking.currentServerData.maxPlayers .. ")"
            else
                details = "Playing a song"
            end
            discordRPC.presence = {
                details = details,
                state = self.songName .. " - " .. self.difficultyName,
                largeImageKey = "totallyreallogo",
                largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
            }
            GameInit.UpdateDiscord()
        end

        -- determine noteScore (1m max score and how many notes)
        self.noteScore = self.maxScore / #self.unspawnNotes

        if self.ableToModscript then
            self.soundManager:setBeatCallback("music", function(beat)
                Modscript:call("OnBeat", {beat})
            end)
        end
    end
end

function Gameplay:exit()
    musicTime = 0
    currentController = menuController
end

return Gameplay
