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
                    accuracy = 0,
                    completed = false
                }
            }
        })
    end
    networking.currentServerData = serverData
end

function LobbyMenu:update(dt)
    if input:pressed("back") then
        if networking.connected then
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
        end
        switchState(states.menu.Multiplayer.ServerMenu, 0.3)
    end

    --[[ if input:pressed("confirm") then
        networking.hub:publish({
            message = {
                action = "serverLobby_CHATMESSAGE",
                id = networking.currentServerID,
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName)
                },
                message = {
                    user = {
                        steamID = tostring(SteamID),
                        name = tostring(SteamUserName)
                    },
                    message = "TESTING!",
                    time = os.time()
                }
            }
        })
    end ]]
end

function LobbyMenu:mousepressed(x, y, b)
    local x, y = toGameScreen(x, y)
    local canc = Header:mousepressed(x, y, b)
    if canc then return end
    if x > 10 and x < 210 and y > 600 and y < 650 then
        if networking.connected then
            networking.hub:publish({
                message = {
                    action = "startGame",
                    id = networking.currentServerID
                }
            })
        end
    end
end

function LobbyMenu:draw()
    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        setFont("menuExtraBold")
        love.graphics.print(localize("Lobby"), 10, 100, 0, 2, 2)

        setFont("menuExtraBold")
        if not networking.currentServerData then love.graphics.pop(); return end
        love.graphics.print(localize("Lobby Name: ") .. networking.currentServerData.name, 10, 150)
        
        love.graphics.print(localize("Host: ") .. (networking.currentServerData.host or "Unknown"), 10, 170)
        love.graphics.print(localize("Players: ") .. #networking.currentServerData.players .. "/" .. networking.currentServerData.maxPlayers, 10, 190)
        local x, y = 0, 210
        for i, player in ipairs(networking.currentServerData.players) do
            -- player.tags (table)
            local text = player.name

            -- for every 5 players, move the x position and reset the y position
            y = y + 20
            if i % 5 == 0 then
                x = x + 325
                y = 210
            end

            if table.find(player.tags, "Owner") then -- Game owner
                text = text .. " (Owner)"
            elseif table.find(player.tags, "Admin") then -- Admin
                text = text .. " (Admin)"
            elseif table.find(player.tags, "Mod") then -- Moderator
                text = text .. " (Mod)"
            elseif table.find(player.tags, "Developer") then -- Developers
                text = text .. " (Developer)"
            elseif table.find(player.tags, "Supporter") then -- Supporters
                text = text .. " (Supporter)"
            end

            love.graphics.print(text, 10 + x, y)
        end

        -- Current song.songNamed and songDiff text
        if networking.currentServerData.currentSong then
            love.graphics.print(localize("Current Song: ") .. networking.currentServerData.currentSong.songName, 10, 400)
            love.graphics.print(localize("Difficulty: ") .. networking.currentServerData.currentSong.songDiff, 10, 420)
        else
            love.graphics.print(localize("Current Song: None"), 10, 400)
            love.graphics.print(localize("Difficulty: None"), 10, 420)
        end

        -- start button
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", 10, 600, 200, 50)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(localize("Start Game"), 10, 600, 200, "center")

        Header:draw()

    love.graphics.pop()
end

return LobbyMenu