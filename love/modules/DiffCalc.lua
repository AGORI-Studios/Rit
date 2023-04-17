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
        if dc.handTwo[i][3] == 1 then
            table.insert(dc.rightHandCol, dc.handTwo[i][1])
        else
            table.insert(dc.rightMHandCol, dc.handTwo[i][1])
        end
    end

    dc.length = ((dc.cleanedNotes[#dc.cleanedNotes][1] / 1000) / 0.5)
    
    dc.segmentsOne = {}
    dc.segmentsTwo = {}

    for i = 1, #dc.cleanedNotes do
        table.insert(dc.segmentsOne, dc.cleanedNotes[i])
        table.insert(dc.segmentsTwo, dc.cleanedNotes[i])
    end

    for i,v in pairs(dc.handOne) do
        local index = math.floor((((v[1]*2)/1000)))
        table.insert(dc.segmentsOne, v)
    end
    for i,v in pairs(dc.handTwo) do
        local index = math.floor((((v[1]*2)/1000)))
        table.insert(dc.segmentsTwo, v)
    end

    dc.hand_npsOne = {}
    dc.hand_npsTwo = {}

    for i = 1, #dc.segmentsOne do
        table.insert(dc.hand_npsOne, #dc.segmentsOne[i] * dc.scale * 1.6)
    end
    for i = 1, #dc.segmentsTwo do
        table.insert(dc.hand_npsTwo, #dc.segmentsTwo[i] * dc.scale * 1.6)
    end

    dc.hand_diffOne = {}
    dc.hand_diffTwo = {}

    for i = 1, #dc.segmentsOne do
        local ve = dc.segmentsOne[i]
        if ve == nil then
            ve = 1
        end
        local fyOne = {}
        local fyTwo = {}
        for j = 1, #ve do
            if ve[j] == 0 then
                table.insert(fyOne, ve[j])
            elseif ve[j] == 1 then
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
            ve = {}
        end
        local fyOne = {}
        local fyTwo = {}
        for j = 1, #ve do
            if ve[j] == 0 then
                table.insert(fyOne, ve[j])
            elseif ve[j] == 1 then
                table.insert(fyTwo, ve[j])
            end
        end

        local one = self:calcPerFinger(fyOne, dc.rightHandCol)
        local two = self:calcPerFinger(fyTwo, dc.rightMHandCol)

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
            table.insert(dc.point_npsOne, 0)
        else
            table.insert(dc.point_npsOne, dc.hand_npsOne[i])
        end
    end
    for i = 1, #dc.segmentsTwo do
        if i == nil then
            table.insert(dc.point_npsTwo, 0)
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

    return math.truncateFloat(self:chisel(accuracy, dc.hand_diffOne, dc.hand_diffTwo, dc.point_npsOne, dc.point_npsTwo, maxPoints), 2)
end

function dc.chisel(self, sG, dO, dT, pO, pT, mP)
    local lB = 0
    local uB = 100

    while uB - lB > .01 do
        local mid = (lB + uB) / 2
        local diff = self:calculate(mid, dO, pO) + self:calculate(mid, dT, pT)
        if diff / mP < sG then
            lB = mid
        else
            uB = mid
        end
    end

    return uB
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

function dc.calcPerFinger(self, float, column)
    local column = column or {}
    local sum = 0
    if #float == 0 then
        --print("no floats")
        return 0
    end
    local startIndex = dc:findIndex(float[1], column)
    if startIndex == -1 then
        --print("no start index")
        return 0
    end
    for i = 1, #float do
        if column[startIndex+1] ~= nil then
            sum = sum + column[startIndex+1] - column[startIndex]
        else
            sum = sum + 1
        end
        startIndex = startIndex + 1
    end

    if sum == 0 then
        --print("no sum")
        return 0
    end

    print("sum: " .. sum)
    return (1375 * (#float)) / sum
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