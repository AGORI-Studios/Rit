local Spectrum = Object:extend()

local function devide(list, factor)
    for i, _ in ipairs(list) do
        list[i] = list[i] * factor
    end
end

function Spectrum:new(sdata)
    self.wave_size = 1
    self.types = 1

    self.size = 1024
    self.freq = 44100
    self.length = self.size / self.freq

    self.doDraw = false

    self.col = {0.70, 0.35, 0}
    self.divideColours = false

    self.musicPos = 0

    self.l = {}
end

function Spectrum:update(obj, sdata)
    self.musicPos = obj:tell("samples")
    self.musicSize = sdata:getSampleCount()

    self.l = {}
    for i = self.musicPos, self.musicPos + (self.size-1) do
        if i + 2048 > self.musicSize then i = self.musicSize/2 end
    
        local l, r = sdata:getSample(i)
        table.insert(self.l, l)
        table.insert(self.l, r)
    end

    self.spectrum = fft(self.l, false)
    devide(self.spectrum, self.wave_size)
    self.doDraw = true
end

function Spectrum:draw()
    if self.doDraw then
        if self.divideColours then
            love.graphics.setColor(self.col[1]/255, self.col[2]/255, self.col[3]/255, 1)
        else
            love.graphics.setColor(self.col[1], self.col[2], self.col[3], 1)
        end

        for i = 1, #self.spectrum do
            local height = self.wave_size*(self.spectrum[i]:abs()) * 1.5
            love.graphics.rectangle("fill", i*7-8, 0, 7, height)
        end
    end
end

return Spectrum