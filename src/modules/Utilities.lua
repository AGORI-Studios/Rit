--[[----------------------------------------------------------------------------

This file is apart of Rit; a free and open sourced rhythm game made with LÖVE.

Copyright (C) 2023 GuglioIsStupid

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

------------------------------------------------------------------------------]]

for i, module in ipairs(love.filesystem.getDirectoryItems("modules/Lua")) do
    if module:sub(-4) == ".lua" then
        require("modules.Lua." .. module:sub(1, -5))
    end
end
for i, module in ipairs(love.filesystem.getDirectoryItems("modules/Love")) do
    if module:sub(-4) == ".lua" then
        require("modules.Love." .. module:sub(1, -5))
    end
end

--@name Try
--@description Tries to run a function, and if it fails, runs another function
--@param f function
--@param catch_f function
--@return nil
function Try(f, catch_f)
    local returnedValue = pcall(f)
    if not returnedValue then
        catch_f()
    end

    return returnedValue
end

--@name switch
--@description calls a function based on a value
--@param value any
--@param cases table
--@return any
function Switch(value, cases) -- similar to the case statement in C
    if cases[value] then
        return cases[value]()
    elseif cases.default then
        return cases.default()
    end
    return value
end
