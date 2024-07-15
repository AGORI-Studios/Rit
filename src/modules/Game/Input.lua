---@diagnostic disable: param-type-mismatch
-- Painful way of adding all required inputs for the game
__k1Binds = Settings.options["Keybinds"]["1kBinds"]:splitAllCharacters()
__k2Binds = Settings.options["Keybinds"]["2kBinds"]:splitAllCharacters()
__k3Binds = Settings.options["Keybinds"]["3kBinds"]:splitAllCharacters()
__k4Binds = Settings.options["Keybinds"]["4kBinds"]:splitAllCharacters()
__k5Binds = Settings.options["Keybinds"]["5kBinds"]:splitAllCharacters()
__k6Binds = Settings.options["Keybinds"]["6kBinds"]:splitAllCharacters()
__k7Binds = Settings.options["Keybinds"]["7kBinds"]:splitAllCharacters()
__k8Binds = Settings.options["Keybinds"]["8kBinds"]:splitAllCharacters()
__k9Binds = Settings.options["Keybinds"]["9kBinds"]:splitAllCharacters()
__k10Binds = Settings.options["Keybinds"]["10kBinds"]:splitAllCharacters()

for i = 1, 10 do
    for j = 1, #_G["__k" .. i .. "Binds"] do
        _G["__k" .. i .. "Binds"][j] = _G["__k" .. i .. "Binds"][j] == " " and "space" or _G["__k" .. i .. "Binds"][j]
    end
end

local k1Binds = __k1Binds
local k2Binds = __k2Binds
local k3Binds = __k3Binds
local k4Binds = __k4Binds
local k5Binds = __k5Binds
local k6Binds = __k6Binds
local k7Binds = __k7Binds
local k8Binds = __k8Binds
local k9Binds = __k9Binds
local k10Binds = __k10Binds

input = (require "lib.baton").new({
    controls = {
        ["1k_game1"] = { "key:" .. string.lower(k1Binds[1])},

        ["2k_game1"] = { "key:" .. string.lower(k2Binds[1])},
        ["2k_game2"] = { "key:" .. string.lower(k2Binds[2])},

        ["3k_game1"] = { "key:" .. string.lower(k3Binds[1])},
        ["3k_game2"] = { "key:" .. string.lower(k3Binds[2])},
        ["3k_game3"] = { "key:" .. string.lower(k3Binds[3])},

        ["4k_game1"] = { "key:" .. string.lower(k4Binds[1])},
        ["4k_game2"] = { "key:" .. string.lower(k4Binds[2])},
        ["4k_game3"] = { "key:" .. string.lower(k4Binds[3])},
        ["4k_game4"] = { "key:" .. string.lower(k4Binds[4])},

        ["5k_game1"] = { "key:" .. string.lower(k5Binds[1])},
        ["5k_game2"] = { "key:" .. string.lower(k5Binds[2])},
        ["5k_game3"] = { "key:" .. string.lower(k5Binds[3])},
        ["5k_game4"] = { "key:" .. string.lower(k5Binds[4])},
        ["5k_game5"] = { "key:" .. string.lower(k5Binds[5])},

        ["6k_game1"] = { "key:" .. string.lower(k6Binds[1])},
        ["6k_game2"] = { "key:" .. string.lower(k6Binds[2])},
        ["6k_game3"] = { "key:" .. string.lower(k6Binds[3])},
        ["6k_game4"] = { "key:" .. string.lower(k6Binds[4])},
        ["6k_game5"] = { "key:" .. string.lower(k6Binds[5])},
        ["6k_game6"] = { "key:" .. string.lower(k6Binds[6])},

        ["7k_game1"] = { "key:" .. string.lower(k7Binds[1])},
        ["7k_game2"] = { "key:" .. string.lower(k7Binds[2])},
        ["7k_game3"] = { "key:" .. string.lower(k7Binds[3])},
        ["7k_game4"] = { "key:" .. string.lower(k7Binds[4])},
        ["7k_game5"] = { "key:" .. string.lower(k7Binds[5])},
        ["7k_game6"] = { "key:" .. string.lower(k7Binds[6])},
        ["7k_game7"] = { "key:" .. string.lower(k7Binds[7])},

        ["8k_game1"] = { "key:" .. string.lower(k8Binds[1])},
        ["8k_game2"] = { "key:" .. string.lower(k8Binds[2])},
        ["8k_game3"] = { "key:" .. string.lower(k8Binds[3])},
        ["8k_game4"] = { "key:" .. string.lower(k8Binds[4])},
        ["8k_game5"] = { "key:" .. string.lower(k8Binds[5])},
        ["8k_game6"] = { "key:" .. string.lower(k8Binds[6])},
        ["8k_game7"] = { "key:" .. string.lower(k8Binds[7])},
        ["8k_game8"] = { "key:" .. string.lower(k8Binds[8])},

        ["9k_game1"] = { "key:" .. string.lower(k9Binds[1])},
        ["9k_game2"] = { "key:" .. string.lower(k9Binds[2])},
        ["9k_game3"] = { "key:" .. string.lower(k9Binds[3])},
        ["9k_game4"] = { "key:" .. string.lower(k9Binds[4])},
        ["9k_game5"] = { "key:" .. string.lower(k9Binds[5])},
        ["9k_game6"] = { "key:" .. string.lower(k9Binds[6])},
        ["9k_game7"] = { "key:" .. string.lower(k9Binds[7])},
        ["9k_game8"] = { "key:" .. string.lower(k9Binds[8])},
        ["9k_game9"] = { "key:" .. string.lower(k9Binds[9])},

        ["10k_game1"] = { "key:" .. string.lower(k10Binds[1])},
        ["10k_game2"] = { "key:" .. string.lower(k10Binds[2])},
        ["10k_game3"] = { "key:" .. string.lower(k10Binds[3])},
        ["10k_game4"] = { "key:" .. string.lower(k10Binds[4])},
        ["10k_game5"] = { "key:" .. string.lower(k10Binds[5])},
        ["10k_game6"] = { "key:" .. string.lower(k10Binds[6])},
        ["10k_game7"] = { "key:" .. string.lower(k10Binds[7])},
        ["10k_game8"] = { "key:" .. string.lower(k10Binds[8])},
        ["10k_game9"] = { "key:" .. string.lower(k10Binds[9])},
        ["10k_game10"] = { "key:" .. string.lower(k10Binds[10])},

        -- UI
        up = { "key:up", "button:dpup", "axis:lefty-" },
        down = { "key:down", "button:dpdown", "axis:lefty+" },
        left = { "key:left", "button:dpleft", "axis:leftx-" },
        right = { "key:right", "button:dpright", "axis:leftx+" },

        confirm = { "key:return", "button:a" },
        back = { "key:escape", "button:back" },

        -- Song Selection
        randomSong = { "key:r" },

        -- Gameplay
        pause = { "key:return", "button:start" },
        restart = { "key:`" },

        -- Misc
        extB = { "button:back" },
        volUp = { "button:rightshoulder" },
        volDown = { "button:leftshoulder" },

        quit = { "key:escape", "button:back" },

        Skip_Key = { "key:space" }
    },
    joystick = love.joystick.getJoysticks()[1]
})

__defaultBinds = {
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
