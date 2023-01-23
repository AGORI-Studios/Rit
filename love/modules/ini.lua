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

local ini = {}

function ini.load(iniFile)
    -- convert the ini file into a table
    local iniTable = {}
    local lines = love.filesystem.lines(iniFile)
    local curSection = nil

    for line in lines do
        -- if the line is a section
        if line:find("%[") then
            -- get the section name
            local section = line:match("%[(.*)%]")
            -- if the section doesn't exist, create it
            if not iniTable[section] then
                iniTable[section] = {}
            end
            -- set the current section to the section we just found
            curSection = iniTable[section]
        -- if the line is a key
        elseif line:find("=") then
            -- get the key and value
            local key, value = line:match("(.*)=(.*)")
            -- if the key doesn't exist, create it
            if not curSection[key] then
                curSection[key] = {}
            end
            -- set the current key to the value we just found
            curSection[key] = value
        end
    end
    
    return iniTable
end

function ini.readKey(iniTable, sectionName, keyName)
    -- return the value of the key
    return iniTable[sectionName][keyName]
end

function ini.isKey(iniTable, sectionName, keyName)
    -- return true if the key exists
    return iniTable[sectionName][keyName] ~= nil
end

function ini.isSection(iniTable, sectionName)
    -- return true if the section exists
    return iniTable[sectionName] ~= nil
end

return ini