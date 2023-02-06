sh = {}

function sh.saveSettings(tabel) 
    --[[
    -- save layout will be like
    (TYPE)-"settingName":value|"settingName2":value2(TYPE2)-etc
    --]]
    -- will result in a table like 
    -- given table will be like
    --[[
    {
        ["TYPE"] = {
            ["settingName"] = value,
            ["settingName2"] = value2
        },
        ["TYPE2"] = {
            ["settingName"] = value,
            ["settingName2"] = value2
        }
    --]]

    local saveString = ""
    for k,v in pairs(tabel) do
        saveString = saveString .. "(" .. k .. ")-"
        for k2,v2 in pairs(v) do
            k2, v2 = tostring(k2), tostring(v2)
            saveString = saveString .. k2 .. "|" .. v2 .. "|"
        end
        saveString = saveString .. ":"
    end
    love.filesystem.write("settings.ritsettings", saveString)
end

function sh.loadSettings()
    local saveString = love.filesystem.read("settings.ritsettings")
    if not saveString then
        lol = {
            ["Game"] = {
                ["Downscroll"] = true,
                ["Scroll speed"] = 1.0,
                ["Scroll Velocities"] = true,
                ["Start Time"] = true,
                ["Note Spacing"] = 200,
                ["Autoplay"] = false,
                ["Audio Offset"] = 0
            },
            ["Graphics"] = {
                ["Width"] = 1280,
                ["Height"] = 720,
                ["Fullscroll"] = false,
                ["Vsync"] = false
            },
            ["Audio"] = {
                ["Volume"] = 1.0
            },
            ["System"] = {
                ["Version"] = "settingsVer1/0.0.3-beta"
            }
        }
        sh.saveSettings(lol)

        return lol
    end

    local saveTable = {}
    --[[
    -- save layout will be like
    (TYPE)-"settingName":value|"settingName2":value2(TYPE2)-etc
    --]]

    local curType = ""
    local curSetting = ""
    local curValue = ""


    return saveTable
end

return sh