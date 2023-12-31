local Popup = Object:extend()

function Popup:new(dir, title, text, fadeTime, delay)
    self.pos = dir or "bottom right" -- scrolls from the right
    self.title = title or "Popup"
    self.text = text or "This is a popup."
    self.fadeTime = fadeTime or 0.5
    self.delay = delay or 0.5
    self.fade = 0
    self.timer = 0

    Timer.after(self.delay, function()
        Timer.tween(self.fadeTime, self, {fade = 1}, "linear", function()
            self:destroy()
        end)
    end)
    
end

function Popup:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.delay then
        self.fade = math.min(self.fade + dt/self.fadeTime, 1)
    end
end

function Popup:destroy()
    Timer.tween(self.fadeTime, self, {fade = 0}, "linear", function()
        state:remove(self)
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
    love.graphics.setColor(0,0,0,self.fade)
    love.graphics.rectangle("fill", x, y, 400, 200)
    love.graphics.setColor(1,1,1,self.fade)
    love.graphics.printf(self.title, x, y, 400, "center")
    love.graphics.printf(self.text, x, y + 50, 400, "center")
    love.graphics.setColor(1,1,1,1)
end