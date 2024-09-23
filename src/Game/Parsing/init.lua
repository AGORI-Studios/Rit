local path = ... .. "."

local Parsers = {}

Parsers.Quaver = require(path .. "Quaver")
Parsers.Rit = require(path .. "Rit")
Parsers.Osu = require(path .. "Osu")

return Parsers