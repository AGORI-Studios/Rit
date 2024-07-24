--- @class Dropdown
---@diagnostic disable-next-line: assign-type-mismatch
local Dropdown = Object:extend()

function Dropdown:new(tag, options, selectedOption, optionTag, option)
    self.tag = tag or "Dropdown"
    self.options = options or {}
    self.optionTag = optionTag or "General" -- Settings.options[self.optionTag]
    self.option = option or "selectedOption" -- Settings.options[self.optionTag][self.option]
    self.selectedOption = selectedOption or Settings.options[self.optionTag][self.option] or self.options[1] or "None"

    self.isOpen = false
    self.x, self.y = 0, 0
    self.width, self.height = 150, 30
    self.optionHeight = 31
end

function Dropdown:onSelect(option) end -- <- Override me

function Dropdown:update(dt)
end

function Dropdown:mousepressed(x, y, b)
    if b == 1 then
        if self.isOpen then
            for i, option in ipairs(self.options) do
                local optY = self.y + (i * self.optionHeight)
                if x >= self.x+400 and x <= self.x+400 + self.width and y >= optY and y <= optY + self.optionHeight then
                    self.selectedOption = option
                    Settings.options[self.optionTag][self.option] = option
                    self:onSelect(option)
                    self.isOpen = false
                    return true
                end
            end
        end
        
        if self:isHovered(x, y) then
            self.isOpen = not self.isOpen
            return true
        end
    end
    return false
end

function Dropdown:isHovered(x, y)
    return x >= self.x+400 and x <= self.x+400 + self.width and y >= self.y and y <= self.y + self.height
end

function Dropdown:draw()
    -- Draw the dropdown box
    setFont("defaultBoldX1.5")
    love.graphics.rectangle("line", self.x+400, self.y, self.width, self.height)
    love.graphics.print(self.tag, self.x, self.y) -- Print the tag above the dropdown
    setFont("defaultBoldX1.25")
    love.graphics.printf(self.selectedOption, self.x + 475-Inits.GameWidth/2, self.y+2, Inits.GameWidth, "center")
    
    if self.isOpen then
        -- Draw the options if the dropdown is open
        for i, option in ipairs(self.options) do
            local optY = self.y + (i * self.optionHeight)
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", self.x + 400, optY, self.width, self.optionHeight)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", self.x + 400, optY, self.width, self.optionHeight)
            love.graphics.printf(option, self.x + 475-Inits.GameWidth/2, optY+2, Inits.GameWidth, "center")
        end
    end
end

return Dropdown