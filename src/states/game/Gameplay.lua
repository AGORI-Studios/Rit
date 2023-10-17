local Gameplay = state()

Gameplay.strumX = 525

Gameplay.spawnTime = 1000

Gameplay.hitObjects = Group()
Gameplay.unspawnNotes = {}

Gameplay.strumLineObjects = Group()

Gameplay.songPercent = 0
Gameplay.updateTime = false
Gameplay.endingSong = false
Gameplay.starting = false

Gameplay.songScore = 0
Gameplay.songHits = 0
Gameplay.songMisses = 0

Gameplay.songName = ""

Gameplay.members = {}

Gameplay.chartType = ""

local previousFrameTime -- used for keeping musicTime consistent

function Gameplay:reset()
    self.strumX = 525
    self.spawnTime = 1000
    self.hitObjects = Group()
    self.holdHitObjects = Group()
    self.unspawnNotes = {}
    self.strumLineObjects = Group()
    self.songPercent = 0
    self.updateTime = false
    self.endingSong = false
    self.starting = false
    self.songScore = 0
    self.songHits = 0
    self.songMisses = 0
    self.songName = ""
    self.members = {}
    self.didTimer = false
    self.objectKillOffset = 350
    self.keysArray = {"gameLeft", "gameDown", "gameUp", "gameRight"}
    self.inputsArray = {false, false, false, false}
    self.hitsound = love.audio.newSource("defaultSkins/skinThrowbacks/hitsound.wav", "static")
    self.hitsound:setVolume(0.1)
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

    safeZoneOffset = (10 / 60) * 1000

    Timer.after(0.8, function()
        self.updateTime = true
        self.didTimer = true
    end)
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
        if musicTime >= 0 and not audioFile:isPlaying() then
            audioFile:play()
            audioFile:seek(musicTime / 1000) -- safe measure to keep it lined up
        end
    end

    for i, member in ipairs(self.members) do
        if member.update then
            member:update(dt)
        end
    end

    if self.unspawnNotes[1] then
        local time = self.spawnTime
        if speed < 1 then time = time / speed end

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
                    ho:followStrum(strum, fakeCrocet)

                    if musicTime - ho.time > self.objectKillOffset then
                        ho.active = false
                        ho.visible = false
                        ho:kill()
                        self.hitObjects:remove(ho)
                        ho:destroy()
                    end
                end
            end
        end

        if #self.holdHitObjects.members > 0 then
            if self.didTimer then
                local fakeCrocet = (60 / bpm) * 1000
                for i, ho in ipairs(self.holdHitObjects.members) do
                    local strum = self.strumLineObjects.members[ho.data]
                    ho:followStrum(strum, fakeCrocet)
                    ho:clipToStrum(strum)

                    if musicTime - ho.time > self.objectKillOffset then
                        ho.active = false
                        ho.visible = false
                        ho:kill()
                        self.holdHitObjects:remove(ho)
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
                        self:goodNoteHit(epicNote)
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
                if not note.tooLate and not note.wasGoodHit and note.isSustainNote and self.inputsArray[note.data] then
                    self:goodNoteHit(note)
                end
            end
        end
    end
end

function Gameplay:goodNoteHit(note)
    if not note.wasGoodHit then
        note.wasGoodHit = true
        self.hitsound:clone():play()
        --self.health = self.health + note.hitHealth

        if not note.isSustainNote then
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
    print(chartType, songPath, folderPath)
    if chartType == "Quaver" then
        quaverLoader.load(songPath, folderPath)
    elseif chartType == "osu!" then
        osuLoader.load(songPath, folderPath)
    elseif chartType == "Stepmania" then
        smLoader.load(songPath, folderPath)
    end

    table.sort(self.unspawnNotes, function(a, b)
        return a.time < b.time
    end)
end

return Gameplay