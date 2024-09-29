local Quaver = {}

function Quaver:parse(path, folderPath)
    print("Parsing Quaver file: " .. path)
    local data = love.filesystem.read(path):gsub("\r\n", "\n")
    data = Yaml.parse(data)
    local noteCount = 0

    for _, note in ipairs(data["HitObjects"]) do
        noteCount = noteCount + 1
        table.insert(
            instance.hitObjects,
            UnspawnObject(note.StartTime, note.EndTime, note.Lane)
        )
    end

    instance.initialSV = data["InitialScrollVelocity"] or 1

    instance.song = love.sound.newSoundData(folderPath .. "/" .. data["AudioFile"])
    instance.mode = data.Mode:gsub("Keys", "")
    instance.mode = tonumber(instance.mode)
    instance.noteCount = noteCount
end

---@param data string
function Quaver:cache(data, filename, path)
    local pathToFile = path
    data = data:gsub("\r\n", "\n")

    data = data:gsub("SliderVelocities(.-)HitObjects", "HitObjects")
    data = Yaml.parse(data)

    local title = data["Title"] or "Unknown"
    local artist = data["Artist"] or "Unknown"
    local source = data["Source"] or "Unknown"
    local tags = data["Tags"] or "Unknown"
    local creator = data["Creator"] or "Unknown"
    local diff_name = data["DifficultyName"] or "Unknown"
    local description = data["Description"] or "Unknown"
    local filename = filename
    local audio_path = data["AudioFile"] or "Unknown"
    local preview_time = data["PreviewTime"] or 0
    local mapset_id = data["MapSetId"] or 0
    local map_id = data["MapId"] or 0
    local mode = data["Mode"]:gsub("Keys", "") or 4
    local bg_path = data["BackgroundFile"] or "Unknown"
    ---@diagnostic disable-next-line: cast-local-type
    mode = tonumber(mode)
    local game_mode = "Mania"
    local hitobj_count = 0
    local ln_count = 0
    local length = 0 -- found from hit objects

    for _, note in ipairs(data["HitObjects"]) do
        hitobj_count = hitobj_count + 1 -- jas StartTime and EndTime (can be nil)
        if note["EndTime"] then
            length = math.max(length, note["EndTime"] > (note["StartTime"] or 0) and note["EndTime"] or note["StartTime"] or 0)
            if note["EndTime"] or 0 > note["StartTime"] or 0 then
                ln_count = ln_count + 1
            end
        else
            length = math.max(length, note["StartTime"] or 0)
        end
    end

    local songData = {
        title = title,
        artist = artist,
        source = source,
        tags = tags,
        creator = creator,
        diff_name = diff_name,
        description = description,
        filename = filename,
        path = pathToFile,
        audio_path = audio_path,
        preview_time = preview_time,
        mapset_id = mapset_id,
        map_id = map_id,
        mode = mode,
        game_mode = game_mode,
        hitobj_count = hitobj_count,
        ln_count = ln_count,
        length = length,
        metaType = 1,
        map_type = "Quaver",
        bg_path = bg_path
    }

    SongCache:createCache(songData, filename, ".qua")

    return songData
end

return Quaver
