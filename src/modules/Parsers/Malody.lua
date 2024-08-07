local malodyLoader = {}
local chart, offset
local noteCount, endNoteTime = 0, 0

local function getTime(bpm, beat, prevOffset) 
    return (1000 * (60/bpm) * beat) + prevOffset 
end

local function getBeat(beat) 
    return beat[1] + (beat[2] / beat[3]) 
end

local function getMilliSeconds(beat, offset)
    local _i = 1

    for i = 1, #chart.time do
        if getBeat(chart.time[i].beat) >= beat then
            break
        end

        offset = getTime(chart.time[i].bpm, getBeat(chart.time[i].beat), offset)
    end

    return getTime(bpm, beat, offset)    
end

function malodyLoader.load(chart_, folderPath, diffName, forNPS)
    noteCount, endNoteTime = 0, 0
    chart = json.decode(love.filesystem.read(chart_))

    local meta = chart.meta

    if meta.mode ~= 0 then
        states.game.Gameplay.mode = meta.mode
    end

    if (meta.mode_ext.column and meta.mode_ext.column ~= 4) then
        states.game.Gameplay.mode = meta.mode_ext.column
    end

    if not forNPS then 
        states.game.Gameplay.strumX = states.game.Gameplay.strumX - ((states.game.Gameplay.mode - 4.5) * (100 + (not forNPS and Settings.options["General"].columnSpacing or 0)))
    end

    -- if theres only 1 timing point, then create 1 more (copy of the first one)
    if #chart.time == 1 then
        chart.time[2] = chart.time[1]
    end

    for i, timingPoint in ipairs(chart.time) do
        if i == 1 then
            bpm = timingPoint.bpm
            crochet = (60 / bpm) * 1000
            stepCrochet = crochet / 4
        end
    end

    for _, note in ipairs(chart.note) do
        if note.type ~= 1 then
            local startTime = getMilliSeconds(getBeat(note.beat), 0)
            local endTime = note.beatEnd and getMilliSeconds(getBeat(note.beatEnd), 0) or 0
            local lane = note.column + 1

            if doAprilFools and Settings.options["Events"].aprilFools then lane = 1; states.game.Gameplay.mode = 1 end

            if not forNPS then
                local ho = HitObject(startTime, lane, endTime)
                table.insert(states.game.Gameplay.unspawnNotes, ho)
            else
                noteCount = noteCount + 1
                endNoteTime = ((endTime and endTime ~= 0) and endTime) or startTime
            end
        else
            if not forNPS then
                states.game.Gameplay.soundManager:newSound("music", folderPath .. "/" .. note.sound, 1, false)
                states.game.Gameplay.soundManager:setBPM("music", bpm)
            end
        end
    end

    __title = chart.meta.song.title
    __diffName = chart.meta.version

    if forNPS then
        states.game.Gameplay.unspawnNotes = {}
        states.game.Gameplay.timingPoints = {}
        states.game.Gameplay.sliderVelocities = {}

        return noteCount / (endNoteTime / 1000)
    end
end

return malodyLoader