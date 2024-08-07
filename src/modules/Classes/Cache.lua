local Cache = {}

Cache.members = {
    image = {},
    font = {},
    sound = {},
    music = {},
    sprite = {},
    imageData = {},
}

function Cache:clear()
    for k, _ in pairs(self.members) do
        self.members[k] = {}
    end
end

function Cache:loadImageData(...) -- so we can load multiple images at once
    --                           also makes it so we don't re-load the same image
    local tbl = {...}
    for i, v in ipairs(tbl) do
        if not self.members.imageData[v] then
            if type(v) == "table" then return end
            self.members.imageData[v] = love.image.newImageData(v)
        else
            return nil
        end

        if #tbl == 1 then
            return self.members.imageData[v]
        else
            if i == #tbl then
                return self.members.imageData[v]
            end
        end
    end
end

function Cache:loadImage(...) -- so we can load multiple images at once
    --                           also makes it so we don't re-load the same image
    local tbl = {...}
    for i, v in ipairs(tbl) do
        if not self.members.image[v] then
            if type(v) == "table" then return end
            self.members.image[v] = love.graphics.newImage(v)
        end

        if #tbl == 1 then
            return self.members.image[v]
        else
            if i == #tbl then
                return self.members.image[v]
            end
        end
    end
end

function Cache:loadFont(path, size)
    if not self.members.font[path] then
        self.members.font[path] = love.graphics.newFont(path, size)
    end

    return self.members.font[path]
end

function Cache:loadSound(path)
    if not self.members.sound[path] then
        self.members.sound[path] = love.audio.newSource(path, "static")
    end

    return self.members.sound[path]
end

function Cache:loadMusic(path)
    if not self.members.music[path] then
        self.members.music[path] = love.audio.newSource(path, "stream")
    end

    return self.members.music[path]
end

--[[ function Cache:loadSprite(path, width, height)
    if not self.members.sprite[path] then
        self.members.sprite[path] = Sprite(path, width, height)
    end

    return self.members.sprite[path]
end ]]

return Cache