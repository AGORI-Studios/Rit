local Locale = {}
Locale.__index = Locale

local localesPath = "Assets/Data/Locales/"
function Locale.set(lang)
    if love.filesystem.getInfo(localesPath .. lang .. ".lua") then
        Locale.lang = lang
        Locale.data = require((localesPath .. lang):gsub("/", "."):gsub("%.lua", ""))
        if type(Locale.data) ~= "table" then
            Locale.lang = "None"
            Locale.data = {}
        end
    else
        Locale.lang = "None"
        Locale.data = {}
    end
end

Locale.set("en")

function Locale.get(key)
    if Locale.data[key] then
        return Locale.data[key]
    else
        return key
    end
end

setmetatable(Locale, {
    __call = function(_, key)
        return Locale.get(key)
    end
})

return Locale