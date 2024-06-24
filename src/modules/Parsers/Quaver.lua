local quaverLoader = {}

function quaverLoader.load(chart, folderPath, diffName, forNPS)
    curChart = "Quaver"

    local chart = tinyyaml.parse(love.filesystem.read(chart):gsub("\r\n", "\n"))
    
    local meta = {
        format = "Quaver",
        title = chart.Title,
        artist = chart.Artist,
        source = chart.Source,
        tags = chart.Tags,
        name = chart.DifficultyName,
        creator = chart.Creator,
        audioPath = chart.AudioFile,
        backgroundFile = chart.BackgroundFile,
        previewTime = chart.PreviewTime or 0,
        noteCount = 0,
        length = 0,
        bpm = 0,
        inputMode = chart.Mode:gsub("Keys", ""),
    }
    states.game.Gameplay.mode = meta.inputMode
    states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + Settings.options["General"].columnSpacing))
    states.game.Gameplay.bpmAffectsScrollVelocity = not chart.BPMDoesNotAffectScrollVelocity

    if not forNPS then
        states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. meta.audioPath, 1, true, "stream")
    end

    if not forNPS then
        for i = 1, #chart.TimingPoints do
            -- if its the first one, set meta.bpm to the bpm of the first timing point
            local timingPoint = chart.TimingPoints[i]
            if i == 1 then
                meta.bpm = timingPoint.Bpm
                bpm = meta.bpm
                crochet = (60/bpm)*1000
                stepCrochet = crochet/4
            end
            table.insert(states.game.Gameplay.timingPoints, timingPoint)
        end
    end
    if not forNPS then
        states.game.Gameplay.soundManager:setBPM("music", bpm)
    end

    states.game.Gameplay.initialScrollVelocity = chart.InitialScrollVelocity or 1

    if love.filesystem.getInfo(folderPath .. "/" .. meta.backgroundFile) then
        states.game.Gameplay.background = love.graphics.newImage(folderPath .. "/" .. meta.backgroundFile)
    end

    for i = 1, #chart.SliderVelocities do
        local sliderVelocity = chart.SliderVelocities[i]
        local startTime = sliderVelocity.StartTime
        local multiplier = sliderVelocity.Multiplier
        if not startTime then goto continue end
        table.insert(states.game.Gameplay.sliderVelocities, {startTime = startTime, multiplier = multiplier or 0})
        ::continue::
    end

    for i = 1, #chart.HitObjects do
        local hitObject = chart.HitObjects[i]
        local startTime = hitObject.StartTime
        local endTime = hitObject.EndTime or 0
        local lane = hitObject.Lane

        if doAprilFools and Settings.options["Events"].aprilFools then lane = 1; states.game.Gameplay.mode = 1 end

        if not startTime then goto continue end

        local ho = HitObject(startTime, lane, endTime)
        ho.keySounds = hitObject.KeySounds or {}
        table.insert(states.game.Gameplay.unspawnNotes, ho)
        ::continue::
    end

    __title = meta.title
    __diffName = meta.name

    if forNPS then
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

return quaverLoader