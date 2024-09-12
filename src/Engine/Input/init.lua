local path = (...):match("(.-)[^%.]+$")

Keyboard = require(path .. "Input.Keyboard")
InputClass = require(path .. "Input.Input")

Input = InputClass({
    MenuPress = {"return", "space", "m"}
})
