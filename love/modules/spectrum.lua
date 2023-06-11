--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]
return {
    setup = function(self)
        self.wave_size=1
        self.types=1

        self.size = 1024
        self.frequency = 44100
        self.length = self.size / self.frequency

        function devide(list, factor)
            for i,v in ipairs(list) do list[i] = list[i] * factor end
        end
        self.UpdateSpectrum = false

        local col = skinJson["skin"]["menu"]["spectrumColor"]
        if spectrumDivideColours then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
        end
        spectrumDivideColours = false
        skinJson["skin"]["menu"]["spectrumColor"] = col
    end,

    update = function(self, obj, sdata)
        self.musicPos = obj:tell("samples")
        self.musicSize = sdata:getSampleCount()

        self.l = {}
        for i = self.musicPos, self.musicPos + (self.size-1) do
            copyPos = i
            if i + 2048 > self.musicSize then i = self.musicSize/2 end
        
            local l, r = sdata:getSample(i)
            table.insert(self.l, l)
            table.insert(self.l, r)
        end

        self.spectrum = fft(self.l, false) 
        devide(self.spectrum, self.wave_size) 
        self.UpdateSpectrum = true
    end,

    draw = function(self)
        if self.UpdateSpectrum then
            
            love.graphics.setColor(skinJson["skin"]["menu"]["spectrumColor"])
            for i = 1, #self.spectrum do
                local height = -self.wave_size*(self.spectrum[i]:abs()) * 1.3
                love.graphics.rectangle("fill", i*7-8, 1080, 7, height) 
            end

            for i = 1, #self.spectrum do
                --draw right to left now
                local height = self.wave_size*(self.spectrum[i]:abs()) * 1.5
                love.graphics.rectangle("fill", i*7-8, 0, 7, height)
            end
        end
    end
}