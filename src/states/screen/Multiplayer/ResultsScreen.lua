local ResultsScreen = state()
ResultsScreen.isEveryoneFinished = false
ResultsScreen.results = {}

function ResultsScreen:enter(_, results)
    if Steam and networking.connected and networking.currentServerData then
        networking.hub:publish({
            message = {
                action = "resultScreen_NEWENTRY",
                id = networking.currentServerID,
                user = {
                    steamID = tostring(SteamID),
                    name = tostring(SteamUserName),
                    score = results.score,
                    accuracy = results.accuracy,
                    completed = true
                }
            }
        })
    end

    self.results = results
end

function ResultsScreen:update(dt)
    if input:pressed("back") or input:pressed("confirm") then
        switchState(states.menu.Multiplayer.LobbyMenu, 0.3, nil, networking.currentServerData)
    end
end

function ResultsScreen:mousepressed(x, y, b) end

function ResultsScreen:draw()
    love.graphics.push()
        love.graphics.setColor(1, 1, 1)
        setFont("menuExtraBold")
        love.graphics.print(localize("Results"), 10, 10, 0, 2, 2)

        setFont("menuExtraBold")
        love.graphics.print(localize("Score: ") .. self.results.score, 10, 70)
        love.graphics.print(localize("Accuracy: ") .. self.results.accuracy, 10, 90)

        if self.isEveryoneFinished then
            love.graphics.print(localize("Everyone has finished!"), 10, 110)
        else
            love.graphics.print(localize("Waiting for everyone to finish..."), 10, 110)
        end

        -- for everyone in networking.currentServerData.players
        if Steam and networking.connected and networking.currentServerData then
            for i, player in ipairs(networking.currentServerData.players) do
                -- Name -\nScore: score\nAccuracy: accuracy\nfinished/not finished
                love.graphics.print(player.name .. " -", 10, 130 + i * 100)
                love.graphics.print(localize("Score: ") .. math.floor(player.score), 10, 150 + i * 100)
                love.graphics.print(localize("Accuracy: ") .. string.format("%.2f", player.accuracy) .. "%", 10, 170 + i * 100)
                if player.completed then
                    love.graphics.print(localize("Finished"), 10, 190 + i * 100)
                else
                    love.graphics.print(localize("Not Finished"), 10, 190 + i * 100)
                end
            end
        end
    love.graphics.pop()
end

return ResultsScreen