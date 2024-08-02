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

local ctrlTable = {
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
}

for i = 1, 10 do
    for k = 1, i do
        ctrlTable[i .. "k_game" .. k] = {"key:" .. string.lower(_G["__k" .. i .. "Binds"][k])} 
    end
end

input = (require "lib.baton").new({
    controls = ctrlTable,
    joystick = love.joystick.getJoysticks()[1]
})
