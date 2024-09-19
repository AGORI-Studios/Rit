---@class Skin
local Skin = {}

function Skin:loadSkin(path)
    self.skin = love.filesystem.load(path)()
    self.skin.__lua_path = path
    self.skin.__folder_path = path:match("(.*/)")
    self.skinnedStates = {}

    for name, state in pairs(self.skin.Scripts.States) do
        local filename = state:match("([^/]+)$")

        if love.filesystem.getInfo(self.skin.__folder_path .. state) then
            self.skinnedStates[name] = love.filesystem.load(self.skin.__folder_path .. state)()
        else
            self.skinnedStates[name] = love.filesystem.load("Assets/IncludedSkins/SkinThrowbacks/scripts/states/" .. filename)()
        end
    end

    setmetatable(self, {__index = self.skin})
end

function Skin:getPath(path)
    if love.filesystem.getInfo(path) then
        return self.skin.__folder_path .. path
    end

    return "Assets/IncludedSkins/SkinThrowbacks/" .. path
end

function Skin:getSkinnedState(name)
    if self.skinnedStates[name] then
        return self.skinnedStates[name]
    end

    -- get throwback from default skin
    return love.filesystem.load("Assets/IncludedSkins/SkinThrowbacks/scripts/states/" .. name .. ".lua")()
end

return Skin