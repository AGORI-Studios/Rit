local stepLoader = {}
lineCount = 0
MEASURE_TICKS = 192
BEAT_TICKS = 48
STEP_TICKS = 12
NUM_COLUMS = 4

local function round(num)
    return math.floor(num + 0.5)
end

-- make a TempoMarker class
TempoMarker = {}
TempoMarker.__index = TempoMarker

function TempoMarker.new(bpm, tick_pos, time_pos)
    self = setmetatable({}, TempoMarker)
    self.bpm = tonumber(bpm)
    self.tick_pos = tonumber(tick_pos)
    self.time_pos = tonumber(time_pos)
end

function TempoMarker.getBPM(self)
    return self.bpm
end

function TempoMarker.getTick(self)
    return self.tick_pos
end

function TempoMarker.getTime(self)
    return self.time_pos
end

function TempoMarker.timeToTick(self, note_time)
    return tonumber(round(self.tick_pos + (tonumber(note_time) - self.time_pos) * MEASURE_TICKS * self.bpm / 240000))
end
function TempoMarker.tickToTime(self, note_tick)
    return self.time_pos + (tonumber(note_tick) -self.tick_pos) / MEASURE_RICKS * 240000 / self.bpm 
end

function measure_gcd(num_set, MEASURE_TICKS)
    d = MEASURE_TICKS
    for i = 1, #num_set do
        d = math.gcd(d, num_set[i])
        if d == 1 then
            return d
        end
    end
    return d
end

tempomarkers = {}

function timeToTick(timestamp)
    for i = 1, #tempomarkers do
        if i == #tempomarkers - 1 or tempomarkers[i+1].getTime() > timestamp then
            return tempomarkers[i].timeToTick(timestamp)
        end
    end
end

function tickToTime(tick)
    for i = 1, #tempomarkers do
        if i == #tempomarkers - 1 or tempomarkers[i+1].getTick() > tick then
            return tempomarkers[i].tickToTime(tick)
        end
    end
end

function ticktoBPM(tick)
    for i = 1, #tempomarkers do
        if i == #tempomarkers - 1 or tempomarkers[i+1].getTick() > tick then
            return tempomarkers[i].getBPM()
        end
    end
end

function stepLoader.load(chart)
    local file = io.open(chart, "r")
    sm_header = ''
    sm_notes = ''
    for line in file:lines() do 
        if line:find("#BPMS:0.000=") then
            bpm = line:gsub("#BPMS:0.000=", "")
            bpm = tonumber(bpm)
        end
    end
end

return stepLoader