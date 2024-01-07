local SoundManager = Object:extend()

function SoundManager:new()
    self.channel = {}
    self.soundData = {}
end

function SoundManager:newSound(name, path, volume, loop, type)
    local volume = volume or 1
    local loop = loop or false
    if not path then return end
    if _G.type(path) == "string" then
        self.soundData[name] = love.sound.newSoundData(path)
    else -- already a sounddata (assumed)
        self.soundData[name] = path
    end
    self.channel[name] = {
        sound = love.audio.newSource(self.soundData[name], type or "stream"),
        volume = volume,
        loop = loop,
        bpm = 120,
        beat = 0,
        beatLength = 60 / 120,
        time = 0,
        lastFrameTime = 0,
        onBeat = function() end,
        paused = false
    }
end

function SoundManager:play(name, clone)
    self.channel[name].paused = false
    if clone then
        local clone = self.channel[name].sound:clone()
        clone:play()
        return clone
    else
        if not self.channel[name] then return end
        self.channel[name].sound:play()
        return self.channel[name].sound
    end
end

function SoundManager:update(dt)
    for k, v in pairs(self.channel) do
        if v.lastFrameTime == 0 then
            v.lastFrameTime = love.timer.getTime()
        end
        v.time = v.time + (love.timer.getTime() - v.lastFrameTime)
        v.lastFrameTime = love.timer.getTime()
        if v.time >= v.beatLength then
            v.beat = v.beat + 1
            v.time = 0
            v.onBeat(v.beat)
        end
        v.sound:setVolume(v.volume)
    end
end

function SoundManager:removeAllSounds()
    for k, v in pairs(self.channel) do
        v.sound:stop()
        v.sound:release()
        self.channel[k] = nil
    end
end

function SoundManager:stop(name)
    if not self.channel[name] then return end
    self.channel[name].sound:stop()
end

function SoundManager:pause(name)
    self.channel[name].paused = true
    self.channel[name].sound:pause()
end

function SoundManager:resume(name)
    self.channel[name].sound:resume()
end

function SoundManager:isPlaying(name)
    return self.channel[name].sound:isPlaying()
end

function SoundManager:isPaused(name)
    return self.channel[name].paused
end

function SoundManager:isStopped(name)
    return self.channel[name].sound:isStopped()
end

function SoundManager:setVolume(name, volume)
    self.channel[name].volume = volume
    self.channel[name].sound:setVolume(volume)
end

function SoundManager:setLooping(name, loop)
    self.channel[name].loop = loop
    self.channel[name].sound:setLooping(loop)
end

function SoundManager:getLooping(name)
    return self.channel[name].loop
end

function SoundManager:setBPM(name, bpm)
    self.channel[name].bpm = bpm
    self.channel[name].beatLength = 60 / bpm
end

function SoundManager:getBeat(name)
    return self.channel[name].beat
end

function SoundManager:getBeatLength(name)
    return self.channel[name].beatLength
end

function SoundManager:getTime(name)
    return self.channel[name].time
end

function SoundManager:getLastFrameTime(name)
    return self.channel[name].lastFrameTime
end

function SoundManager:getSound(name)
    return self.channel[name].sound
end

function SoundManager:seek(name, seconds, unit)
    self.channel[name].sound:seek(seconds or 0, unit or "seconds")
end

function SoundManager:tell(name, unit)
    return self.channel[name].sound:tell(unit)
end

function SoundManager:clone(name)
    return self.channel[name].sound:clone()
end

function SoundManager:getDuration(name)
    return self.channel[name].sound:getDuration()
end

function SoundManager:setBeatCallback(name, callback)
    self.channel[name].onBeat = callback
end

function SoundManager:release(name)
    self.channel[name].sound:release()
end

function SoundManager:exists(name)
    return self.channel[name] ~= nil
end

function SoundManager:getSoundData(name)
    return self.soundData[name]
end

function SoundManager:getChannel(name)
    return self.channel[name]
end

return SoundManager