local dc = {}

dc.scale = 3 * 1.8
dc.lastDiffHandOne = {}
dc.lastDiffHandTwo = {}

function dc.CalculateDiff(self, accuracy)
    local chartc = table.copy(charthits)
    local accuracy = accuracy or .93
    dc.cleanedNotes = {}
    -- go through all of charthits[i] and add j to dc.cleanedNotes
    for i = 1, #chartc do
        for j = 1, #chartc[i] do
            table.insert(dc.cleanedNotes, chartc[i][j])
        end
    end

    dc.handOne = {}
    dc.handTwo = {}

    table.sort(dc.cleanedNotes, function(a, b) return a[1] < b[1] end)

    if #dc.cleanedNotes == 0 then
        return "N/A"
    end

    local firstNoteTime = dc.cleanedNotes[1][1]

    -- Normalize the notes

    for i,v in pairs(dc.cleanedNotes) do
        dc.cleanedNotes[i][1] = (dc.cleanedNotes[i][1] - firstNoteTime) * 2
        -- fixed note time
    end

    table.sort(dc.cleanedNotes, function(a, b) return a[1] < b[1] end)

    for i = 1, #dc.cleanedNotes do
        local note = dc.cleanedNotes[i]
        if note[3] == 1 or note[3] == 2 then
            table.insert(dc.handOne, note)
        elseif note[3] == 3 or note[3] == 4 then
            table.insert(dc.handTwo, note)
        end
    end

    dc.leftHandCol = {}
    dc.leftMHandCol = {}
    dc.rightHandCol = {}
    dc.rightMHandCol = {}

    for i = 1, #dc.handOne do
        if dc.handOne[i][3] == 1 then
            table.insert(dc.leftHandCol, dc.handOne[i][1])
        else
            table.insert(dc.leftMHandCol, dc.handOne[i][1])
        end
    end
    for i = 1, #dc.handTwo do
        if dc.handTwo[i][3] == 3 then
            table.insert(dc.rightHandCol, dc.handTwo[i][1])
        else
            table.insert(dc.rightMHandCol, dc.handTwo[i][1])
        end
    end

    dc.length = math.floor(((dc.cleanedNotes[#dc.cleanedNotes][1] / 1000) / 0.5))
    
    dc.segmentsOne = {}
    dc.segmentsTwo = {}
    for i = 1, dc.length do
        table.insert(dc.segmentsOne, {})
        table.insert(dc.segmentsTwo, {})
    end

    -- for i in handOne
    for i = 1, #dc.handOne do
        local note = dc.handOne[i]
        local index = math.floor((((note[1]*2)/1000)))
        if index + 1 > dc.length then
            break
        end
        table.insert(dc.segmentsOne[index + 1], note)
    end

    for i = 1, #dc.handTwo do
        local note = dc.handTwo[i]
        local index = math.floor((((note[1]*2)/1000)))
        if index + 1 > dc.length then
            break
        end
        table.insert(dc.segmentsTwo[index + 1], note)
    end
    
    dc.hand_npsOne = {}
    dc.hand_npsTwo = {}

    -- for i in segmentsOne
    for i = 1, #dc.segmentsOne do
        local segment = dc.segmentsOne[i]
        if segment == nil then break end
        table.insert(dc.hand_npsOne, #segment * dc.scale * 1.6)
    end

    for i = 1, #dc.segmentsTwo do
        local segment = dc.segmentsTwo[i]
        if segment == nil then break end
        table.insert(dc.hand_npsTwo, #segment * dc.scale * 1.6)
    end

    dc.hand_diffOne = {}
    dc.hand_diffTwo = {}

    for i = 1, #dc.segmentsOne do
        local ve = dc.segmentsOne[i]
        if ve == nil then
            break
        end
        local fyOne = {}
        local fyTwo = {}

        for j = 1, #ve do
            if ve[j][3] == 1 then
                table.insert(fyOne, ve[j])
            elseif ve[j][3] == 2 then
                table.insert(fyTwo, ve[j])
            end
        end
        
        local one = self:calcPerFinger(fyOne, dc.leftHandCol)
        local two = self:calcPerFinger(fyTwo, dc.leftMHandCol)

        local bf = ((((one > two and one or two) * 8) + (dc.hand_npsOne[i] / dc.scale) * 5) / 13) * dc.scale

        table.insert(dc.hand_diffOne, bf)
    end
    for i = 1, #dc.segmentsTwo do
        local ve = dc.segmentsTwo[i] 
        
        if ve == nil then
            break
        end
        local fyOne = {}
        local fyTwo = {}
        for j = 1, #ve do
            if ve[j][3] == 3 then
                table.insert(fyOne, ve[j])
            elseif ve[j][3] == 4 then
                table.insert(fyTwo, ve[j])
            end
        end

        local one = self:calcPerFinger(fyOne, dc.rightMHandCol)
        local two = self:calcPerFinger(fyTwo, dc.rightHandCol)

        local bf = ((((one > two and one or two) * 8) + (dc.hand_npsTwo[i] / dc.scale) * 5) / 13) * dc.scale

        table.insert(dc.hand_diffTwo, bf)
    end

    for i = 1, 4 do
        dc.hand_npsOne = self:smoothen(dc.hand_npsOne, 0)
        dc.hand_npsTwo = self:smoothen(dc.hand_npsTwo, 0)

        dc.hand_diffOne = self:smoothen2(dc.hand_diffOne)
        dc.hand_diffTwo = self:smoothen2(dc.hand_diffTwo)
    end

    dc.point_npsOne = {}
    dc.point_npsTwo = {}

    -- for i in segmentsOne
    for i = 1, #dc.segmentsOne do
        local segment = dc.segmentsOne[i]
        if segment == nil then break end
        table.insert(dc.point_npsOne, #segment)
    end

    for i = 1, #dc.segmentsTwo do
        local segment = dc.segmentsTwo[i]
        if segment == nil then break end
        table.insert(dc.point_npsTwo, #segment)
    end

    local maxPoints = 0
    for i = 1, #dc.point_npsOne do
        maxPoints = maxPoints + 1
    end
    for i = 1, #dc.point_npsTwo do
        maxPoints = maxPoints + 1
    end

    if accuracy > .965 then
        accuracy = .965
    end

    dc.lastDiffHandOne = dc.hand_diffOne
    dc.lastDiffHandTwo = dc.hand_diffTwo

    local lol = math.truncateFloat(self:chisel(accuracy, dc.hand_diffOne, dc.hand_diffTwo, dc.point_npsOne, dc.point_npsTwo, maxPoints), 2)
    return lol * 6
end

function dc.chisel(self, scoreGoal, diffOne, diffTwo, pointsOne, pointsTwo, maxPoints)
    local lowerBound = 0
    local upperBound = 100

    while upperBound - lowerBound > 0.01 do
        local average = (upperBound + lowerBound) / 2
        local amountOfPoints = self:calculate(average, diffOne, pointsOne) + self:calculate(average, diffTwo, pointsTwo)
        if amountOfPoints / maxPoints < scoreGoal then
            lowerBound = average
        else
            upperBound = average
        end
    end

    return upperBound
end

function dc.findIndex(self, st, array)
    for i = 1, #array do
        if array[i] == st then
            return i
        end
    end
    return -1
end

function dc.calculate(self, mP, diff, p)
    local output = 0

    for i = 1, #diff do
        local res = diff[i]
        if mP > res then
            output = output + p[i]
        else
            output = output + p[i] * math.pow(mP/res, 1.2)
        end
    end

    return output
end

function dc.calcPerFinger(self, floats, column)
    local sum = 0
    if #floats == 0 then
        return 0
    end
    local startIndex = dc:findIndex(floats[1][1], column)

    if startIndex == -1 then
        return 0
    end
    for i = 1, #floats-1 do
        --sum = sum + column[startIndex + 1] - column[startIndex]
        tryExcept(
            function()
                sum = sum + column[startIndex + 1] - column[startIndex]
            end,
            function()
                sum = sum
            end
        )
        startIndex = startIndex + 1
    end

    if sum == 0 then
        return 0
    end

    return (1375 * (#floats)) / sum
end

function dc.smoothen(self, nps, wc)
    local fOne = wc
    local fTwo = wc

    for i = 1, #nps do
        local result = nps[i]

        local chunker = fOne
        fOne = fTwo
        fTwo = result

        nps[i] = (chunker + fOne + fTwo) / 3
    end

    return nps
end

function dc.smoothen2(self, dv)
    local fZ = 0

    for i = 1, #dv do
        local result = dv[i]

        local f = fZ
        fZ = result
        dv[i] = (f + fZ) / 2
    end

    return dv
end

dc.divideRatingColours = {
    true,
    true,
    true,
    true,
    true,
    true,
    true
}

function dc.ratingColours(rating)
    -- blue = easy
    -- red = hard
    -- green = medium
    -- yellow = very easy
    -- purple = very hard
    -- orange = impossible

    --[[
        somewhat off of - https://github.com/Quaver/Quaver.API/blob/87c428ea9cd4229c5334b23c680cb4311546d6b7/Quaver.API/Maps/Processors/Difficulty/StrainColors.cs
        { ColorTier.Tier1, 0 },
        { ColorTier.Tier2, 6 },
        { ColorTier.Tier3, 14 },
        { ColorTier.Tier4, 26 },
        { ColorTier.Tier5, 32 },
        { ColorTier.Tier6, 40 },
        { ColorTier.Tier7, 58 }
        ..
        { ColorTier.Tier1, Color.FromArgb(255, 126, 111, 90) },
        { ColorTier.Tier2, Color.FromArgb(255, 184, 184, 184) },
        { ColorTier.Tier3, Color.FromArgb(255, 242, 218, 104) },
        { ColorTier.Tier4, Color.FromArgb(255, 146, 255, 172) },
        { ColorTier.Tier5, Color.FromArgb(255, 112, 227, 225) },
        { ColorTier.Tier6, Color.FromArgb(255, 255, 146, 255) },
        { ColorTier.Tier7, Color.FromArgb(255, 255, 97, 119) }
    --]]
    if rating < 6 then
        local col = skinJson["skin"]["difficultyColors"][1]
        if dc.divideRatingColours[1] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[1] = false
        end
        return col
    elseif rating < 14 then
        local col = skinJson["skin"]["difficultyColors"][2]
        if dc.divideRatingColours[2] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[2] = false
        end
        return col
    elseif rating < 26 then
        local col = skinJson["skin"]["difficultyColors"][3]
        if dc.divideRatingColours[3] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[3] = false
        end
        return col
    elseif rating < 32 then
        local col = skinJson["skin"]["difficultyColors"][4]
        if dc.divideRatingColours[4] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[4] = false
        end
        return col
    elseif rating < 40 then
        local col = skinJson["skin"]["difficultyColors"][5]
        if dc.divideRatingColours[5] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[5] = false
        end
        return col
    elseif rating < 58 then
        local col = skinJson["skin"]["difficultyColors"][6]
        if dc.divideRatingColours[6] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[6] = false
        end
        return col
    else
        local col = skinJson["skin"]["difficultyColors"][7]
        if dc.divideRatingColours[7] then
            col[1] = col[1] / 255
            col[2] = col[2] / 255
            col[3] = col[3] / 255
            dc.divideRatingColours[7] = false
        end
        return col
    end
end

return dc