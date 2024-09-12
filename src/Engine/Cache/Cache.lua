local Cache = Class:extend("Cache")

function Cache:new()
    self._cache = {
        Image = ImageCache(),
        Font = FontCache(),
        Sound = SoundCache(),
    }
end

local cacheTypes = {
    "Image",
    "Font",
    "Sound",
}

function Cache:get(type, path, ...)
    if not self._cache[type] then
        error("Cache:get() requires a valid type. Valid types are: " .. table.concat(cacheTypes, ", "))
    end

    return self._cache[type]:get(path, ...)
end

function Cache:clear(type)
    if type then
        if not self._cache[type] then
            error("Cache:clear() requires a valid type. Valid types are: " .. table.concat(cacheTypes, ", "))
        end

        self._cache[type]:clear()
    else
        for _, cache in pairs(self._cache) do
            cache:clear()
        end
    end
end

function Cache:clearAll()
    for _, cache in pairs(self._cache) do
        cache:clear()
    end
end

function Cache:load(type, path, ...)
    if not self._cache[type] then
        error("Cache:load() requires a valid type. Valid types are: " .. table.concat(cacheTypes, ", "))
    end

    return self._cache[type]:load(path, ...)
end

return Cache