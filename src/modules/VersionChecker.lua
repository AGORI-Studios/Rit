local VersionChecker = {}
local VersionCheckerEnabled = false
local Version = "0.0.0"

-- load __VERSION__ from the file
local function loadVersion()
    -- ignore all liens that start with #
    for line in love.filesystem.lines("__VERSION__.txt") do
        if not line:match("^#") then
            Version = line
            break
        end
    end
end

--loadVersion()

-- get latest git release tag with lua-https with user agent "RitBot" UserAgent: RitBot
local GitURL = "https://api.github.com/repos/AGORI-Studios/Rit/releases/latest"
local function getLatestGitTagWithAgent()   
    local code, body, headers = https.request(GitURL, {
        headers = {
            ["User-Agent"] = "RitBot : " .. love.math.random(1, 999) .. " : " .. love.system.getOS() .. " : " .. Version
        }
    })

    if code == 200 then
        local jsonBody = json(body)
        if jsonBody.tag_name ~= Version then
            print("New version available: " .. jsonBody.tag_name)
            print("Download it here: " .. jsonBody.html_url)
        end
    else
        print("Couldn't get latest version from GitHub. Error code: " .. code)
    end
end

if VersionCheckerEnabled then
    getLatestGitTagWithAgent()
end