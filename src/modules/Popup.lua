local Popup = Object:extend()
Popup.popups = {}

function Popup:new(dir, title, text, fadeTime, delay)
    self.pos = dir or "bottom right"
    self.title = title or "Popup"
    self.text = text or "This is a popup."
    self.fadeTime = fadeTime or 0.5
    self.delay = delay or 0.5
    self.fade = 0
    self.timer = 0
    self.index = #Popup.popups + 1

    Timer.tween(self.fadeTime, self, {fade = 1}, "linear", function()
        Timer.after(self.delay, function()
            self:destroy()
        end)
    end)
    
    table.insert(Popup.popups, self)
end

function Popup:update(dt)
    self.timer = self.timer + dt
    
end

function Popup:destroy()
    Timer.tween(self.fadeTime, self, {fade = 0}, "linear", function()
        table.remove(Popup.popups, self.index)
    end)
end

function Popup:draw()
    local w, h = love.graphics.getDimensions()
    local x, y = 0, 0
    if self.pos == "bottom right" then
        x, y = w - 400, h - 200
    elseif self.pos == "bottom left" then
        x, y = 0, h - 200
    elseif self.pos == "top right" then
        x, y = w - 400, 0
    elseif self.pos == "top left" then
        x, y = 0, 0
    end
    
    love.graphics.setColor(0.75, 0.75, 0.75, self.fade)
    love.graphics.rectangle("fill", x, y, 400, 200)
    love.graphics.setColor(0.5, 0.5, 0.5, self.fade)
    love.graphics.rectangle("fill", x, y, 400, 25)
    love.graphics.setColor(0.15, 0.15, 0.15, self.fade)
    love.graphics.printf(self.title, x, y, 400, "center")
    love.graphics.printf(self.text, x, y + 25, 400, "center")

end

return Popup