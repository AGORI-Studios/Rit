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

local SongButton = Sprite:extend()

function SongButton:new(y, diffs, bmType, name, creator)
    self.super.new(self)
    self.children = {} -- List of dificulties
    self.childrenHeight = 0
    self.open = false
    self.name = name
    self.creator = creator

    self.x = 0
    self.y = y

    self:load("assets/images/ui/menu/songBtn.png")

    for i, diff in ipairs(diffs) do
        local diffBtn = Sprite(0, self.height-55, "assets/images/ui/menu/diffBtn.png")
        diffBtn.text = diff.difficultyName
        table.insert(self.children, diffBtn)
        diffBtn.y = (#self.children-1) * diffBtn.height * 1.1
        diffBtn.x = -diffBtn.width
        diffBtn.name = diff.difficultyName
        diffBtn.chartVer = bmType
        diffBtn.folderPath = diff.folderPath
        diffBtn.songPath = diff.songPath
        diffBtn.filename = diff.filename
        diffBtn.path = diff.path
    end
    
    self.type = bmType
end

function SongButton:draw()
    self.super.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    local name = self.name
    if fontWidth("menuBold", name) > 317 then
        local newWidth = 0
        local newString = ""
        for i = 1, #name:splitAllCharacters() do
            local char = name:sub(i, i)
            newWidth = newWidth + fontWidth("menuBold", char)
            if newWidth > 317 then
                -- break, remove last 3, and add "..."
                newString = newString:sub(1, #newString - 3) .. "..."
                break
            else
                newString = newString .. char
            end
        end
        name = newString
    end
    love.graphics.print(name or "N/A", self.x + 10, self.y + 60, 0, 2, 2)
end

return SongButton