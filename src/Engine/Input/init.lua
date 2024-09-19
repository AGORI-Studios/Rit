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

    ["4k1"] = {Key("d")},
    ["4k2"] = {Key("f")},
    ["4k3"] = {Key("j")},
    ["4k4"] = {Key("k")},

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
