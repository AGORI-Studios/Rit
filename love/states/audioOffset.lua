return {
    enter = function()
        -- offset is in milliseconds
        audioOffset = settings.audioOffset
        offsetTimer = math.abs(audioOffset)
        -- the bpm is 1 tick every tenth of a second
        beatHandler.setBPM(60)

        audio = love.audio.newSource("audio/offsetTest.ogg", "static")
        audio:setLooping(true)

        beatHandler.forceBeat()

        circSize = {50}
    end,

    update = function(self, dt)
        offsetTimer = offsetTimer + dt * 1000
        if not audio:isPlaying() then
            if offsetTimer >= math.abs(audioOffset) then
                audio:play()
                offsetTimer = 0
            end
        end
        beatHandler.update(dt)
        if beatHandler.onBeat() then 
            Timer.tween((60/beatHandler.bpm) / 8, circSize, {100}, "out-quad", function()
                Timer.tween((60/beatHandler.bpm) / 4, circSize, {50}, "in-quad")
            end)
        end
    end,

    keypressed = function(self, key)
    end,

    draw = function()
        love.graphics.circle("fill", graphics.getWidth() / 2, graphics.getHeight() / 2, circSize[1])
    end,

    leave = function()
        audio:stop()
        audio = nil
        offsetTimer = nil
        circSize = nil
        audioOffset = nil
    end
}