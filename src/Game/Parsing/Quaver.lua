local Quaver = {}

function Quaver:parse(path, folderPath)
    print("Parsing Quaver file: " .. path)
    local data = love.filesystem.read(path):gsub("\r\n", "\n")
    data = Yaml.parse(data)

    for _, note in ipairs(data["HitObjects"]) do
        table.insert(
            States.Screens.Game.instance.hitObjectManager.hitObjects,
            UnspawnObject(note.StartTime, note.EndTime, note.Lane)
        )
    end
--[[ 
    for _, point in ipairs(data["SliderVelocities"]) do
        table.insert(
            States.Screens.Game.instance.hitObjectManager.scrollVelocities,
            ScrollVelocity(point.StartTime, point.Multiplier)
        )
    end
 ]]
    States.Screens.Game.instance.hitObjectManager.initialSV = data["InitialScrollVelocity"] or 1

    States.Screens.Game.instance.song = love.audio.newSource(folderPath .. "/" .. data["AudioFile"], "stream")
end

---@param data string
function Quaver:cache(data, filename, path)
    local pathToFile = path
    data = data:gsub("\r\n", "\n")
    -- remove all timing points between TimingPoints and HitObjects because sv heavy charts can cause very long loading times
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
    local game_mode = "mania"
    local hitobj_count = 0
    local ln_count = 0
    local length = 0 -- found from hit objects

    for _, note in ipairs(data["HitObjects"]) do
        hitobj_count = hitobj_count + 1 -- jas StartTime and EndTime (can be nil)
        if note["EndTime"] then
            length = math.max(length, note["EndTime"] > (note["StartTime"] or 0) and note["EndTime"] or note["StartTime"] or 0)
            if note["EndTime"] > note["StartTime"] or 0 then
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
        bg_path = bg_path
    }

    SongCache:createCache(songData, filename, ".qua")

    return songData
end

return Quaver