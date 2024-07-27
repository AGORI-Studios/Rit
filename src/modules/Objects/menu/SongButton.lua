---@diagnostic disable: missing-parameter
---@class SongButton
local SongButton = Sprite:extend()

function SongButton:new(y, diffs, bmType, name, artist, creator, description, tags, gamemode, nps)
    self.super.new(self)
    self.children = {} -- List of dificulties
    self.extendedChildren = {}
    self.childrenHeight = 0
    self.open = false
    self.name = name
    self.artist = artist
    self.creator = creator
    self.description = description
    self.selected = false
    self.tags = tags
    self.gameMode = gamemode
    self.nps = nps

    self.x = 0
    self.y = y
    self.toX = 0

    self:load("assets/images/ui/menu/songTag.png")

    table.sort(diffs, function(a, b)
        return tonumber(a.nps) < tonumber(b.nps)
    end)
    
    for _, diff in ipairs(diffs) do
        local diffBtn = Sprite(0, self.height-55, "assets/images/ui/menu/diffBtn.png")
        diffBtn.text = diff.difficultyName
        diffBtn.y = #self.children * diffBtn.height * 1.1
        diffBtn.x = -diffBtn.width
        diffBtn.name = diff.difficultyName
        diffBtn.chartVer = bmType
        diffBtn.folderPath = diff.folderPath
        diffBtn.songPath = diff.songPath
        diffBtn.filename = diff.filename
        diffBtn.path = diff.path
        diffBtn.audioFile = diff.audioFile
        diffBtn.previewTime = diff.previewTime
        diffBtn.gameMode = gamemode
        diffBtn.nps = diff.nps
        diffBtn.keyMode = diff.mode
    
        table.insert(self.children, diffBtn)
    end

    self.extendedChildren[1] = Sprite(0, self.y + self.height-63, "assets/images/ui/menu/songTagSelectedBar.png")
    self.extendedChildren[1].scale.y = 0.9

    self.extendedChildren[2] = Sprite(0, self.y + self.height-63, "assets/images/ui/menu/arrowSelect.png")
    self.extendedChildren[3] = Sprite(0, self.y + self.height-63, "assets/images/ui/menu/arrowNuhUh.png")

    self.extendedChildren[4] = Sprite(0, self.y + self.height-63, "assets/images/ui/menu/arrowSelect.png")
    self.extendedChildren[5] = Sprite(0, self.y + self.height-63, "assets/images/ui/menu/arrowNuhUh.png")
    
    self.type = bmType
end

function SongButton:draw(transX, transY, current, total)
    -- return if not on screen
    if self.y + (transX or 0) < -self.height-600 or self.y + (transY or 0) > Inits.GameHeight+self.height+600 then return end

    if curTab == "songs" then
        if self.selected then
            self.extendedChildren[1].y = math.fpsLerp(self.extendedChildren[1].y, self.y + self.height - 45, 25)
            self.x = math.fpsLerp(self.x, 0, 25)
        elseif not self.selected then
            self.extendedChildren[1].y = math.fpsLerp(self.extendedChildren[1].y, self.y + self.height - 63, 25)
            self.x = math.fpsLerp(self.x, -125, 25)
        end

        -- I am so sorry for this code
        if self.selected then
            if current == 1 and current == total then
                -- two nuh uh arrowSelect
                self.extendedChildren[3].x = self.width - 180 + self.extendedChildren[3].width
                self.extendedChildren[3].y = self.y - 15
                self.extendedChildren[3].angle = 180

                self.extendedChildren[5].x = self.width - 175
                self.extendedChildren[5].y = self.y + self.height + 35
                self.extendedChildren[5].angle = 0

                self.extendedChildren[3]:draw()
                self.extendedChildren[5]:draw()
            elseif current == 1 and current ~= total then
                -- nuh uh arrow at top, arrowSelect at bottom
                self.extendedChildren[3].x = self.width - 180 + self.extendedChildren[3].width
                self.extendedChildren[3].y = self.y - 15
                self.extendedChildren[3].angle = 180

                self.extendedChildren[2].x = self.width - 175   
                self.extendedChildren[2].y = self.y + self.height + 35
                self.extendedChildren[2].angle = 0

                self.extendedChildren[3]:draw()
                self.extendedChildren[2]:draw()
            elseif current == total and current ~= 1 then
                -- arrowSelect at top, nuh uh arrow at bottom
                self.extendedChildren[4].x = self.width - 180 + self.extendedChildren[4].width
                self.extendedChildren[4].y = self.y - 15
                self.extendedChildren[4].angle = 180

                self.extendedChildren[5].x = self.width - 175
                self.extendedChildren[5].y = self.y + self.height + 35
                self.extendedChildren[5].angle = 0

                self.extendedChildren[4]:draw()
                self.extendedChildren[5]:draw()
            elseif current ~= total and current ~= 1 then
                -- two arrowSelect
                self.extendedChildren[4].x = self.width - 180 + self.extendedChildren[4].width
                self.extendedChildren[4].y = self.y - 15
                self.extendedChildren[4].angle = 180

                self.extendedChildren[2].x = self.width - 175
                self.extendedChildren[2].y = self.y + self.height + 35
                self.extendedChildren[2].angle = 0

                self.extendedChildren[4]:draw()
                self.extendedChildren[2]:draw()
            end
        end
    else
        self.extendedChildren[1].x = math.fpsLerp(self.extendedChildren[1].x, -self.width, 25)
        self.x = math.fpsLerp(self.x, -self.width, 25)
        self.extendedChildren[2].x = self.width - 175
        self.extendedChildren[2].y = self.y + self.height + 35
    end

    --[[
        self.extendedChildren[2].y = self.y - 35
        self.extendedChildren[3].y = self.y + self.height + 35
    ]]

    self.extendedChildren[1].visible = self.extendedChildren[1].y > self.y + self.height - 62
    self.extendedChildren[1].x = self.x

    self.extendedChildren[1]:draw()
    self.super.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    local name = self.name:strip()
    if fontWidth("menuExtraBoldX2.5", name) > 600 then
        local newWidth = 0
        local newString = ""
        for i = 1, #name:splitAllCharacters() do
            local char = name:sub(i, i)
            newWidth = newWidth + fontWidth("menuExtraBoldX2.5", char)
            if newWidth > 600 then
                -- break, remove last 3, and add "..."
                newString = newString:sub(1, #newString - 3) .. "..."
                break
            else
                newString = newString .. char
            end
        end
        name = newString
    end
    local lastFont = love.graphics.getFont()
    local lastColor = {love.graphics.getColor()}
    if self.selected then
        setFont("menuExtraBoldX2.5")
        love.graphics.print(name or "N/A", self.x + 10, self.y, 0, 1, 1)
        setFont("menuExtraBoldX1.5")
        local artist = (self.artist or "N/A"):strip()
        if fontWidth("menuExtraBoldX1.5", artist) > 375 then
            local newWidth = 0
            local newString = ""
            for i = 1, #artist:splitAllCharacters() do
                local char = artist:sub(i, i)
                newWidth = newWidth + fontWidth("menuExtraBoldX1.5", char)
                if newWidth > 375 then
                    -- break, remove last 3, and add "..."
                    newString = newString:sub(1, #newString - 3) .. "..."
                    break
                else
                    newString = newString .. char
                end
            end
            artist = newString
        end
        love.graphics.setColor(200/255, 80/255, 104/255)
        love.graphics.print("By " .. artist, self.x + 13, self.y + 75, 0, 1, 1)

        local diffCount = #self.children

        --local lastLineWidth = love.graphics.getLineWidth()
        --love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1)
        for i = 1, diffCount do
            if i > 6 then 
                -- put a +, and break
                love.graphics.print("+", self.x + 35 + (i-1) * 7 + fontWidth("menuExtraBoldX1.5", "By " .. artist), self.y + 72, 0, 1, 1)
                break
            else
                love.graphics.rectangle("fill", self.x + 35 + (i-1) * 7 + fontWidth("menuExtraBoldX1.5", "By " .. artist), self.y + 80, 5, 25, 2)
            end
        end
        -- italic "{diffCount} Difficulties"
        -- love2d doesn't support italic, so we gotta shear :(
            -- since shearing messes up the position, we gotta translate
        love.graphics.push()
        love.graphics.translate(self.x + 35, self.y + 80)
        love.graphics.shear(-0.3, 0)
        love.graphics.translate(-self.x - 35, -self.y - 80)
        setFont("menuBoldX1.5")
        -- display "1 Difficulty" or "2 Difficulties" after the rectangles
        love.graphics.setColor(200/255, 80/255, 104/255)
        love.graphics.print(diffCount .. " Difficult" .. (diffCount > 1 and "ies" or "y"), self.x + 15 + diffCount * 7 + 35 + fontWidth("menuExtraBoldX1.5", "By " .. artist), self.y + 72, 0, 1, 1)
        love.graphics.pop()
        
    else
        local name = self.name:strip()
        setFont("menuExtraBoldX3")
        if fontWidth("menuExtraBoldX3", name) > 500 then
            local newWidth = 0
            local newString = ""
            for i = 1, #name:splitAllCharacters() do
                local char = name:sub(i, i)
                newWidth = newWidth + fontWidth("menuExtraBoldX3", char)
                if newWidth > 500 then
                    -- break, remove last 3, and add "..."
                    newString = newString:sub(1, #newString - 3) .. "..."
                    break
                else
                    newString = newString .. char
                end
            end
            name = newString
        end
        
        love.graphics.setColor(85/255, 15/255, 55/255)
        love.graphics.print(name or "N/A", self.x + 135, self.y+20, 0, 1, 1)
    end

    love.graphics.setColor(lastColor)
    love.graphics.setFont(lastFont)
end

return SongButton