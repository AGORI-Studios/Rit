local stepLoader = {}
local List = {}

function List.toQuas()
    quas = {}
    for i = 1, #List do
        currentTime = -offset * 1000

        qua = {
            Title = title,
            Artist = artist,
            Creator = creator,
            BannerFile = banner,
            BackgroundFile = background,
            AudioFile = music,
            SongPreviewTime = preview,
            Mode = "Keys4",
            DifficultyName = difficultyname
        }

        totalBeats = 0
        bpmCache = {}
        for i = 1, #bpm do
            bpmCache[i] = bpm[i]
        end
    end
end

-- based off of https://github.com/Quaver/Quaver.API/tree/master/Quaver.API/Maps/Parsers/Stepmania

function stepLoader.load(chart)
    curChart = "Stepmania"
    love.filesystem.read(chart)
    for line in love.filesystem.lines(chart) do
        -- if line starts with #, then it's a comment
        if line:find("#") then
            -- split the line from the :
            local splitLine = line:split(":")
            key = splitLine[1]:gsub("#", "")
            value = splitLine[2]:gsub(";", "")
            value = value:gsub(":", "")

            if line:find("TITLE") then
                title = value
            elseif line:find("SUBTITLE") then
                subtitle = value
            elseif line:find("ARTIST") then
                artist = value
            elseif line:find("TITLETRANSLIT") then
                titleTranslit = value
            elseif line:find("SUBTITLETRANSLIT") then
                subtitleTranslit = value
            elseif line:find("ARTISTTRANSLIT") then
                artistTranslit = value
            elseif line:find("CREDIT") then
                credit = value
            elseif line:find("BANNER") then
                banner = value
            elseif line:find("BACKGROUND") then
                background = value
            elseif line:find("LYRICSPATH") then
                lyricsPath = value
            elseif line:find("CDTITLE") then
                cdTitle = value
            elseif line:find("MUSIC") then
                music = value
            elseif line:find("MUSICLENGTH") then
                musicLength = tonumber(value)
            elseif line:find("OFFSET") then
                offset = tonumber(value)
            elseif line:find("SAMPLESTART") then
                sampleStart = tonumber(value)
            elseif line:find("SAMPLELENGTH") then
                sampleLength = tonumber(value)
            elseif line:find("SELECTABLE") then
            elseif line:find("BPMS") then
                inBpms = true
                bpm = tonumber(value:gsub("0.000=", ""))
                if bpm:find(";") then
                    inBpms = false
                end
            elseif line:find("STOPS") then
                inStops = true
                stop = value
                if stop:find(";") then
                    inStops = false
                end
            elseif line:find("NOTES") then

            end
        end
    end
end

return stepLoader