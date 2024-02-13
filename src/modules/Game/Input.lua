-- Painful way of adding all required inputs for the game
input = (require "lib.baton").new({
    controls = {
        ["1k_game1"] = {"key:space"},

        ["2k_game1"] = { "key:f" },
        ["2k_game2"] = { "key:j" },

        ["3k_game1"] = { "key:d" },
        ["3k_game2"] = { "key:space" },
        ["3k_game3"] = { "key:j" },

        ["4k_game1"] = { "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d" },
        ["4k_game2"] = { "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f" },
        ["4k_game3"] = { "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j" },
        ["4k_game4"] = { "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k" },

        ["5k_game1"] = { "key:d" },
        ["5k_game2"] = { "key:f" },
        ["5k_game3"] = { "key:space" },
        ["5k_game4"] = { "key:j" },
        ["5k_game5"] = { "key:k" },

        ["6k_game1"] = { "key:s" },
        ["6k_game2"] = { "key:d" },
        ["6k_game3"] = { "key:f" },
        ["6k_game4"] = { "key:j" },
        ["6k_game5"] = { "key:k" },
        ["6k_game6"] = { "key:l" },

        ["7k_game1"] = { "key:s" },
        ["7k_game2"] = { "key:d" },
        ["7k_game3"] = { "key:f" },
        ["7k_game4"] = { "key:space" },
        ["7k_game5"] = { "key:j" },
        ["7k_game6"] = { "key:k" },
        ["7k_game7"] = { "key:l" },

        ["8k_game1"] = { "key:a" },
        ["8k_game2"] = { "key:s" },
        ["8k_game3"] = { "key:d" },
        ["8k_game4"] = { "key:f" },
        ["8k_game5"] = { "key:j" },
        ["8k_game6"] = { "key:k" },
        ["8k_game7"] = { "key:l" },
        ["8k_game8"] = { "key:;" },

        ["9k_game1"] = { "key:a" },
        ["9k_game2"] = { "key:s" },
        ["9k_game3"] = { "key:d" },
        ["9k_game4"] = { "key:f" },
        ["9k_game5"] = { "key:space" },
        ["9k_game6"] = { "key:j" },
        ["9k_game7"] = { "key:k" },
        ["9k_game8"] = { "key:l" },
        ["9k_game9"] = { "key:;" },

        ["10k_game1"] = { "key:a" },
        ["10k_game2"] = { "key:s" },
        ["10k_game3"] = { "key:d" },
        ["10k_game4"] = { "key:f" },
        ["10k_game5"] = { "key:v" },
        ["10k_game6"] = { "key:n" },
        ["10k_game7"] = { "key:j" },
        ["10k_game8"] = { "key:k" },
        ["10k_game9"] = { "key:l" },
        ["10k_game10"] = { "key:;" },

        -- UI
        up = { "key:up", "button:dpup", "axis:lefty-" },
        down = { "key:down", "button:dpdown", "axis:lefty+" },
        left = { "key:left", "button:dpleft", "axis:leftx-" },
        right = { "key:right", "button:dpright", "axis:leftx+" },

        confirm = { "key:return", "button:a" },
        back = { "key:escape", "button:back" },

        pause = { "key:return", "button:start" },
        --restart = { "key:r", "button:b" },

        -- Misc
        extB = { "button:back" },
        volUp = { "button:rightshoulder" },
        volDown = { "button:leftshoulder" },

        quit = { "key:escape", "button:back" }
    },
    joystick = love.joystick.getJoysticks()[1]
})

local defaultBinds = {
    ["1k"] = {
        input1 = "space"
    },
    ["2k"] = {
        input1 = "f",
        input2 = "j"
    },
    ["3k"] = {
        input1 = "d",
        input2 = "space",
        input3 = "j",
    },
    ["4k"] = {
        input1 = "d",
        input2 = "f",
        input3 = "j",
        input4 = "k",
    },
    ["5k"] = {
        input1 = "d",
        input2 = "f",
        input3 = "space",
        input4 = "j",
        input5 = "k",
    },
    ["6k"] = {
        input1 = "s",
        input2 = "d",
        input3 = "f",
        input4 = "j",
        input5 = "k",
        input6 = "l",
    },
    ["7k"] = {
        input1 = "s",
        input2 = "d",
        input3 = "f",
        input4 = "space",
        input5 = "j",
        input6 = "k",
        input7 = "l",
    },
    ["8k"] = {
        input1 = "a",
        input2 = "s",
        input3 = "d",
        input4 = "f",
        input5 = "j",
        input6 = "k",
        input7 = "l",
        input8 = ";",
    },
    ["9k"] = {
        input1 = "a",
        input2 = "s",
        input3 = "d",
        input4 = "f",
        input5 = "space",
        input6 = "j",
        input7 = "k",
        input8 = "l",
        input9 = ";",
    },
    ["10k"] = {
        input1 = "a",
        input2 = "s",
        input3 = "d",
        input4 = "f",
        input5 = "v",
        input6 = "n",
        input7 = "j",
        input8 = "k",
        input9 = "l",
        input10 = ";",
    },
}

if not love.filesystem.getInfo("keybinds_config.ini") then
    ini.save(defaultBinds, "keybinds_config.ini")
else
    local binds = ini.parse("keybinds_config.ini")
    for i, v in pairs(binds) do
        for i2, v2 in pairs(v) do
            local i2 = i2:gsub("input", "")
            if i ~= "4k" then
                input:rebindControl(i .. "_game" .. i2, {"key:" .. v2})
            else
                if i2 == "1" then
                    input:rebindControl(i .. "_game" .. i2, {"axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:" .. v2})
                elseif i2 == "2" then
                    input:rebindControl(i .. "_game" .. i2, {"axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:" .. v2})
                elseif i2 == "3" then
                    input:rebindControl(i .. "_game" .. i2, {"axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:" .. v2})
                elseif i2 == "4" then
                    input:rebindControl(i .. "_game" .. i2, {"axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:" .. v2})
                end
            end
        end
    end
end