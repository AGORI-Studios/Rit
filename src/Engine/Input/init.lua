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
    }
})
