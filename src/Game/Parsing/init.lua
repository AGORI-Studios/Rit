local path = ... .. "."

local Parsers = {}

Parsers.Quaver = require(path .. "Quaver")
Parsers.Rit = require(path .. "Rit")

return Parsers