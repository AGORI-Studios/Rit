local MapEditorScreen = state()

-- Todo, Map Editor Screen
-- Note, Gotta figure out how to make a waveform from the audio file before I can create a map editor
local noteOffsetY = 0
local wasPressed = false
local laneIndexes = {}
local noteWidth
local songEnd = 60000 
function MapEditorScreen:enter()
    self.map = {
        meta = {
            SongTitle = "New Song",
            SongDiff = "Difficulty",
            AudioFile = "song.mp3",
            Background = "bg.png",
            Banner = "banner.png",
            KeyAmount = 4,
            Creator = "Creator",
            CreatorID = Steam and SteamUser:getName() or "Unknown",
        },

        -- ms time, bpm
        timings = {},

        -- ms starttime, ms endtime, lane
        hits = {},

        -- ms time, amount
        velocities = {}
    }

    self.strums = Group()
    local strumX = 525 - ((self.map.meta.KeyAmount - 4.5) * 100)
    for i = 1, self.map.meta.KeyAmount do
        local strum = StrumObject(strumX, 50, i)
        self.strums:add(strum)
        strum:postAddToGroup()

        laneIndexes[i] = {strum.x, strum.x + strum.width}
    end
    -- find noteWidth from first x to second x
    noteWidth = laneIndexes[2][1] - laneIndexes[1][1]
end

function MapEditorScreen:update(dt)
    
end

function MapEditorScreen:onMapSave()

end

function MapEditorScreen:onMapLoad()

end

function MapEditorScreen:mousepressed(x, y, button)
    local x, y = toGameScreen(x, y)
    wasPressed = true
    local lane = 1
    for i, v in ipairs(laneIndexes) do
        if x > v[1] and x < v[2] then
            lane = i
            break
        end

        if i == #laneIndexes then
            goto not_in_bounds
        end
    end
    -- check if note exists at y with a 20 pixel buffer
    for i, note in ipairs(self.map.hits) do
        if lane == note.lane and y > note.starttime - 20 and y < note.starttime + 20 then
            table.remove(self.map.hits, i)
        end
    end
    table.insert(self.map.hits, {starttime = y - noteOffsetY, endtime = 0, lane = lane})
    ::not_in_bounds::

end

function MapEditorScreen:mousemoved(x, y, dx, dy, istouch)
    local x, y = toGameScreen(x, y)
    if wasPressed then
        -- set endtime to y + noteOffsetY
        self.map.hits[#self.map.hits].endtime = y - noteOffsetY
    end
end

function MapEditorScreen:mousereleased(x, y, button)
    wasPressed = false
end

function MapEditorScreen:wheelmoved(x, y)
    noteOffsetY = noteOffsetY + y * 10
    noteOffsetY = math.clamp(noteOffsetY, -songEnd, 0)
end

function MapEditorScreen:draw()
    love.graphics.push()
        love.graphics.setLineWidth(5)
        love.graphics.line(575, 0, 575, 1080)
        love.graphics.line(1375, 0, 1375, 1080)
        self.strums:draw()
        love.graphics.setLineWidth(1)

        love.graphics.push()
            love.graphics.translate(0, noteOffsetY)
            
            for i, note in ipairs(self.map.hits) do
                love.graphics.setColor(1, 1, 1, 1)
                -- if endtime in't 0, draw height as endtime - starttime, else just do 100
                love.graphics.rectangle("fill", note.lane * noteWidth + 422, note.starttime, noteWidth, ((note.endtime == 0 or note.endtime == note.starttime or note.endtime <= note.starttime) and 100 or note.endtime - note.starttime))
            end
        love.graphics.pop()
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
    -- noteOffsetY and songEnd for a 0:00/3:00 type thing
    love.graphics.print("Song Position: " .. -noteOffsetY .. "ms / " .. songEnd .. "ms", 10, 10, 0, 2, 2)
end

return MapEditorScreen