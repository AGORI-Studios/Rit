---@diagnostic disable: param-type-mismatch
local FluxisInportScreen = state()
local os_ = love.system.getOS()
local sep = os_ == "Windows" and "\\" or "/"
local songsFolder = love.filesystem.getSaveDirectory() .. sep .. "songs"

-- TODO: Make the following code work in a thread.

local path = ""
local username = os_ == "Windows" and os.getenv("USERNAME") or os.getenv("USER") or "user"
-- Figure out osu's install location and songs folder
if os_ == "Windows" then
    path = "C:\\Users\\%username%\\AppData\\Roaming\\fluXis\\maps"
elseif os_ == "Linux" then
    path = "/home/$USER/.local/share/fluXis/maps"
elseif os_ == "OS X" then
    path = "/Users/$USER/Library/Application Support/fluXis/maps"
end

-- replace $USER and %username% with the actual username
if love.system.getSystem() == "Desktop" then
    path = path:gsub("$USER", username):gsub("%%username%%", username)
end

local frame = 0

function FluxisInportScreen:enter()
    frame = 0
end

function FluxisInportScreen:update(dt)
    frame = frame + 1

    if frame == 2 then
        if importer:exists(path) then
            importer:cd(path)
            local lastDir = importer.current
            local dir, lFolders = importer:ls()

            for _, song in ipairs(lFolders) do
                importer:cd(song)
                love.filesystem.createDirectory("songs/" .. song)
                local dir, _, lFiles = importer:ls()
                for _, file in ipairs(lFiles) do
                    print(dir .. sep .. file, songsFolder .. sep .. song .. sep .. file)
                    importer:copy(dir .. sep .. file, songsFolder .. sep .. song .. sep .. file)
                end

                importer:cd(lastDir)
            end
        end

        songList = {}
        state.switch(states.screens.PreloaderScreen)
    end
end

function FluxisInportScreen:draw()
    love.graphics.printf(localize.localize("Importing fluXis songs..."), 0, Inits.GameHeight/2-100, Inits.GameWidth/2, "center", 0, 2, 2)
end

return FluxisInportScreen