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
        return 9999
    end

    --[[
    for i = 1, #dc.cleanedNotes do
        if firstNoteTime == nil then
            firstNoteTime = dc.cleanedNotes[i][1]
        end

        if dc.cleanedNotes[i][1] < firstNoteTime then
            firstNoteTime = dc.cleanedNotes[i][1]
        end

        -- normalize the notes

        dc.cleanedNotes[i][1] = (dc.cleanedNotes[i][1] - firstNoteTime) * 2

        if i == 1 or i == 2 then
            table.insert(dc.handOne, dc.cleanedNotes[i])
        else
            table.insert(dc.handTwo, dc.cleanedNotes[i])
        end
    end
    --]]

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
        else
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

    dc.length = ((dc.cleanedNotes[#dc.cleanedNotes][1] / 1000) / 0.5)
    
    dc.segmentsOne = {}
    dc.segmentsTwo = {}
    for i = #dc.segmentsOne, dc.length do
        table.insert(dc.segmentsOne, {})
        table.insert(dc.segmentsTwo, {})
    end

    -- algo loop
    for i, v in ipairs(dc.handOne) do
        local index = math.floor((((v[1]*2)/1000)))
        if index + 1 > dc.length then
            break
        end
        dc.segmentsOne[index + 1] = v
    end

    for i, v in ipairs(dc.handTwo) do
        local index = math.floor((((v[1]*2)/1000)))
        if index + 1 > dc.length then
            break
        end
        dc.segmentsTwo[index + 1] = v
    end
    
    dc.hand_npsOne = {}
    dc.hand_npsTwo = {}

    for i = 1, #dc.segmentsOne do
        if i == nil then break end
        table.insert(dc.hand_npsOne, #dc.segmentsOne[i] * dc.scale * 1.6)
    end
    for i = 1, #dc.segmentsTwo do
        if i == nil then break end
        table.insert(dc.hand_npsTwo, #dc.segmentsTwo[i] * dc.scale * 1.6)
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

        if ve[3] == 1 then
            table.insert(fyOne, ve)
        elseif ve[3] == 2 then
            table.insert(fyTwo, ve)
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
        
        if ve[3] == 3 then
            table.insert(fyOne, ve)
        elseif ve[3] == 4 then
            table.insert(fyTwo, ve)
        end

        local one = self:calcPerFinger(fyOne, dc.rightMHandCol)
        local two = self:calcPerFinger(fyTwo, dc.rightHandCol)

        local bf = ((((one > two and one or two) * 8) + (dc.hand_npsTwo[i] / dc.scale) * 5) / 13) * dc.scale

        table.insert(dc.hand_diffTwo, bf)
    end

    for i = 1, 4 do
        self:smoothen(dc.hand_npsOne, 0)
        self:smoothen(dc.hand_npsTwo, 0)

        self:smoothen2(dc.hand_diffOne)
        self:smoothen2(dc.hand_diffTwo)
    end

    dc.point_npsOne = {}
    dc.point_npsTwo = {}

    for i = 1, #dc.segmentsOne do
        if i == nil then
            break
        else
            table.insert(dc.point_npsOne, dc.hand_npsOne[i])
        end
    end
    for i = 1, #dc.segmentsTwo do
        if i == nil then
            break
        else
            table.insert(dc.point_npsTwo, dc.hand_npsTwo[i])
        end
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

    print(dc.hand_diffOne, dc.hand_diffTwo, dc.point_npsOne, dc.point_npsTwo, maxPoints)

    local lol = math.truncateFloat(self:chisel(accuracy, dc.hand_diffOne, dc.hand_diffTwo, dc.point_npsOne, dc.point_npsTwo, maxPoints), 2) * 25
    print(lol)
    return lol
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
        sum = sum + column[startIndex + 1] - column[startIndex]
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
end

function dc.smoothen2(self, dv)
    local fZ = 0

    for i = 1, #dv do
        local result = dv[i]

        local f = fZ
        fZ = result
        dv[i] = (f + fZ) / 2
    end
end

return dc