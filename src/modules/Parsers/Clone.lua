local cloneLoader = {}
local noteCount, endNoteTime = 0, 0

function cloneLoader.load(chart, folderPath, diffName, forNPS)
    noteCount, endNoteTime = 0, 0
    curChart = "CloneHero"

    local chart = clone.parse(chart)

    states.game.Gameplay.mode = 5 -- always 5 key i think idk i dont play clone hero
    states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + (not forNPS and Settings.options["General"].columnSpacing or 0)))
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

        if not forNPS then
            local ho = HitObject(startTime, lane, endTime)
            table.insert(states.game.Gameplay.unspawnNotes, ho)
        else
            noteCount = noteCount + 1
            endNoteTime = ((endTime and endTime ~= 0) and endTime) or startTime
        end
        ::continue::
    end

    __title = chart.meta.Name
    __diffName = "ExpertSingle"

    if forNPS then
        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (endNoteTime / 1000)
    end
end

return cloneLoader