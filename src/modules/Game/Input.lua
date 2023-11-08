input = (require "lib.baton").new({
    controls = {
        ["1k_game1"] = {"key:space"},

        ["2k_game1"] = { "key:f" },
        ["2k_game2"] = { "key:j" },

        ["3k_game1"] = { "key:d" },
        ["3k_game2"] = { "key:f" },
        ["3k_game3"] = { "key:j" },

        ["4k_game1"] = { "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d" },
        ["4k_game2"] = { "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f" },
        ["4k_game3"] = { "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j" },
        ["4k_game4"] = { "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k" },

        ["5k_game1"] = { "key:s" },
        ["5k_game2"] = { "key:d" },
        ["5k_game3"] = { "key:space" },
        ["5k_game4"] = { "key:f" },
        ["5k_game5"] = { "key:j" },

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