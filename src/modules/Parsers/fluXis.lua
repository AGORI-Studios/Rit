local fluXisLoader = {}

function fluXisLoader.load(chart, folderPath_, diffName, forNPS)
    local chart = json.decode(love.filesystem.read(chart))
    local bpm = 0

    states.game.Gameplay.mode = 1

    if chart.EffectFile and love.filesystem.getInfo(folderPath_ .. "/" .. chart.EffectFile) then
        states.game.Gameplay.songEvents = json.decode(love.filesystem.read(folderPath_ .. "/" .. chart.EffectFile))
        --[[ table.sort(states.game.Gameplay.songEvents, function(a, b) return a.time < b.time end) ]]
        if states.game.Gameplay.songEvents.playfieldmove then
            table.sort(states.game.Gameplay.songEvents.playfieldmove, function(a, b) return a.time < b.time end)
        end
        if states.game.Gameplay.songEvents.playfieldscale then
            table.sort(states.game.Gameplay.songEvents.playfieldscale, function(a, b) return a.time < b.time end)
        end
        if states.game.Gameplay.songEvents.playfieldfade then
            table.sort(states.game.Gameplay.songEvents.playfieldfade, function(a, b) return a.time < b.time end)
        end
    end

    if not chart.VideoFile or not video then
        -- just use chart.backgroundFile
        if chart.BackgroundFile and love.filesystem.getInfo(folderPath_ .. "/" .. chart.BackgroundFile) then
            states.game.Gameplay.background = love.graphics.newImage(folderPath_ .. "/" .. chart.BackgroundFile)
        end
    else
        -- use chart.VideoFile
        if love.filesystem.getInfo(folderPath_ .. "/" .. chart.VideoFile) then
            local video_ = love.filesystem.newFileData(folderPath_ .. "/" .. chart.VideoFile)
            states.game.Gameplay.background = Video(video_)
        end
    end

    if not forNPS then
        states.game.Gameplay.soundManager:newSound("music", folderPath_ .. "/" .. chart.AudioFile, 1, true, "stream")
    end

    for _, hitObject in ipairs(chart.HitObjects) do
        local startTime = hitObject.time
        local endTime = hitObject.holdtime or 0
        endTime = endTime + startTime
        if endTime == startTime then endTime = 0 end -- no.
        local lane = hitObject.lane
        local n_Type = hitObject.type -- 0 is a normal note, 1 is a "catch" (TODO: Implement this)
        if n_Type ~= 0 then goto continue end
        local hitsound = hitObject.hitsound or ":normal"

        if lane > states.game.Gameplay.mode then
            states.game.Gameplay.mode = lane
        end

        if doAprilFools and Settings.options["Events"].aprilFools then lane = 1; states.game.Gameplay.mode = 1 end

        if not startTime then goto continue end

        local ho = HitObject(startTime, lane, endTime)
        ho.keySounds = {hitsound}
        table.insert(states.game.Gameplay.unspawnNotes, ho)
        ::continue::
    end

    for _, timingPoint in ipairs(chart.TimingPoints) do
        if timingPoint.bpm then
            bpm = timingPoint.bpm
        end
    end

    if not forNPS then
        states.game.Gameplay.soundManager:setBPM("music", bpm)
    end

    
    __title = chart.Meta
    __diffName = diffName

    if forNPS then
        -- find our average notes per second and return the nps

        local noteCount = #states.game.Gameplay.unspawnNotes
        local songLength = 0
        local endNote = states.game.Gameplay.unspawnNotes[#states.game.Gameplay.unspawnNotes]
        if endNote.endTime ~= 0 and endNote.endTime ~= endNote.time then
            songLength = endNote.endTime
        else
            songLength = endNote.time
        end

        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (songLength / 1000)
    end
end

return fluXisLoader