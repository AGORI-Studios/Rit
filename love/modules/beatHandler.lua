local beatHandler = {}

beatHandler.beat = 0
beatHandler.beatTime = 0

beatHandler.bpm = 0

function beatHandler.setBPM(bpm)
    beatHandler.bpm = bpm
end

function beatHandler.getBeat()
    return beatHandler.beat
end

function beatHandler.getBeatTime()
    return beatHandler.beatTime
end

function beatHandler.update(dt)
    beatHandler.beatTime = beatHandler.beatTime + dt
    if beatHandler.beatTime >= 60 / beatHandler.bpm then
        beatHandler.beat = beatHandler.beat + 1
        beatHandler.beatTime = 0
    end
end

return beatHandler