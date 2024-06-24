---@class ServerButton
---@diagnostic disable-next-line: assign-type-mismatch
local ServerButton = Object:extend()

function ServerButton:new(name, maxPlayers, players, host, hasPassword, hasStarted, serverData)
    self.name = name or "Test Server"
    self.maxPlayers = maxPlayers or 4
    self.players = players or {}
    self.host = host or "Unknown"
    self.hasPassword = hasPassword or false
    self.x, self.y = 0, 0 
    self.width, self.height = 800, 100
    self.hasStarted = hasStarted or false
    self.serverData = serverData

    return self
end

function ServerButton:mousepressed(x, y, b)
    if x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height then
        return not self.hasStarted
    end
    return false
end

function ServerButton:draw()
    if self.hasStarted then
        love.graphics.setColor(0.7, 0.5, 0.5)
    else
        love.graphics.setColor(0.5, 0.7, 0.5)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.name, self.x + 10, self.y + 10)
    love.graphics.print("Host: " .. self.host, self.x + 10, self.y + 30)
    love.graphics.print("Players: " .. #self.players .. "/" .. self.maxPlayers, self.x + 250, self.y + 10)
    love.graphics.print("Password: " .. (self.hasPassword and "Yes" or "No"), self.x + 250, self.y + 30)
    if self.hasStarted then
        love.graphics.print("Game has started. Please check back later.", self.x + 10, self.y + 50)
    end
end

return ServerButton
