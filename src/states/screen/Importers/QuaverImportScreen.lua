local QuaverImportScreen = state()
local os = love.system.getOS()
local importer = lovefs()
local sep = os == "Windows" and "\\" or "/"
local songsFolder = love.filesystem.getSaveDirectory() .. sep .. "songs"

function QuaverImportScreen:enter()
    -- use lovefs to print all the drives
    --print(unpack(importer.drives))
    for _, drive in ipairs(importer.drives) do
        local path = drive .. "SteamLibrary"
        if importer:isDirectory(path) then
            importer:cd(path)
            importer:cd("steamapps")
            importer:cd("common")
            importer:cd("Quaver")
            if importer:exists("Songs") then
                importer:cd("Songs")
                local lastDir = importer.current
                local dir, lFolders = importer:ls()

                for _, song in ipairs(lFolders) do
                    importer:cd(song)
                    love.filesystem.createDirectory("songs/" .. song)
                    local dir, _, lFiles = importer:ls()
                    for _, file in ipairs(lFiles) do
                        importer:copy(dir .. sep .. file, songsFolder .. sep .. song .. sep .. file)
                    end
                end
            end
        end

        importer:cd(drive)
        importer:cd("Program Files (x86)")
        importer:cd("Steam")
        importer:cd("steamapps")
        importer:cd("common")
        importer:cd("Quaver")
        if importer:exists("Songs") then
            importer:cd("Songs")
            local lastDir = importer.current
            local dir, lFolders = importer:ls()

            for _, song in ipairs(lFolders) do
                importer:cd(song)
                love.filesystem.createDirectory("songs/" .. song)
                local dir, _, lFiles = importer:ls()
                for _, file in ipairs(lFiles) do
                    importer:copy(dir .. sep .. file, songsFolder .. sep .. song .. sep .. file)
                end
            end
        end
    end

    state.switch(states.screens.Importers.OsuImportScreen)
end

return QuaverImportScreen