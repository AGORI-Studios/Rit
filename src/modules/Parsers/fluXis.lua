local fluXisLoader = {}
local noteCount, endNoteTime = 0, 0

function fluXisLoader.load(chart, folderPath_, diffName, forNPS)
    noteCount, endNoteTime = 0, 0
    local chart = json.decode(love.filesystem.read(chart))
    local bpm = 0

    states.game.Gameplay.mode = 1

    if chart.EffectFile and love.filesystem.getInfo(folderPath_ .. "/" .. chart.EffectFile) and not forNPS then
        states.game.Gameplay.songEvents = {}
        Try(
            function()
                states.game.Gameplay.songEvents = json.decode(love.filesystem.read(folderPath_ .. "/" .. chart.EffectFile))
            end,
            function(e)
                print("Error loading effect file: " .. e)
            end
        )

        table.sort(states.game.Gameplay.songEvents.playfieldmove, function(a, b) return a.time < b.time end)
        table.sort(states.game.Gameplay.songEvents.playfieldscale, function(a, b) return a.time < b.time end)
        table.sort(states.game.Gameplay.songEvents.playfieldfade, function(a, b) return a.time < b.time end)
    end

    if not forNPS and (not chart.VideoFile or not video or chart.VideoFile == "") then
        if chart.BackgroundFile and love.filesystem.getInfo(folderPath_ .. "/" .. chart.BackgroundFile) then
            states.game.Gameplay.background = love.graphics.newImage(folderPath_ .. "/" .. chart.BackgroundFile)
        end
    elseif not forNPS then
        if love.filesystem.getInfo(folderPath_ .. "/" .. chart.VideoFile) then
            local video_ = love.filesystem.newFileData(folderPath_ .. "/" .. chart.VideoFile)
            states.game.Gameplay.background = Video(video_)
        end
    end

    if not forNPS then
        states.game.Gameplay.soundManager:newSound("music", folderPath_ .. "/" .. chart.AudioFile, 1, true, "stream")
    end

    for _, hitObject in ipairs(chart.HitObjects) do
        local startTime = hitObject.time or hitObject.Time or 0
        local endTime = hitObject.holdtime or hitObject.HoldTime or 0
        endTime = endTime + startTime
        if endTime == startTime then endTime = 0 end -- no.
        local lane = hitObject.lane or hitObject.Lane or 1
        local n_Type = hitObject.type or hitObject.Type or 0 -- 0 is a normal note, 1 is a "catch" (TODO: Implement this)
        if n_Type ~= 0 and n_Type ~= 1 then goto continue end
        local hitsound = hitObject.hitsound or ":normal"

        if lane > states.game.Gameplay.mode then
            states.game.Gameplay.mode = lane
        end

        if doAprilFools and Settings.options["Events"].aprilFools then lane = 1; states.game.Gameplay.mode = 1 end

        if not startTime then goto continue end

        if not forNPS then
            local ho --= HitObject(startTime, lane, endTime)
            if n_Type == 0 then
                ho = HitObject(startTime, lane, endTime)
            elseif n_Type == 1 then
                ho = CatchObject(startTime, lane)
            end
            ho.keySounds = {hitsound}
            table.insert(states.game.Gameplay.unspawnNotes, ho)
        else
            noteCount = noteCount + 1
            endNoteTime = ((endTime and endTime > 0) and endTime) or startTime
        end
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

    
    __title = chart.Metadata.Title
    __diffName = diffName

    if forNPS then
        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (endNoteTime/ 1000)
    end
end

return fluXisLoader