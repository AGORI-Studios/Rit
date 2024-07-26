---@diagnostic disable: undefined-global
-- This is possibly the weirdest file format i have EVEr seen lol (I lied, its still osu's)
-- still highly wip
local clone = {
    _NAME = "Clone",
    _VERSION = "1.0.0",
    _DESCRIPTION = "A simple clone hero chart parser",
    _LICENSE = [[
        MIT LICENSE
    ]]
}

local function split(str, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

function clone.parse(clonestr)
    local str

    if love.filesystem.getInfo(clonestr) then
        str = love.filesystem.read(clonestr)
    else
        str = clonestr
    end

    assert(str, "No clone hero file or string provided")

    local lines = split(str, "\n")

    local data = {
        meta = {},
        other = {},
        notes = {},
    }
    local currentSection = nil

    -- no comments lol
    for _, line in ipairs(lines) do
        --formatted like this:
        --[[
            [Song]
            {
                Name = "Running with the boys"
                Artist = "LIGHTS\\Myth"
                Charter = "metalli3212"
                Album = "Dead End"
                Year = ", 2020"
                Offset = 0
                Resolution = 192
                Player2 = bass
                Difficulty = 0
                PreviewStart = 0
                PreviewEnd = 0
                Genre = "Electro"
                MediaType = "cd"
                MusicStream = "guitar.ogg"
            }
            [SyncTrack]
            {
                0 = TS 4
                0 = B 120000
                768 = B 99000
                1536 = B 100400
                3072 = B 100000
            }
            [ExpertSingle]
            { -- MS_TIME = N LANE HOLD_MS_TIME
                1536 = N 0 0
                1536 = N 3 0
                1680 = N 0 0
                1680 = N 4 0
                1824 = N 0 0
                1824 = N 2 0
            }
        ]]

        -- remove whitespace
        line = line:gsub("%s+", "")

        -- check if line has [%] (can be second char)
        if line:find("%[") then
            currentSection = line:match("%[(.+)%]")
        elseif line:sub(1, 1) == "{" then
            -- do nothing, simply go to next line
        elseif line:sub(1, 1) == "}" then
            -- do nothing, simply go to next line
        else
            if currentSection == nil then
                --error("No section found")
            else
                if currentSection == "Song" then
                    if line:find("=") then
                        local key, value = line:match("(.+)=(.+)")
                        -- remove quotes
                        value = value:gsub("\"", "")
                        data.meta[key] = value
                    end
                elseif currentSection == "ExpertSingle" then
                    if not data.notes[currentSection] then
                        data.notes[currentSection] = {}
                    end
                    if line:find("=") then
                        --print(line) -- 32832=N00
                        local time = line:match("(.+)=")
                        local note = line:match("=(.+)")
                        local _, lane, hold = note:match("(.)(.)(.+)")
                        table.insert(data.notes[currentSection], {
                            time = tonumber(time),
                            note = note,
                            lane = tonumber(lane),
                            hold = tonumber(hold),
                        })
                        --print(time, note, lane, hold)
                    end
                else
                    if line:find("=") then
                        local key, value = line:match("(.+)=(.+)")
                        -- remove quotes
                        value = value:gsub("\"", "")
                        data.other[currentSection] = data.other[currentSection] or {}
                        data.other[currentSection][key] = value
                    end
                end
            end
        end
    end

    return data
end

return clone