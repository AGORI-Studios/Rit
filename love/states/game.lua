inputList = {
    "one4",
    "two4",
    "three4",
    "four4"
}

return {
    enter = function(self)
        now = os.time()
        scoring = {
            score = 0,
            accuracy = 0,
            ["Marvellous"] = 0,
            ["Perfect"] = 0,
            ["Great"] = 0,
            ["Good"] = 0,
            ["Miss"] = 0
        }
        combo = 0

        lastReportedPlaytime = 0
        previousFrameTime = love.timer.getTime() * 1000
        additionalScore = 0
        additionalAccuracy = 0
        noteCounter = 0
    
        songRate = 1
        musicTime = 0

        strumLineY = 250

        health = 1
        died = false
        musicPosValue = {1000}
        musicPitch = {1}

        for i = 1, 4 do 
            for t = 1, 2 do 
                receptors[i][t].x = 650 + (i * 225)
                receptors[i][t].y = strumLineY
            end

            print(#charthits[i])
        end
    end,

    update = function(self, dt)
        musicTime = musicTime + 1000 * dt
        for i = 1, 4 do 
            curInput = inputList[i]
            notes = charthits[i]
            if input:down(curInput) then 
                receptors[i][3] = 2
            else
                receptors[i][3] = 1
            end

            if input:pressed(curInput) then 
                if hitsoundCache[#hitsoundCache]:isPlaying() then
                    hitsoundCache[#hitsoundCache] = hitsoundCache[#hitsoundCache]:clone()
                    hitsoundCache[#hitsoundCache]:play()
                else
                    hitsoundCache[#hitsoundCache]:play()
                end
                for hit = 2, #hitsoundCache do
                    if not hitsoundCache[hit]:isPlaying() then
                        hitsoundCache[hit] = nil -- Nil afterwords to prevent memory leak
                    end --                             maybe, idk how love2d works lmfao
                end

                for _, hitObject in ipairs(notes) do 
                    if hitObject.time - musicTime >= -80 and hitObject.time - musicTime <= 180 and ((hitObject.prevNote ~= nil and not hitObject.prevNote.isSustainNote) or hitObject.prevNote == nil) then
                        noteCounter = noteCounter + 1
                        pos = math.abs(hitObject.time - musicTime)
                        if pos < 45 then 
                            judgement = "Marvellous"
                            health = health + 0.135
                            additionalScore = additionalScore + 650
                            additionalAccuracy = additionalAccuracy + 100
                        elseif pos < 60 then
                            judgement = "Perfect"
                            health = health + 0.1
                            additionalScore = additionalScore + 500
                            additionalAccuracy = additionalAccuracy + 100
                        elseif pos < 75 then
                            judgement = "Great"
                            health = health + 0.075
                            additionalScore = additionalScore + 350
                            additionalAccuracy = additionalAccuracy + 75
                        elseif pos < 120 then
                            judgement = "Good"
                            health = health + 0.05
                            additionalScore = additionalScore + 200
                            additionalAccuracy = additionalAccuracy + 50
                        else
                            judgement = "Miss"
                            health = health - 0.05
                            additionalScore = additionalScore - 100
                        end

                        if health > 2 then health = 2 end
                        scoring[judgement] = scoring[judgement] + 1
                        if scoringTimer then 
                            Timer.cancel(scoringTimer)
                        end
                        if accuracyTimer then
                            Timer.cancel(accuracyTimer)
                        end
                        scoringTimer = Timer.tween(
                            0.35,
                            scoring,
                            {score = additionalScore},
                            "out-quad",
                            function()
                                scoringTimer = nil
                            end
                        )
                        accuracyTimer = Timer.tween(
                            0.35,
                            scoring,
                            {accuracy = additionalAccuracy / (noteCounter + (scoring["Miss"] or 0))},
                            "out-quad",
                            function()
                                accuracyTimer = nil
                            end
                        )

                        table.remove(notes, _)
                    end
                end
            end
        end
        for _, charthits in ipairs(charthits) do
            for _, hitObject in ipairs(charthits) do 
                hitObject:update(dt)
                hitObject.y = (strumLineY + ( 1 * -((musicTime - hitObject.time) * 0.45 * speed))) - 50

                -- if the note is above the strum line, it's a miss
                --[[ -- too lazy for math, gotta get this stencil working sooner or later though
                if hitObject.y < strumLineY then
                   
                    scoring["Miss"] = scoring["Miss"] + 1
                    scoring.accuracy = scoring.accuracy - 0.05
                    table.remove(charthits, _)
                    print("Miss")                    

                    if not hitObject.isSustainNote then
                        table.remove(charthits, _)
                    else
                        local center = strumLineY + hitObject.spr:getHeight() / 2
                        local vert = center - hitObject.y
                        if hitObject.y + hitObject.spr:getHeight() * hitObject.scale.y >= center then
                            if not hitObject.spr.stencilInfo then hitObject.spr.stencilInfo = {} end
                            hitObject.spr.stencilInfo.x = 0
                            hitObject.spr.stencilInfo.y = 0
                            hitObject.spr.stencilInfo.width = hitObject.spr:getWidth() * hitObject.scale.x
                            hitObject.spr.stencilInfo.height = vert
                        end
                    end
                    
                end
                --]]

                if hitObject.y <= 0 - hitObject.spr:getHeight() * hitObject.scale.y then 
                    if not hitObject.isSustainNote then
                        scoring["Miss"] = scoring["Miss"] + 1
                        noteCounter = noteCounter + 1
                    end
                    table.remove(charthits, _)
                end
            end
        end

    end,

    draw = function(self)
        graphics.drawReceptors()
        graphics.drawNotes()
    end,

    leave = function(self)

    end
}