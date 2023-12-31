local OsuImportScreen = state()
local os_ = love.system.getOS()
local importer = lovefs()
local sep = os_ == "Windows" and "\\" or "/"
local songsFolder = love.filesystem.getSaveDirectory() .. sep .. "songs"

local path = ""
local username = os_ == "Windows" and os.getenv("USERNAME") or os.getenv("USER")
if os_ == "Windows" then
    path = "C:\\Users\\%username%\\AppData\\Local\\osu!\\Songs"
elseif os_ == "Linux" then
    path = "/home/$USER/.local/share/osu/Songs"
elseif os_ == "OS X" then
    path = "/Users/$USER/Library/Application Support/osu!/Songs"
end

-- replace $USER and %username% with the actual username
path = path:gsub("$USER", username):gsub("%%username%%", username)

function OsuImportScreen:enter()
    -- osu saves its songs as .osz files (thank god) so we can just copy one file over lol!

    if importer:exists(path) then
        importer:cd(path)
        local lastDir = importer.current
        local dir, _, lFiles = importer:ls()

        for _, song in ipairs(lFiles) do
            if song:sub(-4) == ".osz" then
                importer:copy(dir .. sep .. song, songsFolder .. sep .. song)
            end
        end
    end

    state.switch(states.menu.StartMenu)
end

return OsuImportScreen