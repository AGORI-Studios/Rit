local cloneLoader = {}

function cloneLoader.load(chart, folderPath, diffName, forNPS)
    curChart = "CloneHero"

    local chart = clone.parse(chart)

    states.game.Gameplay.mode = 5 -- always 5 key i think idk i dont play clone hero
    states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + Settings.options["General"].columnSpacing))
    if not forNPS then
        states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. chart.meta.MusicStream, 1, true, "stream")
    end

    for i = 1, #chart.notes.ExpertSingle do
        local note = chart.notes.ExpertSingle[i]
        local startTime = note.time
        local endTime = note.time + note.hold
        local lane = note.lane + 1
        if lane == 7 then goto continue end -- ignore "lane 7" because its a special all-lane

        if doAprilFools and Settings.options["Events"].aprilFools then lane = 1; states.game.Gameplay.mode = 1 end

        local ho = HitObject(startTime, lane, endTime)
        table.insert(states.game.Gameplay.unspawnNotes, ho)
        ::continue::
    end

    __title = chart.meta.Name
    __diffName = "ExpertSingle"

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

return cloneLoader