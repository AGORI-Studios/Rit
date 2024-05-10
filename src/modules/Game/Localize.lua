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

local function localize(text)
    if currentLocaleData[text] then
        return currentLocaleData[text]
    else
        return text
    end
end

return {
    loadLocale = loadLocale,
    localize = localize
}