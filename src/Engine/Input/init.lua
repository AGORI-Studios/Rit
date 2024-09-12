local path = ... .. "."

Keyboard = require(path .. "Keyboard")
InputClass = require(path .. "Input")

Input = InputClass({
    MenuPress = {"return", "space", "m"}
})
