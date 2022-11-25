local osuLoader = {}

local function stripComments(str)

function osuLoader.load(file)
    if file == nil then
        return
    end
    osuHitObject = {}
    timingPoint = {}

    isValid = true
    originalFileName = file

    section = ""

    for raw_line in love.filesystem.lines(love.filesystem.read(file)) do
        if file then
            if startsWith(raw_line, "//") and startsWith(raw_line, " ") startsWith(raw_line, "_") then 
                -- just comments, ignore
            end
        end
        line = raw_line
        
        -- trim the line
        
        lineNew = line:gsub("^%s*(.-)%s*$", "%1")

        if lineNew == "[General]" then
            section = "General"
        elseif lineNew == "[Editor]" then
            section = "Editor"
        elseif lineNew == "[Metadata]" then
            section = "Metadata"
        elseif lineNew == "[Difficulty]" then
            section = "Difficulty"
        elseif lineNew == "[Events]" then
            section = "Events"
        elseif lineNew == "[TimingPoints]" then
            section = "TimingPoints"
        elseif lineNew == "[Colours]" then
            section = "Colours"
        elseif lineNew == "[HitObjects]" then
            section = "HitObjects"
        else 
        end

        if section == "[General]" then
            if line:find(":") then
                -- line substring
                local key = line:sub(1, line:find(":") - 1)
                local value = line.split(line, ":"):gsub("^%s*(.-)%s*$", "%1")

                if line:find("AudioFilename") then
                    audioFilename = value
                elseif line:find("AudioLeadIn") then
                    audioLeadIn = value
                elseif line:find("PreviewTime") then
                    previewTime = value
                elseif line:find("Countdown") then
                    countdown = value
                elseif line:find("SampleSet") then
                    sampleSet = value
                elseif line:find("StackLeniency") then
                    stackLeniency = value
                elseif line:find("Mode") then
                    mode = value
                elseif line:find("LetterboxInBreaks") then
                    letterboxInBreaks = value
                elseif line:find("SpecialStyle") then
                    specialStyle = value
                elseif line:find("WidescreenStoryboard") then
                    widescreenStoryboard = value
                end

            elseif section == "[Metadata]" then
                if line:find(":") then
                    -- line substring
                    local key = line:sub(1, line:find(":") - 1)
                    local value = line.split(line, ":"):gsub("^%s*(.-)%s*$", "%1")

                    if line:find("Title") then
                        title = value
                    elseif line:find("TitleUnicode") then
                        titleUnicode = value
                    elseif line:find("Artist") then
                        artist = value
                    elseif line:find("ArtistUnicode") then
                        artistUnicode = value
                    elseif line:find("Creator") then
                        creator = value
                    elseif line:find("Version") then
                        version = value
                    elseif line:find("Source") then
                        source = value
                    elseif line:find("Tags") then
                        tags = value
                    elseif line:find("BeatmapID") then
                        beatmapID = value
                    elseif line:find("BeatmapSetID") then
                        beatmapSetID = value
                    end
                end

            elseif section == "[TimingPoints]" then
                if line:find(",") then
                    values = line.split(line, ",")

                    msecPerBeat = values[1]

                    timingPoint.append(
                        {
                            Offset = values[1],
                            MillisecondsPerBeat = msecPerBeat,
                            Signature = values[3] == 0
                        }
                    )

            elseif section == "[Difficulty]" then
                if line:find(":") then
                    -- line substring
                    local key = line:sub(1, line:find(":") - 1)
                    local value = line.split(line, ":"):gsub("^%s*(.-)%s*$", "%1")

                    if line:find("HPDrainRate") then
                        hpDrainRate = value
                    elseif line:find("CircleSize") then
                        circleSize = value
                    elseif line:find("OverallDifficulty") then
                        overallDifficulty = value
                    elseif line:find("ApproachRate") then
                        approachRate = value
                    elseif line:find("SliderMultiplier") then
                        sliderMultiplier = value
                    elseif line:find("SliderTickRate") then
                        sliderTickRate = value
                    end
                end
            elseif section == "[HitObjects]" then
                if line:find(",") then
                   values = line.split(line, ",")
                    osuHitObject.append(
                        {
                            x = values[1],
                            y = values[2],
                            StartTime = values[3],
                            Type = values[4],
                            Additions = "0:0:0:0:"
                        }
                    )
                end
            end
        end
    end

    -- now we convert the osuHitObject to a normal hit object so Rit can read it 


    
end

return osuLoader