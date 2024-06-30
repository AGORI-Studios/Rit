local ServerMenu = state()

ServerMenu.serverList = {}
ServerMenu.serverButtons = {}

function ServerMenu:enter()
    if Steam and networking.connected and #self.serverList == 0 and networking.connected then
        networking.hub:publish({
            message = {
                action = "updateServerInfo_FORCEREMOVEUSER",
                id = networking.currentServerID,
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName)
                }
            }
        })

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
        table.insert(self.serverButtons, ServerButton(server.name, server.maxPlayers, server.players, server.host, server.hasPassword, server.started, server))

        self.serverButtons[#self.serverButtons].y = 190 + (#self.serverButtons - 1) * 110
    end

    if discordRPC then
        local details = ""
        discordRPC.presence = {
            details = localize("Browsing multiplayer lobbies"),
            state = localize("In the lobby list"),
            largeImageKey = "totallyreallogo",
            largeImageText = "Rit" .. (__DEBUG__ and " DEBUG MODE" or "")
        }
        GameInit.UpdateDiscord()
    end
end

function ServerMenu:update(dt)
    if input:pressed("back") then
        switchState(states.menu.StartMenu, 0.3)
    end
end

function ServerMenu:mousepressed(x, y, b)
    if state.inSubstate then return end
    local x, y = toGameScreen(x, y)
    local canc = Header:mousepressed(x, y, b)
    if canc then return end

    for _, button in ipairs(self.serverButtons) do
        if button:mousepressed(x, y, b) then
            switchState(states.menu.Multiplayer.LobbyMenu, 0.3, nil, button.serverData)
        end
    end
end

function ServerMenu:draw()
    Header:draw()
    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        setFont("menuExtraBold")
        love.graphics.print(localize("Server List"), 10, 100, 0, 2, 2)
        
        setFont("menuExtraBold")
        for _, button in ipairs(self.serverButtons) do
            button:draw()
        end

        if not Steam or not networking.connected then
            love.graphics.print(localize("Not connected to the server.\nIt's possible it is offline currently."), 10, 190, 0, 1.5, 1.5)
        end
    love.graphics.pop()
end

return ServerMenu