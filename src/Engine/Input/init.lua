local path = ... .. "."

Key = require(path .. "Key")
Button = require(path .. "Button")

Keyboard = require(path .. "Keyboard")
Mouse = require(path .. "Mouse")
InputClass = require(path .. "Input")

Input = InputClass({
    MenuPress = {
        Key("return"),
        Key("space"),
        Key("m"),
        Button("1")
    },

    -- MANIA BINDS
    ["1k1"] = {Key("Space")},

    ["2k1"] = {Key("f")},
    ["2k2"] = {Key("j")},

    ["3k1"] = {Key("d")},
    ["3k2"] = {Key("space")},
    ["3k3"] = {Key("j")},

    ["4k1"] = {Key("d")},
    ["4k2"] = {Key("f")},
    ["4k3"] = {Key("j")},
    ["4k4"] = {Key("k")},

    ["5k1"] = {Key("s")},
    ["5k2"] = {Key("d")},
    ["5k3"] = {Key("space")},
    ["5k4"] = {Key("j")},
    ["5k5"] = {Key("k")},

    ["6k1"] = {Key("s")},
    ["6k2"] = {Key("d")},
    ["6k3"] = {Key("f")},
    ["6k4"] = {Key("j")},
    ["6k5"] = {Key("k")},
    ["6k6"] = {Key("l")},

    ["7k1"] = {Key("s")},
    ["7k2"] = {Key("d")},
    ["7k3"] = {Key("f")},
    ["7k4"] = {Key("space")},
    ["7k5"] = {Key("j")},
    ["7k6"] = {Key("k")},
    ["7k7"] = {Key("l")},

    ["8k1"] = {Key("a")},
    ["8k2"] = {Key("s")},
    ["8k3"] = {Key("d")},
    ["8k4"] = {Key("f")},
    ["8k5"] = {Key("j")},
    ["8k6"] = {Key("k")},
    ["8k7"] = {Key("l")},
    ["8k8"] = {Key(";")},

    ["9k1"] = {Key("a")},
    ["9k2"] = {Key("s")},
    ["9k3"] = {Key("d")},
    ["9k4"] = {Key("f")},
    ["9k5"] = {Key("space")},
    ["9k6"] = {Key("j")},
    ["9k7"] = {Key("k")},
    ["9k8"] = {Key("l")},
    ["9k9"] = {Key(";")},

    ["10k1"] = {Key("a")},
    ["10k2"] = {Key("s")},
    ["10k3"] = {Key("d")},
    ["10k4"] = {Key("f")},
    ["10k5"] = {Key("v")},
    ["10k6"] = {Key("n")},
    ["10k7"] = {Key("j")},
    ["10k8"] = {Key("k")},
    ["10k9"] = {Key("l")},
    ["10k10"] = {Key(";")},

    MenuDown = {
        Key("down"),
    },
    MenuUp = {
        Key("up"),
    },
    MenuBack = {
        Key("escape"),
    },
    MenuConfirm = {
        Key("return")
    },
})
