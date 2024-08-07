---@diagnostic disable: duplicate-set-field, inject-field
-- Sound manager for more time-based functions, such as BPM and beat callbacks
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
        fullBeat = 0, 
        beatLength = 60 / 120,
        time = 0,
        time2 = 0,
        lastFrameTime = 0,
        onBeat = function() end,
        paused = false,
        pitch = 1,
    }
end

function SoundManager:play(name, clone)
    if not self.channel[name] then return end
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

function SoundManager:playFromTime(name, time, clone)
    local time = math.abs(time or 0)
    if not self.channel[name] then return end
    self.channel[name].paused = false
    self.channel[name].time2 = time * 1000
    if clone then
        local clone = self.channel[name].sound:clone()
        clone:seek(time or 0)
        clone:play()
        return clone
    else
        if not self.channel[name] then return end
        self.channel[name].sound:seek(time or 0)
        self.channel[name].sound:play()
        return self.channel[name].sound
    end
end

function SoundManager:update(dt)
    for _, v in pairs(self.channel) do
        if v.lastFrameTime == 0 then
            v.lastFrameTime = love.timer.getTime()
        end
        v.time = v.time + (love.timer.getTime() - v.lastFrameTime)
        v.time2 = v.time2 + (love.timer.getTime() - v.lastFrameTime)
        v.fullBeat = v.time / v.beatLength
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

function SoundManager:setPitch(name, pitch)
    self.channel[name].pitch = pitch
    self.channel[name].sound:setPitch(pitch)
end


function SoundManager:getLooping(name)
    return self.channel[name].loop
end

function SoundManager:setBPM(name, bpm)
    self.channel[name].bpm = bpm
    self.channel[name].beatLength = 60 / bpm
end

function SoundManager:getBPM(name)
    return self.channel[name].bpm
end

function SoundManager:getBeat(name)
    if not self.channel[name] then return end
    return self.channel[name].beat
end

function SoundManager:getDecBeat(name)
    local time = self.channel[name].time2

    local decBeat = time / self.channel[name].beatLength

    return decBeat
end

function SoundManager:getFullBeat(name)
    return self.channel[name].fullBeat
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
    return self.channel[name].sound:tell(unit or "seconds")
end

function SoundManager:clone(name)
    return self.channel[name].sound:clone()
end

function SoundManager:getDuration(name)
    return self.channel[name].sound:getDuration("seconds")
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

function SoundManager:setEffect(name, effect)
    self.channel[name].sound:setEffect(effect)
end

function SoundManager:setFilter(name, settings)
    self.channel[name].sound:setFilter(settings)
end

return SoundManager