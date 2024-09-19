---@class Skin
local Skin = {}

function Skin:loadSkin(path)
    self.skin = love.filesystem.load(path)()
    self.skin.__lua_path = path
    self.skin.__folder_path = path:match("(.*/)")
    self.skinnedStates = {}
    self.skin._noteAssets = {}

    for name, state in pairs(self.skin.Scripts.States) do
        local filename = state:match("([^/]+)$")

        if love.filesystem.getInfo(self.skin.__folder_path .. state) then
            self.skinnedStates[name] = love.filesystem.load(self.skin.__folder_path .. state)()
        else
            self.skinnedStates[name] = love.filesystem.load("Assets/IncludedSkins/SkinThrowbacks/scripts/states/" .. filename)()
        end
    end

    for i, lanes in ipairs(self.skin.Notes) do
        self.skin._noteAssets[i] = {}
        for j, curLane in ipairs(lanes) do
            --[[ local noteAssetPath = self.skin.__folder_path .. curLane["Note"] ]]
            local noteAssetPath = self:getPath(curLane["Note"])
            local receptorPressedPath = self:getPath(curLane["Pressed"])
            local receptorUnpressedPath = self:getPath(curLane["Unpressed"])
            self.skin._noteAssets[i][j] = {
                ["Note"] = love.graphics.newImage(noteAssetPath),
                
                ["Pressed"] = love.graphics.newImage(receptorPressedPath),
                ["Unpressed"] = love.graphics.newImage(receptorUnpressedPath)
            }
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