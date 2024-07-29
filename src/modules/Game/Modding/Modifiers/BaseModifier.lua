local Modifier = Object:extend()
Modifier.name = "Base"
Modifier.percents = {0} -- add more with each playfield
Modifier.submods = {}
Modifier.parent = nil
Modifier.active = false

function Modifier:new(parent)
    self.parent = parent
    for _, submod in ipairs(self:getSubmods()) do
        self.submods[submod] = BaseSubModifier(submod, self)
    end
end

function Modifier:getOrder()
    return 1
end

function Modifier:getValue(playfield)
    return self.percents[math.clamp(1, playfield, #self.percents)]
end

function Modifier:getPercent(playfield)
    return self.percents[math.clamp(1, playfield, #self.percents)] * 100
end

function Modifier:setValue(value, playfield)
    if playfield < 1 then
        -- do all of them
        for i = 1, #self.percents do
            self.percents[i] = value
        end
    else
        self.percents[math.clamp(1, playfield, #self.percents)] = value
    end
end

function Modifier:setPercent(percent, playfield)
    self:setValue(percent * 0.01, playfield)
end

function Modifier:getSubmods()
    return {}
end

function Modifier:getSubmodPercent(modName, playfield)
    if self.submods[modName] then
        return self.submods[modName]:getPercent(playfield)
    end

    return 0
end

function Modifier:getSubmodValue(modName, playfield)
    if self.submods[modName] then
        return self.submods[modName]:getSubmodValue(playfield)
    end

    return 0
end

function Modifier:setSubmodPercent(modName, endPercent, playfield)
    if self.submods[modName] then
        self.submods[modName]:setPercent(endPercent, playfield)
    end
end

function Modifier:setSubmodValue(modName, endValue, playfield)
    if self.submods[modName] then
        self.submods[modName]:setValue(endValue, playfield)
    end
end

function Modifier:updateReceptor()
end

function Modifier:updateNote()
end

function Modifier:getPos()
end

function Modifier:update()
end

return Modifier