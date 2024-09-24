local path = ... .. "."

Key = require(path .. "Key")
Button = require(path .. "Button")

Keyboard = require(path .. "Keyboard")
Mouse = require(path .. "Mouse")
InputClass = require(path .. "Input")

local function splitInputChars(str)
    local t = {}
    for i = 1, #str do
        t[i] = str:sub(i, i)
        if t[i] == " " then
            t[i] = "space"
        end
    end
    return t
end

local keybinds = {
    " ",
    "fj",
    "d j",
    "dfjk",
    "df jk",
    "sdfjkl",
    "sdf jkl",
    "asdfjkl;",
    "asdf jkl;",
    "asdfvnjkl;"
}

local _splittedBinds = {}
for i = 1, #keybinds do
    _splittedBinds[i] = splitInputChars(keybinds[i])
end

local controlsTbl = {
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
}

for i = 1, #keybinds do
    for j = 1, i do
        controlsTbl[i .. "k" .. j] = {Key(_splittedBinds[i][j])}
    end
end

Input = InputClass(controlsTbl)
