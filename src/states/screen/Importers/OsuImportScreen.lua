---@unused
---@deprecated

--[[

UNUSED NOW AS OF 24/07/2024.
https://x.com/GuglioIsStupid/status/1815980056478368129
https://github.com/ppy/osu/wiki/User-file-storage
https://github.com/ppy/osu/issues/3910#issuecomment-543239384

Technically speaking, this still works for OLD osu! installs. 
This will not work however for osu!lazer due to the file structure difference and using file hashing for storing its songs.

]]--

---@diagnostic disable: param-type-mismatch
local OsuImportScreen = state()
local os_ = love.system.getOS()
local sep = os_ == "Windows" and "\\" or "/"
local songsFolder = love.filesystem.getSaveDirectory() .. sep .. "songs"

local pathOLD = ""
local username = os_ == "Windows" and os.getenv("USERNAME") or os.getenv("USER") or "user"
-- Figure out osu's install location and songs folder
if os_ == "Windows" then
    pathOLD = "C:\\Users\\%username%\\AppData\\Local\\osu!\\Songs"
elseif os_ == "Linux" then
    pathOLD = "/home/$USER/.local/share/osu/Songs"
elseif os_ == "OS X" then
    pathOLD = "/Users/$USER/Library/Application Support/osu!/Songs"
end

local pathLAZER = ""
if os_ == "Windows" then
    pathLAZER = "C:\\Users\\%username%\\AppData\\Roaming\\osu\\Songs"
elseif os_ == "Linux" then
    pathLAZER = "/home/$USER/.local/share/osu/Songs"
elseif os_ == "OS X" then
    pathLAZER = "/Users/$USER/Library/Application Support/osu!/Songs"
end

if love.system.getSystem() == "Desktop" then
    pathOLD = pathOLD:gsub("$USER", username):gsub("%%username%%", username)
    pathLAZER = patpathLAZERhOLD:gsub("$USER", username):gsub("%%username%%", username)
end

local frame = 0

function OsuImportScreen:enter()
    frame = 0
end

function OsuImportScreen:update(dt)
    frame = frame + 1

    if frame == 2 then
        -- osu saves its songs as .osz files (thank god) so we can just copy one file over lol!

        if importer:exists(pathOLD) then
            importer:cd(pathOLD)
            local lastDir = importer.current
            local dir, _, lFiles = importer:ls()

            for _, song in ipairs(lFiles) do
                if song:sub(-4) == ".osz" then
                    importer:copy(dir .. sep .. song, songsFolder .. sep .. song)
                end
            end
        end

        state.switch(states.screens.Importers.fluXisImportScreen)
    end
end

function OsuImportScreen:draw()
    love.graphics.printf(localize("Importing osu! songs..."), 0, Inits.GameHeight/2-100, Inits.GameWidth/2, "center", 0, 2, 2)
end

return OsuImportScreen