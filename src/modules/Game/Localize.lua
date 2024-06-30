local currentLocale = "en-US"
local currentLocaleData = {}

local function loadLocale(locale)
    currentLocale = locale
    local localeFile
    if not love.filesystem.getInfo("locale/" .. locale .. ".locale.json") then
        print("Locale not found. Switching to en-US.")
        currentLocale = "en-US"
        localeFile = love.filesystem.read("locale/en-US.locale.json")
    else
        localeFile = love.filesystem.read("locale/" .. locale .. ".locale.json")
    end
    
    currentLocaleData = json.decode(localeFile)

    return {
        currentLocale = currentLocale,
        currentLocaleData = currentLocaleData
    }
end

local function localizeString(text)
    local text = text or ""
    return currentLocaleData[text] or text
end

local function getLocaleName()
    return currentLocale
end

local returnTbl = {
    loadLocale = loadLocale,
    getLocaleName = getLocaleName,
    localize = localizeString
}

local met = {}

function met.__call(...)
    local args = {...}
    
    return localizeString(args[2])
end


setmetatable(returnTbl, met)

return returnTbl
