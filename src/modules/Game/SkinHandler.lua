
local skin = {}

skin.path = "defaultSkins/Circle Default/"
skin.name = "Circle Default"

function skin:format(path)
    local path = self.path .. path
    if love.filesystem.getInfo(path) then
        return path
    else
        return path:gsub(skin.name, "skinThrowbacks")
    end
end

return skin