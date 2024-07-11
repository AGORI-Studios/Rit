---@diagnostic disable: assign-type-mismatch, duplicate-set-field
---@class OverlayObject
local OverlayObject = Object:extend()

function OverlayObject:new(options, formatString)
    local options = options or {}
    self.font = love.graphics.newFont("assets/fonts/Montserrat-Medium.ttf", 16)
    self.formatString = formatString or "_: %s"
    self.formatReplacement = options.formatReplacement or formatString:find("%s") and "_" or 0
    self.time = 0
    self.x = options.x or 0
    self.y = options.y or 0
    self.width = options.width or 80
    self.height = options.height or 30
    self.cornerRadius = options.cornerRadius or 5

    self.doFontColor = options.doFontColor or false
    self.color = {1, 1, 1}
    self.checkFontFunc = options.checkFontFunc or function(self) self.color = {0, 1, 0, 1} end
end

function OverlayObject:update(dt, newParamFunc)
    self.time = self.time + dt
    if self.time >= 1 then
        self.formatReplacement = newParamFunc()
        self.time = 0

        if self.doFontColor then
            self:checkFontFunc()
        end
    end
end

function OverlayObject:draw()
    local lastFont = love.graphics.getFont()
    local lastColor = {love.graphics.getColor()}
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)
    love.graphics.setColor(1, 1, 1, 1)
    --[[ love.graphics.printf("FPS: " .. self.fps, self.x, self.y + self.height/2 - self.font:getHeight()/2, self.width, "center") ]]
    love.graphics.printf({{unpack(self.color)}, string.format(self.formatString, self.formatReplacement)}, self.x, self.y + self.height/2 - self.font:getHeight()/2, self.width, "center")
    
    love.graphics.setFont(lastFont)
    love.graphics.setColor(lastColor)
end

return OverlayObject