local DifficultyCalculator = {}

-- VSRG Difficulty Calculator based off of note-density (and what Lane its in (Lane))

function DifficultyCalculator:calculate(notes)
    local density = 0
    local densityByLane = {}
    local densityByTime = {}

    for _, note in ipairs(notes) do
        if not densityByLane[note.Lane] then
            densityByLane[note.Lane] = 0
        end

        if not densityByTime[note.StartTime or 0] then
            densityByTime[note.StartTime or 0] = 0
        end

        density = density + 1
        densityByLane[note.Lane] = densityByLane[note.Lane] + 1
        densityByTime[note.StartTime or 0] = densityByTime[note.StartTime or 0] + 1
    end

    local averageDensity = density / #notes

    local standardDeviationAll = 0

    for _, note in ipairs(notes) do
        standardDeviationAll = standardDeviationAll + math.pow(note.Lane - averageDensity, 2)
    end

    standardDeviationAll = math.sqrt(standardDeviationAll / #notes)

    local difficulty = 0

    for _, note in ipairs(notes) do
        difficulty = difficulty + (note.Lane - averageDensity) / standardDeviationAll
    end

    print(difficulty / 125 * 6.2)

    return difficulty / 125 * 6.2
end

return DifficultyCalculator