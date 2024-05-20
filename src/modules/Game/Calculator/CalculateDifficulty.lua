local calculateDifficulty = {}

function calculateDifficulty:calculate(song)
    states.game.Gameplay.unspawnNotes = {}
    states.game.Gameplay:generateBeatmap(song.chartType, song.songPath, song.folderPath, song.diffName, true)
    -- use states.game.Gameplay.unspawnNotes for notes for calculating difficult
    local keys = states.game.Gameplay.mode -- 1 - 10
    --                                        1 = 1K, 2 = 2K, etc/
    local notes = states.game.Gameplay.unspawnNotes
    local totalNotes = 0
    local totalNotesPerKey = {}
    for i = 1, keys do
        totalNotesPerKey[i] = 0
    end
    for i, note in ipairs(notes) do
        totalNotes = totalNotes + 1
        totalNotesPerKey[note.data] = totalNotesPerKey[note.data] + 1
    end
    local difficulty = 0
    for i = 1, keys do
        difficulty = difficulty + totalNotesPerKey[i] / totalNotes
    end

    return difficulty
end

return calculateDifficulty