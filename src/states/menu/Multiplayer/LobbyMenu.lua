local LobbyMenu = state()

local checkingForSong = 0 -- every 5 seconds

function LobbyMenu:enter(last, serverData)
    networking.currentServerID = serverData.id
    if networking.currentServerData ~= serverData then
        networking.hub:publish({
            message = {
                action = "updateServerInfo_USERJOINED",
                id = networking.currentServerID,
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName),
                    score = 0,
                    accuracy = 0
                }
            }
        })
    end
    networking.currentServerData = serverData
end

function LobbyMenu:update(dt)
end

function LobbyMenu:mousepressed(x, y, b)
    local x, y = toGameScreen(x, y)
    print(x, y)
    if x > 10 and x < 210 and y > 500 and y < 550 then
        if networking.connected then
            networking.hub:publish({
                message = {
                    action = "startGame"
                }
            })
        end
        networking.inMultiplayerGame = true

        local song = getSongFromNameAndDiff(networking.currentServerData.currentSong.songName, networking.currentServerData.currentSong.songDiff)
        local songPath = song.path
        local chartVer = song.type
        local folderPath = song.folderPath
        local filename = song.filename
        local diffName = song.difficultyName
        local mode = song.mode
        --print(songPath, chartVer, folderPath, filename, diffName, mode)
        love.filesystem.mount("songs/" .. filename, "song")
        states.game.Gameplay.chartVer = chartVer
        states.game.Gameplay.songPath = songPath
        states.game.Gameplay.folderpath = folderPath
        states.game.Gameplay.difficultyName = diffName
        switchState(states.game.Gameplay, 0.3, nil)
    end
end

function LobbyMenu:draw()
    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        setFont("menuExtraBold")
        love.graphics.print("Lobby", 10, 10, 0, 2, 2)

        setFont("menuExtraBold")
        love.graphics.print("Server Name: " .. networking.currentServerData.name, 10, 50)
        
        love.graphics.print("Host: " .. (networking.currentServerData.host or "Unknown"), 10, 70)
        love.graphics.print("Players: " .. #networking.currentServerData.players .. "/" .. networking.currentServerData.maxPlayers, 10, 90)
        for i, player in ipairs(networking.currentServerData.players) do
            love.graphics.print(player.name, 10, 110 + i * 20)
        end

        -- Current song.songNamed and songDiff text
        if networking.currentServerData.currentSong then
            love.graphics.print("Current Song: " .. networking.currentServerData.currentSong.songName, 10, 300)
            love.graphics.print("Difficulty: " .. networking.currentServerData.currentSong.songDiff, 10, 320)
        else
            love.graphics.print("Current Song: None", 10, 300)
            love.graphics.print("Difficulty: None", 10, 320)
        end

        -- start button
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", 10, 500, 200, 50)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Start Game", 10, 500, 200, "center")

    love.graphics.pop()
end

return LobbyMenu