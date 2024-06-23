local MapEditorScreen = state()

local noteOffsetY = 0
local wasPressed = false
local noteWidth
local songEnd = 60000 
local cols = {
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
    {1, 1, 1},
}
local snapSlider = {
    x = 10,
    y = 50,
    width = 200,
    height = 20,
    min = 1,
    max = 16,
    value = 4,
    dragging = false
}
local beatDisplaySlider = {
    x = 10,
    y = 140,
    width = 200,
    height = 20,
    min = 1,
    max = 16,
    value = 4,
    dragging = false
}

local utf8 = require("utf8")

local musicTime = 0

local hitsound = love.audio.newSource("defaultSkins/skinThrowbacks/hitsound.wav", "stream")

local exporting = false
local exporting_CURTAG = "SongTitle"
local exporting_LOG = ""

local full_AudioPath = ""
local full_BackgroundPath = ""

function MapEditorScreen:enter(songPath)
    if not songPath then
        self.map = {
            meta = {
                AudioFile = "None",
                SongTitle = "New Song",
                SongDiff = "New Difficulty",
                Background = "None",
                Banner = "None",
                Icon = "None",
                KeyAmount = 4, -- TODO: Key amounts other than 4.
                Creator = "Creator",
                CreatorID = Steam and SteamUser:getName() or "Unknown",
                Artist = "Artist",
                Tags = "",
                Description = "",
                PreviewTime = 0
            },

            curBPM = 120,

            -- ms_starttime:bpm
            timings = {},

            -- ms_starttime:ms_endtime:lane
            hits = {},

            -- ms_starttime:multiplier
            velocities = {}
        }
    else
        self.map = {
            meta = {
                AudioFile = "None",
                SongTitle = "New Song",
                SongDiff = "New Difficulty",
                Background = "None",
                Banner = "None",
                Icon = "None",
                KeyAmount = 4, -- TODO: Key amounts other than 4.
                Creator = "Creator",
                CreatorID = Steam and SteamUser:getName() or "Unknown",
                Artist = "Artist",
                Tags = "",
                Description = "",
                PreviewTime = 0
            },

            curBPM = 120,

            -- ms_starttime:bpm
            timings = {},

            -- ms_starttime:ms_endtime:lane
            hits = {},

            -- ms_starttime:multiplier
            velocities = {}
        }
        -- You will ONLY be able to open (and export) .ritc files with this... grrrr....
    end
    
    noteWidth = 100
    self.snapping = snapSlider.value  -- Default snapping value for 4/4 beat

    droppingBackground, droppingAudio = false, false

    self.audioData = nil
    self.audioSource = nil
    self.backgroundData = nil
    self.waveformPoints = {}

    love.audio.stop()
end

function MapEditorScreen:update(dt)
    if exporting then goto exportingupdate end
    if playing then
        -- Calculate pixels per millisecond based on beat display settings
        local msPerScreen = beatDisplaySlider.value * (60000 / self.map.curBPM)
        local pixelsPerMs = 1080 / msPerScreen

        musicTime = musicTime + 1000 * dt
        noteOffsetY = -musicTime * pixelsPerMs  -- Update noteOffsetY based on musicTime

        -- Stop playing if the end of the song is reached
        if -musicTime >= songEnd then
            musicTime = -songEnd
            playing = false
            if self.audioSource then self.audioSource:pause() end
            return
        end

        -- Play audio if not already playing and within valid offset range
        if self.audioSource and not self.audioSource:isPlaying() and -musicTime >= 0 then
            self.audioSource:play()
        end

        -- Define the strum line Y position
        local strumLineY = 50  -- Adjust this value as needed

        -- Hit notes that pass the strum line based on time
        for i, note in ipairs(self.map.hits) do
            if musicTime >= note.starttime and not note.hit then
                note.hit = true
                hitsound:clone():play()
            end
        end
    end

    goto endfunction
    ::exportingupdate::

    ::endfunction::
end

function MapEditorScreen:keypressed(key)
    if exporting then goto exportingkeypressed end
    if key == "space" then
        playing = not playing
        if playing and self.audioSource then
            -- Example: Start playing the song from current noteOffsetY
            if musicTime >= 0 then
                self.audioSource:seek(musicTime / 1000)  -- Convert noteOffsetY to seconds
                self.audioSource:play()
            end
        else
            if self.audioSource then
                self.audioSource:pause()
            end

            for i, note in ipairs(self.map.hits) do
                note.hit = false
            end
        end

        -- Set note.hit to true for notes already passed
        for i, note in ipairs(self.map.hits) do
            if musicTime >= note.starttime and not note.hit then
                note.hit = true
            end
        end

        table.sort(self.map.hits, function(a, b) return a.starttime < b.starttime end)
    end

    goto endfunction
    ::exportingkeypressed::
    if key == "escape" then
        exporting = false
    elseif key == "backspace" then
        local byteoffset = utf8.offset(self.map.meta[exporting_CURTAG], -1)

        if byteoffset then
            self.map.meta[exporting_CURTAG] = string.sub(self.map.meta[exporting_CURTAG], 1, byteoffset - 1)
        end
    end
    ::endfunction::
end

function MapEditorScreen:onMapSave()
    love.filesystem.createDirectory("songs/" .. self.map.meta.SongTitle .. "/")
    local exportString = ""

    -- [Meta] section
    exportString = exportString .. "[Meta]\n"
    exportString = exportString .. "AudioFile:" .. self.map.meta.AudioFile .. "\n"
    exportString = exportString .. "SongTitle:" .. self.map.meta.SongTitle .. "\n"
    exportString = exportString .. "SongDiff:" .. self.map.meta.SongDiff .. "\n"
    exportString = exportString .. "Background:" .. self.map.meta.Background .. "\n"
    exportString = exportString .. "Banner:" .. self.map.meta.Banner .. "\n"
    exportString = exportString .. "KeyAmount:" .. self.map.meta.KeyAmount .. "\n"
    exportString = exportString .. "Creator:" .. self.map.meta.Creator .. "\n"
    exportString = exportString .. "CreatorID:" .. self.map.meta.CreatorID .. "\n"
    exportString = exportString .. "Artist:" .. self.map.meta.Artist .. "\n"
    exportString = exportString .. "Tags:" .. self.map.meta.Tags .. "\n"
    exportString = exportString .. "Description:" .. self.map.meta.Description .. "\n"
    exportString = exportString .. "PreviewTime:" .. self.map.meta.PreviewTime .. "\n\n"

    -- [Timings] section
    exportString = exportString .. "[Timings]\n"
    exportString = exportString .. "0:" .. self.map.curBPM .. "\n"
    for _, timing in ipairs(self.map.timings) do -- TODO: Add a timings thingy a bobber
        exportString = exportString .. timing.ms_starttime .. ":" .. timing.bpm .. "\n"
    end
    exportString = exportString .. "\n"

    -- [Hits] section
    exportString = exportString .. "[Hits]\n"
    for _, note in ipairs(self.map.hits) do
        exportString = exportString .. note.starttime .. ":" .. note.endtime .. ":" .. note.lane .. "\n"
    end
    if #self.map.hits == 0 then
        exportString = exportString .. "0:0:1"
    end

    love.filesystem.write("songs/" .. self.map.meta.SongTitle .. "/" .. self.map.meta.SongDiff .. ".ritc", exportString)

    -- now we do some wackies !!!
    exporting_LOG = ""
    if not importer then
        exporting_LOG = exporting_LOG .. "importer was not loaded. Lovefs wasn't fully initialized. Can not copy audio file and background\n"
    else
        Try(
            function()
                importer:copy(full_AudioPath)
            end,
            function()
                exporting_LOG = exporting_LOG .. "Could not copy audio file. You will have to do this manually.\n"
            end
        )
        Try(
            function()
                importer:copy(full_BackgroundPath)
            end,
            function()
                exporting_LOG = exporting_LOG .. "Could not copy background file. You will have to do this manually.\n"
            end
        )
    end

    print("file://" .. love.filesystem.getSaveDirectory() .. "/songs/" .. self.map.meta.SongTitle)

    love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/songs/" .. self.map.meta.SongTitle)
end

function MapEditorScreen:onMapLoad()

end

function MapEditorScreen:mousepressed(x, y, button)
    local x, y = toGameScreen(x, y)

    if not exporting then
        -- Check if the mouse is pressed on the snapping slider
        if x >= snapSlider.x and x <= snapSlider.x + snapSlider.width and y >= snapSlider.y and y <= snapSlider.y + snapSlider.height then
            snapSlider.dragging = true
            return
        end

        -- Check if the mouse is pressed on the beat display slider
        if x >= beatDisplaySlider.x and x <= beatDisplaySlider.x + beatDisplaySlider.width and y >= beatDisplaySlider.y and y <= beatDisplaySlider.y + beatDisplaySlider.height then
            beatDisplaySlider.dragging = true
            return
        end

        -- Adjust y-coordinate for noteOffsetY and pixelsPerMs
        local msPerScreen = beatDisplaySlider.value * (60000 / self.map.curBPM)
        local pixelsPerMs = 1080 / msPerScreen
        local adjustedY = (y - noteOffsetY) / pixelsPerMs

        -- Calculate the beat interval based on the current BPM and snapping value
        local beatInterval = (60000 / self.map.curBPM) / self.snapping
        local snappedPosition = math.floor(adjustedY / beatInterval + 0.5) * beatInterval

        -- Determine which lane was clicked
        local lane = math.floor((x - 725 - 50) / noteWidth) - 1

        if lane >= 0 and lane < self.map.meta.KeyAmount then
            -- Check if the mouse click is within the bounds of an existing note
            local noteClicked = nil
            local noteIndexToDelete = nil
            for i, note in ipairs(self.map.hits) do
                local noteEnd = (note.endtime == 0 or note.endtime == note.starttime) and note.starttime + (25 / pixelsPerMs) or note.endtime
                if note.lane == lane + 1 and adjustedY >= note.starttime and adjustedY <= noteEnd then
                    if button == 2 then
                        noteIndexToDelete = i
                    else
                        noteClicked = note
                    end
                    break
                end
            end

            if noteIndexToDelete then
                table.remove(self.map.hits, noteIndexToDelete)
                return
            end

            if button == 1 and noteClicked then
                -- If a note was clicked with left button, allow modifying its endTime
                noteClicked.dragging = true
                wasPressed = true
            elseif button == 1 and not noteClicked and snappedPosition >= 0 and snappedPosition <= songEnd then
                -- If no note was clicked and left button was pressed, create a new note
                table.insert(self.map.hits, {
                    lane = lane + 1,
                    starttime = snappedPosition,
                    endtime = snappedPosition,  -- Initialize endtime to starttime
                    hit = false
                })
                wasPressed = true
            end
        end

        -- Check if the mouse is pressed on the AudioFile button
        if x >= 10 and x <= 310 and y >= 250 and y <= 300 then
            droppingAudio = true
            droppingBackground = false  -- Ensure only one file dropping mode is active
            return
        end

        -- Check if the mouse is pressed on the Background button
        if x >= 10 and x <= 310 and y >= 320 and y <= 370 then
            droppingBackground = true
            droppingAudio = false  -- Ensure only one file dropping mode is active
            return
        end

        if x >= 10 and x <= 160 and y >= 400 and y <= 450 then
            exporting = true
        end
    else
    
        local metaItems = {
            "SongTitle", "SongDiff", "Creator",
            "Artist", "Tags", "Description", "PreviewTime"
        }
        local yOffset = 100  -- Initial y offset for the first meta element
        local boxWidth = 1700
        local boxHeight = 50

        for index, meta in ipairs(metaItems) do
            -- Calculate the boundaries of the current meta box
            local boxX = 100
            local boxY = yOffset
            local boxRight = boxX + boxWidth
            local boxBottom = boxY + boxHeight

            -- Check if the mouse click was inside this meta box
            if x >= boxX and x <= boxRight and y >= boxY and y <= boxBottom then
                exporting_CURTAG = metaItems[index]
                break
            end

            yOffset = yOffset + boxHeight + 10  -- Increase yOffset for the next box
        end

        local buttonWidth = 200
        local buttonHeight = 50
        local buttonX = 100
        local buttonY = 950

        if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
            self:onMapSave()
        end
    end
end

function MapEditorScreen:textinput(text)
    if exporting then
        if exporting_CURTAG == "KeyAmount" then
            text = tonumber(text) or ""
            self.map.meta[exporting_CURTAG] = tonumber(self.map.meta[exporting_CURTAG] .. text)
            self.map.meta["KeyAmount"] = math.clamp(1, self.map.meta["KeyAmount"], 10)
        else
            self.map.meta[exporting_CURTAG] = self.map.meta[exporting_CURTAG] .. text
        end
    end
end

function MapEditorScreen:mousemoved(x, y, dx, dy, istouch)
    if exporting then goto exportingmousemoved end
    local x, y = toGameScreen(x, y)

    if snapSlider.dragging then
        -- Update the snapping slider value based on the mouse position
        local newValue = math.clamp((x - snapSlider.x) / snapSlider.width, 0, 1) * (snapSlider.max - snapSlider.min) + snapSlider.min
        snapSlider.value = math.floor(newValue + 0.5)
        self.snapping = snapSlider.value
        return
    end

    if beatDisplaySlider.dragging then
        -- Update the beat display slider value based on the mouse position
        local newValue = math.clamp((x - beatDisplaySlider.x) / beatDisplaySlider.width, 0, 1) * (beatDisplaySlider.max - beatDisplaySlider.min) + beatDisplaySlider.min
        beatDisplaySlider.value = math.floor(newValue + 0.5)
        return
    end

    -- Adjust y-coordinate for noteOffsetY and pixelsPerMs
    local msPerScreen = beatDisplaySlider.value * (60000 / self.map.curBPM)
    local pixelsPerMs = 1080 / msPerScreen
    local adjustedY = (y - noteOffsetY) / pixelsPerMs

    -- Calculate the beat interval based on the current BPM and snapping value
    local beatInterval = (60000 / self.map.curBPM) / self.snapping
    local snappedPosition = math.floor(adjustedY / beatInterval + 0.5) * beatInterval
    -- Handle dragging of a note's endTime
    for i, note in ipairs(self.map.hits) do
        if note.dragging then
            -- Update the endTime of the dragged note
            note.endtime = math.max(snappedPosition, note.starttime)
            return
        end
    end

    -- If no note is being dragged, adjust the position of the last created note
    if wasPressed then
        self.map.hits[#self.map.hits].endtime = math.max(snappedPosition, self.map.hits[#self.map.hits].starttime)
    end

    goto endfunction
    ::exportingmousemoved::

    ::endfunction::
end

function MapEditorScreen:filedropped(file)
    local filename = file:getFilename():gsub("\\", "/"):match(".+/(.+)$")
    local ext = string.lower(filename:match("%.(%w+)$"))

    if ext then
        if droppingAudio and (ext == "mp3" or ext == "ogg" or ext == "wav") then
            full_AudioPath = file:getFilename()
            file:open("r")
            local fileData = file:read("data")
            self.audioData = love.sound.newSoundData(fileData)
            self.audioSource = love.audio.newSource(self.audioData, "stream")
            self.map.meta.AudioFile = filename
            droppingAudio = false
            songEnd = self.audioSource:getDuration() * 1000

        elseif droppingBackground and (ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp") then
            full_BackgroundPath = file:getFilename()
            file:open("r")
            local fileData = file:read("data")
            self.backgroundData = love.graphics.newImage(love.image.newImageData(fileData))
            self.map.meta.Background = filename
            droppingBackground = false
        else
            print("Unsupported file type:", filename)
        end
    else
        print("File has no extension:", filename)
    end
end

function MapEditorScreen:mousereleased(x, y, button)
    if exporting then goto exportingmousereleased end
    wasPressed = false
    snapSlider.dragging = false
    beatDisplaySlider.dragging = false

    for _, note in ipairs(self.map.hits) do
        note.dragging = false
    end

    goto endfunction
    ::exportingmousereleased::
    ::endfunction::
end

function MapEditorScreen:wheelmoved(x, y)
    if exporting then goto exportingwheelmoved end
    local msPerScreen = beatDisplaySlider.value * (60000 / self.map.curBPM)
    local pixelsPerMs = 1080 / msPerScreen
    local scrollSpeed = love.keyboard.isDown("lctrl") and 100 or 10
    scrollSpeed = love.keyboard.isDown("lshift") and scrollSpeed * 10 or scrollSpeed
    musicTime = musicTime - y * scrollSpeed  -- Adjust musicTime based on mouse wheel movement
    
    -- Clamp musicTime to ensure it stays within valid bounds
    musicTime = math.clamp(musicTime, -100, songEnd)
    
    -- Update noteOffsetY based on musicTime
    noteOffsetY = -musicTime * pixelsPerMs

    goto endfunction
    ::exportingwheelmoved::

    ::endfunction:: 
end

function MapEditorScreen:draw()
    if self.backgroundData then
        local scaleX = 1920 / self.backgroundData:getWidth()
        local scaleY = 1080 / self.backgroundData:getHeight()
        love.graphics.draw(self.backgroundData, 0, 0, 0, scaleX, scaleY)
        love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
        love.graphics.rectangle("fill", 0, 0, 1920, 1080)
    end
    
    local lastFont = love.graphics.getFont()
    local font = Cache.members.font["defaultX0.75"]
    love.graphics.setFont(font)
    love.graphics.push()
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 875, 0, 400, 1080)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(2.5)
        love.graphics.line(875, 0, 875, 1080)
        love.graphics.line(1275, 0, 1275, 1080)
        love.graphics.setLineWidth(1)

        love.graphics.push()
            love.graphics.translate(0, noteOffsetY)

            -- Calculate the beat interval in milliseconds
            local beatInterval = 60000 / self.map.curBPM
            local halfBeatInterval = beatInterval / 2

            -- Calculate the number of milliseconds to show on screen based on beatDisplaySlider
            local msPerScreen = beatDisplaySlider.value * beatInterval
            local pixelsPerMs = 1080 / msPerScreen
            local scale = beatDisplaySlider.value / 2

            -- Draw beat lines
            for i = 0, songEnd * scale, beatInterval do
                local y = i * pixelsPerMs
                love.graphics.setColor(1, 1, 1)  -- White for full beat lines
                love.graphics.line(875, y, 1275, y)
            end

            -- Draw half-beat lines
            for i = halfBeatInterval, songEnd * scale, beatInterval do
                local y = i * pixelsPerMs
                love.graphics.setColor(1, 0, 0)  -- Red for half beat lines
                love.graphics.line(875, y, 1275, y)
            end

            for i, note in ipairs(self.map.hits) do
                love.graphics.setColor(cols[note.lane])
                local y = note.starttime * pixelsPerMs
                local height = ((note.endtime == 0 or note.endtime == note.starttime or note.endtime <= note.starttime) and 25 or note.endtime - note.starttime) * pixelsPerMs
                love.graphics.rectangle("fill", (note.lane+1) * noteWidth + 725-50, y, noteWidth, height)
                love.graphics.setColor(1, 1, 1)
            end

            love.graphics.setColor(1, 1, 1)
            love.graphics.pop()
    love.graphics.pop()

    -- background tab for all the options
    love.graphics.setColor(0.35, 0.35, 0.35)
    love.graphics.rectangle("fill", 2, 2, 500, 800, 10, 10)

    -- Draw the snapping slider background tab
    love.graphics.setColor(0.8, 0.8, 0.8)  -- Light gray color
    love.graphics.rectangle("fill", snapSlider.x, snapSlider.y, snapSlider.width, snapSlider.height, 10, 10)

    -- Draw the snapping slider handle
    local snapSliderPos = ((snapSlider.value - snapSlider.min) / (snapSlider.max - snapSlider.min)) * snapSlider.width
    love.graphics.setColor(0.3, 0.3, 0.3)  -- Darker gray color
    love.graphics.rectangle("fill", snapSlider.x + snapSliderPos - 10, snapSlider.y - 5, 20, snapSlider.height + 10, 10, 10)

    -- Draw the snapping slider value text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Snapping: " .. snapSlider.value, 10, 20, 0, 2, 2)

    -- Draw the beat display slider background tab
    love.graphics.setColor(0.8, 0.8, 0.8)  -- Light gray color
    love.graphics.rectangle("fill", beatDisplaySlider.x, beatDisplaySlider.y, beatDisplaySlider.width, beatDisplaySlider.height, 10, 10)

    -- Draw the beat display slider handle
    local beatDisplaySliderPos = ((beatDisplaySlider.value - beatDisplaySlider.min) / (beatDisplaySlider.max - beatDisplaySlider.min)) * beatDisplaySlider.width
    love.graphics.setColor(0.3, 0.3, 0.3)  -- Darker gray color
    love.graphics.rectangle("fill", beatDisplaySlider.x + beatDisplaySliderPos - 10, beatDisplaySlider.y - 5, 20, beatDisplaySlider.height + 10, 10, 10)

    -- Draw the beat display slider value text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Beats on Screen: " .. beatDisplaySlider.value, 10, 110, 0, 2, 2)

    love.graphics.print("Song Position: " .. musicTime .. "ms / " .. songEnd .. "ms", 10, 190, 0, 2, 2)

    -- Draw AudioFile button
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 10, 250, 300, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Audio File: " .. self.map.meta.AudioFile, 10, 250, 300, "left", 0, 1.5, 1.5)

    -- Draw Background button
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 10, 320, 300, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Background: " .. self.map.meta.Background, 10, 320, 300, "left", 0, 1.5, 1.5)

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 10, 400, 150, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Export Map", -30, 410, 150, "center", 0, 1.5, 1.5)

    if exporting then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", 50, 50, 1820, 980, 15, 15) -- tab background
        love.graphics.setColor(1, 1, 1)
    
        local yOffset = 100  -- Initial y offset for the first meta element
        local boxWidth = 1700
        local boxHeight = 50
    
        -- Draw each meta element with a surrounding box
        for _, meta in ipairs({ -- i should probably define this somewhere else, but ah well
            {label = "Song Title:", value = self.map.meta.SongTitle},
            {label = "Song Diff:", value = self.map.meta.SongDiff},
            {label = "Creator:", value = self.map.meta.Creator},
            {label = "Artist:", value = self.map.meta.Artist},
            {label = "Tags:", value = self.map.meta.Tags},
            {label = "Description:", value = self.map.meta.Description},
            {label = "Preview Time:", value = self.map.meta.PreviewTime},
        }) do
            -- Draw background box
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.rectangle("fill", 100, yOffset, boxWidth, boxHeight)
    
            -- Draw text within the box
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(meta.label .. " " .. meta.value, 100, yOffset, boxWidth, "left", 0, 2, 2)
    
            -- Increase yOffset for the next line
            yOffset = yOffset + boxHeight + 10  -- Add extra space between boxes
        end

        -- Draw export file button
        local buttonWidth = 200
        local buttonHeight = 50
        local buttonX = 100
        local buttonY = 950

        love.graphics.setColor(0.3, 0.8, 0.3)  -- Button color
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 10, 10)

        love.graphics.setColor(1, 1, 1)  -- Text color
        love.graphics.printf("Export File", buttonX-buttonWidth/2, buttonY + 10, buttonWidth, "center", 0, 2, 2)

        love.graphics.print("LOG:\n" .. exporting_LOG, 100, 550, 0, 2, 2)
    end

    if droppingAudio or droppingBackground then
        love.graphics.setColor(0.3, 0.3, 0.3, 0.6)
        love.graphics.rectangle("fill", 0, 0, 1920, 1080)

        local scale = 2
    
        -- Calculate message dimensions
        local message = droppingAudio and "Drop audio file..." or "Drop background file..."
    
        -- Draw the centered message
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(message, 0, love.graphics.getHeight() / 2 + 150, love.graphics.getWidth() - 225, "center", 0, scale, scale)
    end

    love.graphics.setFont(lastFont)
end

return MapEditorScreen