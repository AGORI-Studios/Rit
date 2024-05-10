local ServerMenu = state()

ServerMenu.serverList = {}
ServerMenu.serverButtons = {}

function ServerMenu:enter()
    if Steam and networking.connected and #self.serverList == 0 and networking.connected then
        networking.hub:publish({
            message = {
                action = "getServers",
                id = love.timer.getTime(),
                timestamp = love.timer.getTime(),
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName),
                    score = 0,
                    accuracy = 0,
                    completed = true
                }
            }
        })
    end

    ServerMenu.serverButtons = {}

    for _, server in ipairs(self.serverList) do
        table.insert(self.serverButtons, ServerButton(server.name, server.maxPlayers, server.players, server.host, server.hasPassword, server))

        self.serverButtons[#self.serverButtons].y = 100 + (#self.serverButtons - 1) * 110
    end
end

function ServerMenu:update(dt)
    if input:pressed("back") then
        state.switch(states.menu.StartMenu)
    end
end

function ServerMenu:mousepressed(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x, y)

    for _, button in ipairs(self.serverButtons) do
        if button:mousepressed(x, y, b) then
            --[[ networking.currentServerID = button.serverData.id
            networking.currentServerData = button.serverData ]]
            state.switch(states.menu.Multiplayer.LobbyMenu, button.serverData)
        end
    end
end

function ServerMenu:draw()
    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        setFont("menuExtraBold")
        love.graphics.print("Server List", 10, 10, 0, 2, 2)
        
        setFont("menuExtraBold")
        for _, button in ipairs(self.serverButtons) do
            button:draw()
        end

        if not networking.connected then
            love.graphics.print("Not connected to the server. Please try again later.", 10, 10)
        end
    love.graphics.pop()
end

return ServerMenu