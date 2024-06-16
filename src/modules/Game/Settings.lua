local Settings = {}

Settings.options = {
    ["General"] = {
        downscroll = true,
        scrollspeed = 2,
        backgroundVisibility = 1,
        skin = {
            name = "Circle Default",
            path = "Circle Default",
            scale = 1
        },
        hitsoundVolume = 0.1,
        globalVolume = 0.1,
        noScrollVelocity = false,

        backgroundDim = 0.5,
        backgroundBlur = 2.5,

        language = "en-US",

        debugText = false,

        noteSize = 1, -- 100%
        columnSpacing = 0, -- 0px

        scrollUnderlayAlpha = 1,
    },
    ["Video"] = {
        ["VSYNC"] = false,
    },
    ["Keybinds"] = {
        -- Characters like " " get converted to the text "space"
        ["1kBinds"] = " ",
        ["2kBinds"] = "fj",
        ["3kBinds"] = "f j",
        ["4kBinds"] = "dfjk",
        ["5kBinds"] = "df jk",
        ["6kBinds"] = "sdfjkl",
        ["7kBinds"] = "sdf jkl",
        ["8kBinds"] = "asdfjkl;",
        ["9kBinds"] = "asdf jkl;",
        ["10kBinds"] = "asdfvnjkl;"
    },
    ["Events"] = {
        aprilFools = true,
    },
    ["Meta"] = {
        __VERSION__ = 1
    }
}

function Settings.saveOptions()
    if not love.filesystem.getInfo("data") then
        love.filesystem.createDirectory("data")
    end
    love.filesystem.write("data/settings.rsetting", json.encode(Settings.options))
end

function Settings.loadOptions()
    if not love.filesystem.getInfo("data/settings.rsetting") then
        Settings.saveOptions()
    end

    --Settings.options = ini.parse("settings")
    local savedOptions --= json.decode(love.filesystem.read("settings"))
    Try(
        function()
            savedOptions = json.decode(love.filesystem.read("data/settings.rsetting"))
        end,
        function()
            love.window.showMessageBox(
                "Error",
                "There was an error loading the settings file. Your settings have been reset.",
                "error"
            )
            Settings.saveOptions()
        end
    )
    for i, type in pairs(savedOptions) do
        for j, setting in pairs(type) do
            Settings.options[i][j] = savedOptions[i][j]
        end
    end
end

return Settings